import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;

final devicesProvider =
    StateNotifierProvider.autoDispose<
      DevicesNotifier,
      devices_state.DevicesState
    >(
      (ref) {
        final deviceRepository = ref.watch(deviceRepositoryProvider);
        return DevicesNotifier(deviceRepository);
      },
    );

class DevicesNotifier extends StateNotifier<devices_state.DevicesState> {
  DevicesNotifier(this.deviceRepository) : super(devices_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> getAllDevices({
    String? name,
    int? page,
    int size = 100,
    AllDevicesSortField? sortField,
    bool? isAscending,
  }) async {
    state = devices_state.Loading();
    final response = await deviceRepository.getAllDevices(
      name: name,
      page: page,
      size: size,
      sortField: sortField,
      isAscending: isAscending,
    );
    state = response.fold(
      (exception) {
        return devices_state.Failure(exception);
      },
      (devicesList) {
        return devices_state.Success(devicesList, searchQuery: name);
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

final shouldResetSortAndSearchProvider = StateProvider<bool>(
  (ref) => false,
);
