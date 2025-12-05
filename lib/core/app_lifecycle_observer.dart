import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';
import 'package:watering_app/core/utils/debug_print.dart';

class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Đăng ký observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Hủy đăng ký observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // KHI APP ĐƯỢC MỞ LẠI
        printDebug(
          '[AppLifecycle] App resumed, ensuring STOMP is connected...',
        );
        _triggerConnect();
        break;
      case AppLifecycleState.inactive:
        // App sắp bị pause (ví dụ có cuộc gọi đến)
        break;
      case AppLifecycleState.paused:
        // APP BỊ ĐƯA XUỐNG NỀN
        printDebug('[AppLifecycle] App paused');
        // Cứ để kết nối tự ngắt và logic _scheduleReconnect xử lý
        break;
      case AppLifecycleState.detached:
        // Widget bị hủy
        break;
      case AppLifecycleState.hidden:
        // Tương tự paused
        break;
    }
  }

  void _triggerConnect() {
    final stompService = ref.read(stompServiceProvider);

    // Nếu người dùng đã đăng nhập (service != null)
    if (stompService != null) {
      // Kích hoạt kết nối
      stompService.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
