import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart' as device_state;

final deleteDeviceProvider =
    StateNotifierProvider.autoDispose<DeleteDeviceNotifier, device_state.DeviceState>(
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