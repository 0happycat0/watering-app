import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart' as device_state;

final createDeviceProvider =
    StateNotifierProvider.autoDispose<CreateDeviceNotifier, device_state.DeviceState>(
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
    state = response.fold(
      (exception) => device_state.Failure(exception),
      (_) => device_state.Success(),
    );
  }
}