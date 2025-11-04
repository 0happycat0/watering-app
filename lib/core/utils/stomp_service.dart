import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/core/constants/stomp_path.dart';

//Định nghĩa kiểu cho hàm Unsubscribe
typedef StompUnsubscribeTopic = void Function();

class StompService {
  static final StompService _instance = StompService._internal();
  factory StompService() => _instance;
  StompService._internal();

  StompClient? _stompClient;
  bool _isConnected = false;
  bool _isConnecting = false;

  //Hàng đợi cho các hàm cần chạy KHI kết nối thành công
  final List<void Function()> _onConnectCallbacks = [];

  void connect() {
    if (_isConnected || _isConnecting) {
      if (_isConnected) print('[WebSocket] Đã kết nối.');
      if (_isConnecting) print('[WebSocket] Đang trong quá trình kết nối...');
      return;
    }

    if (_stompClient != null) {
      print('[WebSocket] Client đã tồn tại, đang kích hoạt...');
      _stompClient!.activate();
      return;
    }

    print('[WebSocket] Bắt đầu quá trình kết nối (async)...');
    _isConnecting = true;

    // lấy token và tạo client
    _initializeAndConnect();
  }

  Future<void> _initializeAndConnect() async {
    final prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString(SharedPreferenceKey.accessToken);

    print(
      token != null
          ? '[WebSocket] Đã lấy token.'
          : '[WebSocket] Không tìm thấy token (kết nối không xác thực).',
    );

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: StompPath.websocketUrl,

        stompConnectHeaders: {
          if (token != null) 'Authorization': 'Bearer $token',
        },

        onConnect: (StompFrame frame) {
          print('[WebSocket] Kết nối thành công.');
          _isConnected = true;
          _isConnecting = false;
          // Chạy tất cả các hàm subscribe đang chờ
          for (final callback in _onConnectCallbacks) {
            callback();
          }
          _onConnectCallbacks.clear();
        },
        beforeConnect: () async {
          print('[WebSocket] Chờ kết nối...');
          await Future.delayed(const Duration(milliseconds: 300));
        },
        onWebSocketError: (dynamic error) {
          print('[WebSocket] Lỗi: $error');
          _isConnected = false;
          _isConnecting = false;
          _stompClient = null;
        },
        onDisconnect: (frame) {
          print('[WebSocket] Đã ngắt kết nối.');
          _isConnected = false;
          _isConnecting = false;
          _stompClient = null;
        },
      ),
    );

    _stompClient!.activate();
  }

  //Thêm hàm Subscribe (trả về hàm Unsubscribe)
  StompUnsubscribeTopic subscribe(
    String destination, {
    required void Function(StompFrame frame) onMessage,
  }) {
    StompUnsubscribeTopic? unsubscribeCallback;

    void doSubscribe() {
      if (_stompClient == null) return;

      print('[WebSocket] Đang subscribe $destination');
      unsubscribeCallback = _stompClient!.subscribe(
        destination: destination,
        callback: (StompFrame frame) {
          onMessage(frame);
        },
      );
    }

    if (_isConnected) {
      doSubscribe();
    } else {
      print('[WebSocket] Thêm $destination vào hàng đợi (chờ kết nối).');
      _onConnectCallbacks.add(doSubscribe);
      if (_stompClient == null && !_isConnecting) {
        connect();
      }
    }

    return () {
      if (unsubscribeCallback != null) {
        print('[WebSocket] Đang unsubscribe $destination');
        unsubscribeCallback!();
      }
    };
  }

  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    _isConnecting = false;
    _onConnectCallbacks.clear();
    print('[WebSocket] Đã ngắt kết nối (toàn bộ).');
  }
}
