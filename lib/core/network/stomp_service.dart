import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/api_strings.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/core/constants/stomp_path.dart';

//Định nghĩa kiểu cho hàm Unsubscribe
typedef StompUnsubscribeTopic = void Function();

enum ConnectionStatus { disconnected, connecting, connected }

class _Subscription {
  final String destination;
  final void Function(StompFrame frame) onMessage;
  StompUnsubscribeTopic? unsubscribeCallback;

  _Subscription({
    required this.destination,
    required this.onMessage,
  });
}

class StompService {
  StompService();

  bool _isDisposed = false;

  StompClient? _stompClient;
  ConnectionStatus _status = ConnectionStatus.disconnected;

  // Stream controller để broadcast connection status
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  ConnectionStatus get status => _status;

  // Stream controller để broadcast token refresh requests
  final _tokenRefreshController = StreamController<void>.broadcast();
  Stream<void> get tokenRefreshRequestStream => _tokenRefreshController.stream;

  // Lưu tất cả subscriptions để re-subscribe sau khi reconnect
  final Map<String, _Subscription> _subscriptions = {};

  // Hàng đợi cho các hàm cần chạy KHI kết nối thành công
  final List<void Function()> _onConnectCallbacks = [];

  // Auto-reconnect config
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  static const int _maxReconnectDelay = 16; // seconds
  static const int _baseReconnectDelay = 2; // seconds

  void _updateStatus(ConnectionStatus newStatus) {
    if (_isDisposed) return;

    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      print('[WebSocket] Status changed: $newStatus');
    }
  }

  // Helper method để refresh token
  Future<bool> _refreshToken() async {
    try {
      print('[WebSocket] Attempting to refresh token...');

      final secureStorage = FlutterSecureStorage();
      final accessToken = await secureStorage.read(key: SharedPreferenceKey.accessToken);
      final refreshToken = await secureStorage.read(key: SharedPreferenceKey.refreshToken);

      if (accessToken == null || refreshToken == null) {
        print('[WebSocket] No tokens found, cannot refresh');
        return false;
      }

      final dio = Dio(BaseOptions(baseUrl: ApiPath.baseUrl));
      final response = await dio.post(
        ApiPath.auth.refresh,
        data: {
          ApiStrings.accessToken: accessToken,
          ApiStrings.refreshToken: refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data'][ApiStrings.accessToken];
        await secureStorage.write(key: SharedPreferenceKey.accessToken, value: newAccessToken);
        print('[WebSocket] ✅ Token refreshed successfully');
        print('[WebSocket] new access token: $newAccessToken');
        return true;
      }

      print('[WebSocket] ❌ Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('[WebSocket] ❌ Error refreshing token: $e');
      return false;
    }
  }

  void connect() {
    if (_isDisposed) return;
    if (_status == ConnectionStatus.connected ||
        _status == ConnectionStatus.connecting) {
      print(
        '[WebSocket] Already ${_status == ConnectionStatus.connected ? "connected" : "connecting"}',
      );
      return;
    }

    // Cancel any pending reconnect timer
    _reconnectTimer?.cancel();

    // Luôn tạo client mới để lấy token mới nhất từ SharedPreferences
    // (trong trường hợp token đã được refresh)
    if (_stompClient != null) {
      print('[WebSocket] Deactivating old client...');
      _stompClient!.deactivate();
      _stompClient = null;
    }

    print('[WebSocket] Starting connection process...');
    _updateStatus(ConnectionStatus.connecting);

    // Lấy token và tạo client
    _initializeAndConnect();
  }

  Future<void> _initializeAndConnect() async {
    try {
      //change from SharedPreferences to SecureStorage
      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString(SharedPreferenceKey.accessToken);
      final secureStorage = FlutterSecureStorage();
      final accessToken = await secureStorage.read(
        key: SharedPreferenceKey.accessToken,
      );

      if (accessToken == null) {
        print('[WebSocket] No token found, cannot connect');
        _updateStatus(ConnectionStatus.disconnected);
        return;
      }

      print('[WebSocket] Token found, creating client...');

      _stompClient = StompClient(
        config: StompConfig.sockJS(
          url: StompPath.websocketUrl,
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
          },
          onConnect: _onConnect,
          beforeConnect: () async {
            print('[WebSocket] Before connect delay...');
            await Future.delayed(const Duration(milliseconds: 300));
          },
          onWebSocketError: _onError,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('[WebSocket] Error during initialization: $e');
      _updateStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  void _onConnect(StompFrame frame) {
    print('[WebSocket] ✅ Connected successfully');
    _updateStatus(ConnectionStatus.connected);
    _reconnectAttempts = 0; // Reset reconnect counter

    // Re-subscribe tất cả subscriptions đã lưu
    _resubscribeAll();

    // Chạy tất cả callbacks đang chờ
    for (final callback in _onConnectCallbacks) {
      callback();
    }
    _onConnectCallbacks.clear();
  }

  void _onError(dynamic error) {
    print('[WebSocket] ❌ Error: $error');
    _updateStatus(ConnectionStatus.disconnected);
    _stompClient?.deactivate();
    _stompClient = null;
    _scheduleReconnect();
  }

  void _onStompError(StompFrame frame) async {
    print('[WebSocket] ❌ STOMP Error: $frame');

    _updateStatus(ConnectionStatus.disconnected);

    // Deactivate và clear client để force tạo mới với token mới
    _stompClient?.deactivate();
    _stompClient = null;

    // print('[WebSocket] Token/Auth error detected. Refreshing token...');
    // // Notify listeners cần refresh token
    // _tokenRefreshController.add(null);

    // // Cố gắng refresh token trước khi reconnect
    // final refreshed = await _refreshToken();

    // if (refreshed) {
    //   // Reset reconnect attempts để retry nhanh với token mới
    //   _reconnectAttempts = 0;
    // }

    _scheduleReconnect();
  }

  void _onDisconnect(StompFrame frame) {
    print('[WebSocket] 🔌 Disconnected');
    _updateStatus(ConnectionStatus.disconnected);
    _stompClient?.deactivate();
    _stompClient = null;

    // Clear unsubscribe callbacks (they're invalid now)
    for (var sub in _subscriptions.values) {
      sub.unsubscribeCallback = null;
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;

    // Don't reconnect if manually disconnected or already scheduling
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      print('[WebSocket] ⚠️ Reconnect timer already active, skipping');
      return;
    }

    _reconnectAttempts++;

    // Exponential backoff: 2s, 4s, 8s, 16s, 30s (max)
    final delay = (_baseReconnectDelay * (1 << (_reconnectAttempts - 1))).clamp(
      0,
      _maxReconnectDelay,
    );

    print(
      '[WebSocket] 🔄 Reconnecting in $delay seconds (attempt $_reconnectAttempts)...',
    );

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      print('[WebSocket] Attempting reconnection...');
      connect();
    });
  }

  void _resubscribeAll() {
    print('[WebSocket] Re-subscribing to ${_subscriptions.length} topics...');
    for (var sub in _subscriptions.values) {
      _doSubscribe(sub);
    }
  }

  void _doSubscribe(_Subscription sub) {
    if (_stompClient == null || _status != ConnectionStatus.connected) {
      print(
        '[WebSocket] Cannot subscribe (not connected): ${sub.destination}',
      );
      return;
    }

    print('[WebSocket] 📡 Subscribing: ${sub.destination}');
    sub.unsubscribeCallback = _stompClient!.subscribe(
      destination: sub.destination,
      callback: (StompFrame frame) {
        // Log message details
        print('\n[WebSocket] 📨 Message received on: ${sub.destination}');
        print('[WebSocket] Headers: ${frame.headers}');
        print('[WebSocket] Body: ${frame.body ?? "(empty)"}');
        sub.onMessage(frame);
      },
    );
  }

  // Hàm Subscribe (trả về hàm Unsubscribe)
  StompUnsubscribeTopic subscribe(
    String destination, {
    required void Function(StompFrame frame) onMessage,
  }) {
    // Kiểm tra nếu đã subscribe topic này rồi
    if (_subscriptions.containsKey(destination)) {
      print('[WebSocket] ⚠️ Already subscribed to: $destination');
      return _subscriptions[destination]!.unsubscribeCallback ?? () {};
    }

    // Tạo subscription mới và lưu lại
    final subscription = _Subscription(
      destination: destination,
      onMessage: onMessage,
    );
    _subscriptions[destination] = subscription;

    // Subscribe ngay nếu đã connected
    if (_status == ConnectionStatus.connected) {
      _doSubscribe(subscription);
    } else {
      print('[WebSocket] ⏳ Queued subscription: $destination');
      // Add to queue if not connected yet
      _onConnectCallbacks.add(() => _doSubscribe(subscription));

      // Trigger connect if not connecting
      if (_status == ConnectionStatus.disconnected) {
        connect();
      }
    }

    // Return unsubscribe function
    return () {
      print('[WebSocket] 🚫 Unsubscribing: $destination');
      if (subscription.unsubscribeCallback != null) {
        subscription.unsubscribeCallback!();
      }
      _subscriptions.remove(destination);
    };
  }

  void disconnect() {
    print('[WebSocket] Manual disconnect requested');
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;

    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }

    // Clear all subscriptions
    _subscriptions.clear();
    _onConnectCallbacks.clear();
    _updateStatus(ConnectionStatus.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _statusController.close();
    _tokenRefreshController.close();
  }
}
