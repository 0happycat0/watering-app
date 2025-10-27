import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart'
    as device_state;

final deviceProvider =
    StateNotifierProvider.autoDispose<DeviceNotifier, device_state.DeviceState>(
      (ref) {
        final deviceRepository = ref.watch(deviceRepositoryProvider);

        return DeviceNotifier(deviceRepository);
      },
    );

// final deleteDeviceProvider =
//     StateNotifierProvider.autoDispose<
//       DeleteDeviceProvider,
//       device_state.DeviceState
//     >(
//       (ref) {
//         final deviceRepository = ref.watch(deviceRepositoryProvider);
//         return DeleteDeviceProvider(deviceRepository);
//       },
//     );

final toggleDeviceProvider = FutureProvider.autoDispose.family<void, Device>((ref, device) {
  final deviceRepository = ref.watch(deviceRepositoryProvider);
  return deviceRepository.toggleDevice(device: device);
});

class DeviceNotifier extends StateNotifier<device_state.DeviceState> {
  DeviceNotifier(this.deviceRepository) : super(device_state.Initial());

  final DeviceRepositoryImpl deviceRepository;

  Future<void> createDevice({
    required String name,
    required String deviceId,
  }) async {
    state = device_state.Loading();

    final response = await deviceRepository.createDevice(
      device: Device(name: name, deviceId: deviceId),
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (_) {
        return device_state.Success();
      },
    );
  }

  Future<void> updateDevice({
    required String id,
    required String name,
    required String deviceId,
  }) async {
    state = device_state.Loading();

    final response = await deviceRepository.updateDevice(
      device: Device(id: id, name: name, deviceId: deviceId),
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (_) {
        return device_state.Success();
      },
    );
  }

  Future<void> deleteDevice({required String id}) async {
    state = device_state.Loading();

    final response = await deviceRepository.deleteDevice(
      device: Device(id: id),
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (_) {
        return device_state.Success();
      },
    );
  }
}

class DeleteDeviceProvider extends StateNotifier<device_state.DeviceState> {
  DeleteDeviceProvider(this.deviceRepository) : super(device_state.Initial());

  final DeviceRepositoryImpl deviceRepository;
}
