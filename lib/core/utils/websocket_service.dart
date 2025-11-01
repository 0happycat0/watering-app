import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/api_path.dart';

//Định nghĩa kiểu cho hàm Unsubscribe
typedef StompUnsubscribeTopic = void Function();

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _stompClient;
  bool _isConnected = false;

  // 2. Hàng đợi cho các hàm cần chạy KHI kết nối thành công
  final List<void Function()> _onConnectCallbacks = [];

  // Hàm này chỉ KẾT NỐI, không subscribe
  void connect() {
    if (_isConnected || (_stompClient != null && _stompClient!.connected)) {
      print('[WebSocket] Đã kết nối.');
      _isConnected = true;
      return;
    }

    if (_stompClient != null) {
      print('[WebSocket] Đang trong quá trình kết nối...');
      return;
    }

    print('[WebSocket] Đang kết nối...');
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: ApiPath.websocketUrl,
        onConnect: (StompFrame frame) {
          print('[WebSocket] Kết nối thành công.');
          _isConnected = true;
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
          _stompClient = null; // Cho phép kết nối lại
        },
        onDisconnect: (frame) {
          print('[WebSocket] Đã ngắt kết nối.');
          _isConnected = false;
          _stompClient = null; // Cho phép kết nối lại
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
      if (_stompClient == null) {
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

  //Sửa hàm Disconnect
  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    _onConnectCallbacks.clear();
    print('[WebSocket] Đã ngắt kết nối (toàn bộ).');
  }
}