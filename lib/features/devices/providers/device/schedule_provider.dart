import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;

//get schedule list & toggle schedule
//use same state to update UI immediately when toggle schedule
final getListScheduleProvider = StateNotifierProvider(
  (ref) => GetListScheduleNotifier(ref.watch(deviceRepositoryProvider)),
);

class GetListScheduleNotifier extends StateNotifier<device_state.DeviceState> {
  GetListScheduleNotifier(this.deviceRepository)
    : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> getListSchedule({required String id}) async {
    state = device_state.Loading();
    final response = await deviceRepository.getListSchedule(
      device: Device(id: id),
    );
    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (scheduleList) {
        return device_state.Success(listSchedule: scheduleList);
      },
    );
  }

  Future<bool> toggleSchedule({
    required String deviceId,
    required Schedule scheduleToToggle,
    required bool newStatus,
  }) async {
    // 1. Chỉ thực hiện nếu state hiện tại là Success
    if (state is! device_state.Success) return false;

    final originalState = state as device_state.Success;
    final currentList = originalState.listSchedule ?? [];

    final updatedSchedule = scheduleToToggle.copyWith(status: newStatus);

    final newList = currentList.map((schedule) {
      return schedule.id == scheduleToToggle.id ? updatedSchedule : schedule;
    }).toList();
    state = device_state.Success(listSchedule: newList);

    final response = await deviceRepository.toggleSchedule(
      device: Device(id: deviceId),
      schedule: updatedSchedule,
    );

    return response.fold(
      (exception) {
        print('Toggle thất bại, revert state: $exception');
        state = originalState; // Revert
        return false; // Trả về false để UI biết và hiển thị SnackBar
      },
      (success) {
        print('Toggle thành công');
        return true;
      },
    );
  }
}
