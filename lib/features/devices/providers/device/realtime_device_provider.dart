import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/core/constants/stomp_path.dart';
import 'package:watering_app/core/utils/stomp_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';

//tự động subscribe khi được watch và unsubscribe khi bị dispose.
final deviceSensorProvider = StateNotifierProvider.autoDispose
    .family<DeviceSensorNotifier, HistorySensor?, String>(
  (ref, deviceId) {
    return DeviceSensorNotifier(deviceId);
  },
);

class DeviceSensorNotifier extends StateNotifier<HistorySensor?> {
  final String deviceId;
  StompUnsubscribeTopic? _unsubscribe; // Hàm để hủy subscribe

  DeviceSensorNotifier(this.deviceId) : super(null) {
    _subscribe();
  }

  void _subscribe() {
    StompService().connect();

    _unsubscribe = StompService().subscribe(
      StompPath.topic.deviceSensor(deviceId),
      onMessage: (StompFrame frame) {
        print('bắt đầu try');
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            state = HistorySensor.fromJson(data);
            print('realtime state: $state');
          } catch (e) {
            print('[DeviceSensorNotifier] Lỗi parse JSON: $e');
          }
        }
      },
    );
  }

  @override
  void dispose() {
    print('[DeviceSensorNotifier] Disposing. Unsubscribing $deviceId...');
    _unsubscribe!();
    super.dispose();
  }
}