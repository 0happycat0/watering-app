import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/stomp_path.dart';
import 'package:watering_app/core/network/stomp_service.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';
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
        final stompService = ref.watch(stompServiceProvider);
        if (stompService == null) {
          throw Exception('StompService is null');
        }
        return DevicesSensorNotifier(stompService);
      },
    );

class DevicesSensorNotifier extends StateNotifier<DevicesSensorState> {
  StompUnsubscribeTopic? _unsubscribe;
  StompService stompService;

  DevicesSensorNotifier(this.stompService) : super({}) {
    _subscribe();
  }

  void _subscribe() {
    try {
      _unsubscribe = stompService.subscribe(
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
        final stompService = ref.watch(stompServiceProvider);
        if (stompService == null) {
          throw Exception('StompService is null');
        }
        return DevicesStatusNotifier(stompService);
      },
    );

class DevicesStatusNotifier extends StateNotifier<DevicesStatusState> {
  StompUnsubscribeTopic? _unsubscribe;
  StompService stompService;

  DevicesStatusNotifier(this.stompService) : super({}) {
    _subscribe();
  }

  void _subscribe() {
    _unsubscribe = stompService.subscribe(
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
        final stompService = ref.watch(stompServiceProvider);
        if (stompService == null) {
          throw Exception('StompService is null');
        }
        return DevicesWateringNotifier(stompService);
      },
    );

class DevicesWateringNotifier extends StateNotifier<DevicesWateringState> {
  StompUnsubscribeTopic? _unsubscribe;
  StompService stompService;

  DevicesWateringNotifier(this.stompService) : super({}) {
    _subscribe();
  }

  void _subscribe() {
    _unsubscribe = stompService.subscribe(
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
