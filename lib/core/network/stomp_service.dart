import 'dart:async';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/api_strings.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/core/constants/stomp_path.dart';
import 'package:watering_app/core/utils/debug_print.dart';
import 'package:watering_app/core/utils/secure_storage_service.dart';

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
      printDebug('[WebSocket] Status changed: $newStatus');
    }
  }

  // Helper method để refresh token
  Future<bool> _refreshToken() async {
    try {
      printDebug('[WebSocket] Attempting to refresh token...');

      final accessToken = await SecureStorageService.instance.read(
        key: SharedPreferenceKey.accessToken,
      );
      final refreshToken = await SecureStorageService.instance.read(
        key: SharedPreferenceKey.refreshToken,
      );

      if (accessToken == null || refreshToken == null) {
        printDebug('[WebSocket] No tokens found, cannot refresh');
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
        await SecureStorageService.instance.write(
          key: SharedPreferenceKey.accessToken,
          value: newAccessToken,
        );
        printDebug('[WebSocket] ✅ Token refreshed successfully');
        printDebug('[WebSocket] new access token: $newAccessToken');
        return true;
      }

      printDebug('[WebSocket] ❌ Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      printDebug('[WebSocket] ❌ Error refreshing token: $e');
      return false;
    }
  }

  void connect() {
    if (_isDisposed) return;
    if (_status == ConnectionStatus.connected ||
        _status == ConnectionStatus.connecting) {
      printDebug(
        '[WebSocket] Already ${_status == ConnectionStatus.connected ? "connected" : "connecting"}',
      );
      return;
    }

    // Cancel any pending reconnect timer
    _reconnectTimer?.cancel();

    // Luôn tạo client mới để lấy token mới nhất từ SharedPreferences
    // (trong trường hợp token đã được refresh)
    if (_stompClient != null) {
      printDebug('[WebSocket] Deactivating old client...');
      _stompClient!.deactivate();
      _stompClient = null;
    }

    printDebug('[WebSocket] Starting connection process...');
    _updateStatus(ConnectionStatus.connecting);

    // Lấy token và tạo client
    _initializeAndConnect();
  }

  Future<void> _initializeAndConnect() async {
    try {
      //change from SharedPreferences to SecureStorage
      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString(SharedPreferenceKey.accessToken);

      final accessToken = await SecureStorageService.instance.read(
        key: SharedPreferenceKey.accessToken,
      );

      if (accessToken == null) {
        printDebug('[WebSocket] No token found, cannot connect');
        _updateStatus(ConnectionStatus.disconnected);
        return;
      }

      printDebug('[WebSocket] Token found, creating client...');

      _stompClient = StompClient(
        config: StompConfig.sockJS(
          url: StompPath.websocketUrl,
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
          },
          onConnect: _onConnect,
          beforeConnect: () async {
            printDebug('[WebSocket] Before connect delay...');
            await Future.delayed(const Duration(milliseconds: 300));
          },
          onWebSocketError: _onError,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      printDebug('[WebSocket] Error during initialization: $e');
      _updateStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  void _onConnect(StompFrame frame) {
    printDebug('[WebSocket] ✅ Connected successfully');
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
    printDebug('[WebSocket] ❌ Error: $error');
    _updateStatus(ConnectionStatus.disconnected);
    _stompClient?.deactivate();
    _stompClient = null;
    _scheduleReconnect();
  }

  void _onStompError(StompFrame frame) async {
    printDebug('[WebSocket] ❌ STOMP Error: $frame');

    _updateStatus(ConnectionStatus.disconnected);

    // Deactivate và clear client để force tạo mới với token mới
    _stompClient?.deactivate();
    _stompClient = null;

    // printDebug('[WebSocket] Token/Auth error detected. Refreshing token...');
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
    printDebug('[WebSocket] 🔌 Disconnected');
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
      printDebug('[WebSocket] ⚠️ Reconnect timer already active, skipping');
      return;
    }

    _reconnectAttempts++;

    // Exponential backoff: 2s, 4s, 8s, 16s, 30s (max)
    final delay = (_baseReconnectDelay * (1 << (_reconnectAttempts - 1))).clamp(
      0,
      _maxReconnectDelay,
    );

    printDebug(
      '[WebSocket] 🔄 Reconnecting in $delay seconds (attempt $_reconnectAttempts)...',
    );

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      printDebug('[WebSocket] Attempting reconnection...');
      connect();
    });
  }

  void _resubscribeAll() {
    printDebug(
      '[WebSocket] Re-subscribing to ${_subscriptions.length} topics...',
    );
    for (var sub in _subscriptions.values) {
      _doSubscribe(sub);
    }
  }

  void _doSubscribe(_Subscription sub) {
    if (_stompClient == null || _status != ConnectionStatus.connected) {
      printDebug(
        '[WebSocket] Cannot subscribe (not connected): ${sub.destination}',
      );
      return;
    }

    printDebug('[WebSocket] 📡 Subscribing: ${sub.destination}');
    sub.unsubscribeCallback = _stompClient!.subscribe(
      destination: sub.destination,
      callback: (StompFrame frame) {
        // Log message details
        printDebug('\n[WebSocket] 📨 Message received on: ${sub.destination}');
        printDebug('[WebSocket] Headers: ${frame.headers}');
        printDebug('[WebSocket] Body: ${frame.body ?? "(empty)"}');
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
      printDebug('[WebSocket] ⚠️ Already subscribed to: $destination');
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
      printDebug('[WebSocket] ⏳ Queued subscription: $destination');
      // Add to queue if not connected yet
      _onConnectCallbacks.add(() => _doSubscribe(subscription));

      // Trigger connect if not connecting
      if (_status == ConnectionStatus.disconnected) {
        connect();
      }
    }

    // Return unsubscribe function
    return () {
      printDebug('[WebSocket] 🚫 Unsubscribing: $destination');
      if (subscription.unsubscribeCallback != null) {
        subscription.unsubscribeCallback!();
      }
      _subscriptions.remove(destination);
    };
  }

  void disconnect() {
    printDebug('[WebSocket] Manual disconnect requested');
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
