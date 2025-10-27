import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart' as device_state;

final updateDeviceProvider =
    StateNotifierProvider.autoDispose<UpdateDeviceNotifier, device_state.DeviceState>(
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