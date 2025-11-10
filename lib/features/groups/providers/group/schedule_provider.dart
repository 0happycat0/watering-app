import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_impl.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;

// Get schedule list & toggle schedule
// Use same state to update UI immediately when toggle schedule
final getGroupListScheduleProvider = StateNotifierProvider(
  (ref) => GetGroupListScheduleNotifier(ref.watch(groupRepositoryProvider)),
);

class GetGroupListScheduleNotifier extends StateNotifier<group_state.GroupState> {
  GetGroupListScheduleNotifier(this.groupRepository)
    : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> getListSchedule({required String id}) async {
    state = group_state.Loading();
    final response = await groupRepository.getListSchedule(
      group: Group(id: id),
    );
    state = response.fold(
      (exception) {
        return group_state.Failure(exception);
      },
      (scheduleList) {
        return group_state.Success(listSchedule: scheduleList);
      },
    );
  }

  Future<bool> toggleSchedule({
    required String id,
    required Schedule scheduleToToggle,
    required bool newStatus,
  }) async {
    // Chỉ thực hiện nếu state hiện tại là Success
    if (state is! group_state.Success) return false;

    final originalState = state as group_state.Success;
    final currentList = originalState.listSchedule ?? [];

    final updatedSchedule = scheduleToToggle.copyWith(status: newStatus);

    final newList = currentList.map((schedule) {
      return schedule.id == scheduleToToggle.id ? updatedSchedule : schedule;
    }).toList();
    state = group_state.Success(listSchedule: newList);

    final response = await groupRepository.toggleSchedule(
      group: Group(id: id),
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
    state = group_state.Loading();
  }
}

//--------------------------------------------------------------------------------------------------
// Create schedule
final createGroupScheduleProvider =
    StateNotifierProvider.autoDispose<
      CreateGroupScheduleNotifier,
      group_state.GroupState
    >(
      (ref) => CreateGroupScheduleNotifier(ref.watch(groupRepositoryProvider)),
    );

class CreateGroupScheduleNotifier extends StateNotifier<group_state.GroupState> {
  CreateGroupScheduleNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> createSchedule({
    required String id,
    required String startTime,
    required int duration,
    required RepeatType repeatType,
    List<DaysOfWeek>? daysOfWeek,
  }) async {
    state = group_state.Loading();
    final response = await groupRepository.createSchedule(
      group: Group(id: id),
      schedule: Schedule(
        startTime: startTime,
        duration: duration,
        repeatType: repeatType,
        daysOfWeek: daysOfWeek,
      ),
    );
    state = response.fold(
      (exception) => group_state.Failure(exception),
      (_) => group_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
// Update schedule
final updateGroupScheduleProvider =
    StateNotifierProvider.autoDispose<
      UpdateGroupScheduleNotifier,
      group_state.GroupState
    >(
      (ref) => UpdateGroupScheduleNotifier(ref.watch(groupRepositoryProvider)),
    );

class UpdateGroupScheduleNotifier extends StateNotifier<group_state.GroupState> {
  UpdateGroupScheduleNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> updateSchedule({
    required String id,
    required String scheduleId,
    required String startTime,
    required int duration,
    required RepeatType repeatType,
    List<DaysOfWeek>? daysOfWeek,
  }) async {
    state = group_state.Loading();
    final response = await groupRepository.updateSchedule(
      group: Group(id: id),
      schedule: Schedule(
        id: scheduleId,
        startTime: startTime,
        duration: duration,
        repeatType: repeatType,
        daysOfWeek: daysOfWeek,
      ),
    );
    state = response.fold(
      (exception) => group_state.Failure(exception),
      (_) => group_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
// Delete schedule
final deleteGroupScheduleProvider =
    StateNotifierProvider.autoDispose<
      DeleteGroupScheduleNotifier,
      group_state.GroupState
    >(
      (ref) => DeleteGroupScheduleNotifier(ref.watch(groupRepositoryProvider)),
    );

class DeleteGroupScheduleNotifier extends StateNotifier<group_state.GroupState> {
  DeleteGroupScheduleNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> deleteSchedule({
    required String id,
    required String scheduleId,
  }) async {
    state = group_state.Loading();
    final response = await groupRepository.deleteSchedule(
      group: Group(id: id),
      schedule: Schedule(id: scheduleId),
    );
    state = response.fold(
      (exception) => group_state.Failure(exception),
      (_) => group_state.Success(),
    );
  }
}

