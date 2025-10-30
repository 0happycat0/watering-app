import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart'
    as device_state;

final getHistorySensorProvider =
    StateNotifierProvider.autoDispose<
      GetHistorySensorNotifier,
      device_state.DeviceState
    >(
      (ref) => GetHistorySensorNotifier(ref.watch(deviceRepositoryProvider)),
    );

class GetHistorySensorNotifier extends StateNotifier<device_state.DeviceState> {
  GetHistorySensorNotifier(this.deviceRepository)
    : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> getHistorySensor({
    required String id,
    int? page,
    int? size,
    HistorySensorSortField? sortField,
    bool? isAscending,
  }) async {
    state = device_state.Loading();

    final response = await deviceRepository.getHistorySensor(
      device: Device(id: id),
      page: page,
      size: size,
      sortField: sortField,
      isAscending: isAscending,
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (listHistorySensor) {
        return device_state.Success(listHistorySensor: listHistorySensor);
      },
    );
  }

  Future<void> refresh({required String id}) {
    return getHistorySensor(id: id);
  }
}
