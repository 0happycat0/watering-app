import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/stomp_path.dart';
import 'package:watering_app/core/utils/stomp_service.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';

typedef DevicesSensorState = Map<String, HistorySensor>;

final devicesSensorProvider = StateNotifierProvider.autoDispose<
    DevicesSensorNotifier, 
    DevicesSensorState
>(
  (ref) {
    return DevicesSensorNotifier();
  },
);

class DevicesSensorNotifier extends StateNotifier<DevicesSensorState> {
  StompUnsubscribeTopic? _unsubscribe;

  DevicesSensorNotifier() : super({}) {
    _subscribe();
  }

  void _subscribe() {
    StompService().connect();

    _unsubscribe = StompService().subscribe(
      StompPath.topic.devicesSensor, 
      onMessage: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!);
          
          final String deviceId = data['deviceId'];
          final HistorySensor sensorData = HistorySensor.fromJson(data);

          if (deviceId.isEmpty) return;

          state = {
            ...state,
            deviceId: sensorData,
          };

        } catch (e) {
          print('[DevicesSensorNotifier] Lỗi parse JSON: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    print('[DevicesSensorNotifier] Đang hủy. Đang unsubscribe /user/devices/sensor...');
    _unsubscribe!();
    super.dispose();
  }
}