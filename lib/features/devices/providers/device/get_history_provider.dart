import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;

//sensor
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

//--------------------------------------------------------------------------------------------------
//watering
final getHistoryWateringProvider =
    StateNotifierProvider.autoDispose<
      GetHistoryWateringNotifier,
      device_state.DeviceState
    >(
      (ref) => GetHistoryWateringNotifier(ref.watch(deviceRepositoryProvider)),
    );

class GetHistoryWateringNotifier
    extends StateNotifier<device_state.DeviceState> {
  GetHistoryWateringNotifier(this.deviceRepository)
    : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;
  
  Future<void> getHistoryWatering({required String id}) async {
    state = device_state.Loading();

    final response = await deviceRepository.getHistoryWatering(
      device: Device(id: id),
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (listHistoryWatering) {
        return device_state.Success(listHistoryWatering: listHistoryWatering);
      },
    );
  }

  Future<void> refresh({required String id}) {
    return getHistoryWatering(id: id);
  }
}
