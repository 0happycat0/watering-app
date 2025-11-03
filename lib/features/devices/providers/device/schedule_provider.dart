import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/enums/schedule_enums.dart';
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
    required String id,
    required Schedule scheduleToToggle,
    required bool newStatus,
  }) async {
    //Chỉ thực hiện nếu state hiện tại là Success
    if (state is! device_state.Success) return false;

    final originalState = state as device_state.Success;
    final currentList = originalState.listSchedule ?? [];

    final updatedSchedule = scheduleToToggle.copyWith(status: newStatus);

    final newList = currentList.map((schedule) {
      return schedule.id == scheduleToToggle.id ? updatedSchedule : schedule;
    }).toList();
    state = device_state.Success(listSchedule: newList);

    final response = await deviceRepository.toggleSchedule(
      device: Device(id: id),
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

  Future<void> refresh({required String id}) async {
    await getListSchedule(id: id);
  }

  void setLoading() {
    state = device_state.Loading();
  }
}

//--------------------------------------------------------------------------------------------------
//create schedule
final createScheduleProvider =
    StateNotifierProvider.autoDispose<
      CreateScheduleNotifier,
      device_state.DeviceState
    >(
      (ref) => CreateScheduleNotifier(ref.watch(deviceRepositoryProvider)),
    );

class CreateScheduleNotifier extends StateNotifier<device_state.DeviceState> {
  CreateScheduleNotifier(this.deviceRepository) : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> createSchedule({
    required String id,
    required String startTime,
    required int duration,
    required RepeatType repeatType,
    List<DaysOfWeek>? daysOfWeek,
  }) async {
    state = device_state.Loading();
    final response = await deviceRepository.createSchedule(
      device: Device(id: id),
      schedule: Schedule(
        startTime: startTime,
        duration: duration,
        repeatType: repeatType,
        daysOfWeek: daysOfWeek,
      ),
    );
    state = response.fold(
      (exception) => device_state.Failure(exception),
      (_) => device_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
//update schedule
final updateScheduleProvider =
    StateNotifierProvider.autoDispose<
      UpdateScheduleNotifier,
      device_state.DeviceState
    >(
      (ref) => UpdateScheduleNotifier(ref.watch(deviceRepositoryProvider)),
    );

class UpdateScheduleNotifier extends StateNotifier<device_state.DeviceState> {
  UpdateScheduleNotifier(this.deviceRepository) : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> updateSchedule({
    required String id,
    required String scheduleId,
    required String startTime,
    required int duration,
    required RepeatType repeatType,
    List<DaysOfWeek>? daysOfWeek,
  }) async {
    state = device_state.Loading();
    final response = await deviceRepository.updateSchedule(
      device: Device(id: id),
      schedule: Schedule(
        id: scheduleId,
        startTime: startTime,
        duration: duration,
        repeatType: repeatType,
        daysOfWeek: daysOfWeek,
      ),
    );
    state = response.fold(
      (exception) => device_state.Failure(exception),
      (_) => device_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
//delete schedule
final deleteScheduleProvider =
    StateNotifierProvider.autoDispose<
      DeleteScheduleNotifier,
      device_state.DeviceState
    >(
      (ref) => DeleteScheduleNotifier(ref.watch(deviceRepositoryProvider)),
    );

class DeleteScheduleNotifier extends StateNotifier<device_state.DeviceState> {
  DeleteScheduleNotifier(this.deviceRepository) : super(device_state.Initial());
  final DeviceRepositoryImpl deviceRepository;

  Future<void> deleteSchedule({
    required String id,
    required String scheduleId,
  }) async {
    state = device_state.Loading();
    final response = await deviceRepository.deleteSchedule(
      device: Device(id: id),
      schedule: Schedule(id: scheduleId),
    );
    state = response.fold(
      (exception) => device_state.Failure(exception),
      (_) => device_state.Success(),
    );
  }
}
