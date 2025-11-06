import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/stomp_path.dart';
import 'package:watering_app/core/utils/stomp_service.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';

typedef DevicesSensorState = Map<String, HistorySensor>;
typedef DevicesStatusState = Map<String, bool>;
typedef DevicesWateringState = Map<String, bool>;

// sensor
final devicesSensorProvider =
    StateNotifierProvider.autoDispose<
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
    try {
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
    } catch (e) {
      print('DevicesSensorNotifier Lỗi subscribe: $e');
    }
  }

  @override
  void dispose() {
    print(
      '[DevicesSensorNotifier] Đang hủy. Đang unsubscribe /user/devices/sensor...',
    );
    _unsubscribe!();
    super.dispose();
  }
}

//--------------------------------------------------------------------------------------------------
// status (true: online, fasle: offline)

final devicesStatusProvider =
    StateNotifierProvider.autoDispose<
      DevicesStatusNotifier,
      DevicesStatusState
    >(
      (ref) {
        return DevicesStatusNotifier();
      },
    );

class DevicesStatusNotifier extends StateNotifier<DevicesStatusState> {
  StompUnsubscribeTopic? _unsubscribe;

  DevicesStatusNotifier() : super({}) {
    _subscribe();
  }

  void _subscribe() {
    _unsubscribe = StompService().subscribe(
      StompPath.topic.devicesStatus,
      onMessage: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!);
          final String deviceId = data['deviceId'];
          final bool isOnline = data['isOnline'];

          if (deviceId.isEmpty) return;

          state = {
            ...state,
            deviceId: isOnline,
          };
        } catch (e) {
          print('[DevicesStatusNotifier] Lỗi parse JSON: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    print(
      '[DevicesStatusNotifier] Đang hủy. Đang unsubscribe /user/devices/status...',
    );
    _unsubscribe!();
    super.dispose();
  }
}

//--------------------------------------------------------------------------------------------------
// watering (true: watering, fasle: not watering)
final devicesWateringProvider =
    StateNotifierProvider.autoDispose<
      DevicesWateringNotifier,
      DevicesWateringState
    >(
      (ref) {
        return DevicesWateringNotifier();
      },
    );

class DevicesWateringNotifier extends StateNotifier<DevicesWateringState> {
  StompUnsubscribeTopic? _unsubscribe;

  DevicesWateringNotifier() : super({}) {
    _subscribe();
  }

  void _subscribe() {
    _unsubscribe = StompService().subscribe(
      StompPath.topic.devicesWatering,
      onMessage: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!);
          final String deviceId = data['deviceId'];
          final bool isWatering = data['isWatering'];

          if (deviceId.isEmpty) return;

          state = {
            ...state,
            deviceId: isWatering,
          };
        } catch (e) {
          print('[DevicesWateringNotifier] Lỗi parse JSON: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    print(
      '[DevicesWateringNotifier] Đang hủy. Đang unsubscribe /user/devices/watering...',
    );
    _unsubscribe!();
    super.dispose();
  }
}
