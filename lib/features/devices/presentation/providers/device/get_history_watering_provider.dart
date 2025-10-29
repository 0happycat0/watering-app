import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart'
    as device_state;

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
