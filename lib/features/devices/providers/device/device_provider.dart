import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;

//create device
final createDeviceProvider =
    StateNotifierProvider.autoDispose<
      CreateDeviceNotifier,
      device_state.DeviceState
    >(
      (ref) => CreateDeviceNotifier(ref.watch(deviceRepositoryProvider)),
    );

class CreateDeviceNotifier extends StateNotifier<device_state.DeviceState> {
  CreateDeviceNotifier(this.deviceRepository) : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> createDevice({
    required String name,
    required String deviceId,
  }) async {
    state = device_state.Loading();
    final response = await deviceRepository.createDevice(
      device: Device(name: name, deviceId: deviceId),
    );
    if (!mounted) return;
    state = response.fold(
      (exception) => device_state.Failure(exception),
      (_) => device_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
//update device
final updateDeviceProvider =
    StateNotifierProvider.autoDispose<
      UpdateDeviceNotifier,
      device_state.DeviceState
    >(
      (ref) => UpdateDeviceNotifier(ref.watch(deviceRepositoryProvider)),
    );

class UpdateDeviceNotifier extends StateNotifier<device_state.DeviceState> {
  UpdateDeviceNotifier(this.deviceRepository) : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> updateDevice({
    required String id,
    required String name,
    required String deviceId,
  }) async {
    state = device_state.Loading();

    final response = await deviceRepository.updateDevice(
      device: Device(id: id, name: name, deviceId: deviceId),
    );
    if (!mounted) return;
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

//--------------------------------------------------------------------------------------------------
//delete device
final deleteDeviceProvider =
    StateNotifierProvider.autoDispose<
      DeleteDeviceNotifier,
      device_state.DeviceState
    >(
      (ref) => DeleteDeviceNotifier(ref.watch(deviceRepositoryProvider)),
    );

class DeleteDeviceNotifier extends StateNotifier<device_state.DeviceState> {
  DeleteDeviceNotifier(this.deviceRepository) : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> deleteDevice({required String id}) async {
    state = device_state.Loading();

    final response = await deviceRepository.deleteDevice(
      device: Device(id: id),
    );
    if (!mounted) return;
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

//--------------------------------------------------------------------------------------------------
//toggle device (true: đang bơm, false: không bơm)
final toggleDeviceProvider = StateNotifierProvider<ToggleDeviceNotifier, bool>(
  (ref) => ToggleDeviceNotifier(ref.watch(deviceRepositoryProvider)),
);

class ToggleDeviceNotifier extends StateNotifier<bool> {
  ToggleDeviceNotifier(this.deviceRepository) : super(false);
  final DeviceRepositoryImpl deviceRepository;

  Future<bool> toggleDevice({
    required Device device,
  }) async {
    final originalState = state;

    if (device.action == 'START') {
      state = true;
    } else if (device.action == 'STOP') {
      state = false;
    }

    final response = await deviceRepository.toggleDevice(
      device: device,
    );

    return response.fold(
      (exception) {
        state = originalState;
        return false;
      },
      (_) {
        return true;
      },
    );
  }
}
