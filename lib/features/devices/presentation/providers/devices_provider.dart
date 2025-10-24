import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/devices_state.dart'
    as devices_state;

final devicesProvider =
    StateNotifierProvider.autoDispose<DevicesNotifier, devices_state.DevicesState>(
      (ref) {
        final deviceRepository = ref.watch(deviceRepositoryProvider);
        return DevicesNotifier(deviceRepository);
      },
    );

class DevicesNotifier extends StateNotifier<devices_state.DevicesState> {
  DevicesNotifier(this.deviceRepository) : super(devices_state.Initial()) {
    getAllDevices();
  }
  final DeviceRepositoryImpl deviceRepository;

  Future<void> getAllDevices() async {
    state = devices_state.Loading();
    final response = await deviceRepository.getAllDevices();
    state = response.fold(
      (exception) {
        return devices_state.Failure(exception);
      },
      (devicesList) {
        return devices_state.Success(devicesList);
      },
    );
  }

  Future<void> refresh() async {
    await getAllDevices();
  }

  void setLoading() {
    state = devices_state.Loading();
  }
}
