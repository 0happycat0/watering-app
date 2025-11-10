import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_impl.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_provider.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;

//get group by id
final groupByIdProvider =
    StateNotifierProvider.autoDispose<GroupNotifier, group_state.GroupState>(
      (ref) {
        final groupRepository = ref.watch(groupRepositoryProvider);
        return GroupNotifier(groupRepository);
      },
    );

class GroupNotifier extends StateNotifier<group_state.GroupState> {
  GroupNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> getGroupById({required String id}) async {
    state = group_state.Loading();
    final response = await groupRepository.getGroupById(id: id);
    state = response.fold(
      (exception) {
        return group_state.Failure(exception);
      },
      (group) {
        return group_state.Success(listDevices: group.listDevices);
      },
    );
  }
}

//--------------------------------------------------------------------------------------------------
//create group
final createGroupProvider =
    StateNotifierProvider.autoDispose<
      CreateGroupNotifier,
      group_state.GroupState
    >(
      (ref) => CreateGroupNotifier(ref.watch(groupRepositoryProvider)),
    );

class CreateGroupNotifier extends StateNotifier<group_state.GroupState> {
  CreateGroupNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> createGroup({
    required String name,
    required List<String> listIdOfDevices,
  }) async {
    state = group_state.Loading();
    final response = await groupRepository.createGroup(
      group: Group(name: name),
      listIdOfDevices: listIdOfDevices,
    );
    state = response.fold(
      (exception) {
        return group_state.Failure(exception);
      },
      (_) => group_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
//update group
final updateGroupProvider =
    StateNotifierProvider.autoDispose<
      UpdateGroupNotifier,
      group_state.GroupState
    >(
      (ref) => UpdateGroupNotifier(ref.watch(groupRepositoryProvider)),
    );

class UpdateGroupNotifier extends StateNotifier<group_state.GroupState> {
  UpdateGroupNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> updateGroup({
    required String id,
    required String name,
    required List<String> listIdOfDevices,
  }) async {
    state = group_state.Loading();
    final response = await groupRepository.updateGroup(
      group: Group(id: id, name: name),
      listIdOfDevices: listIdOfDevices,
    );
    state = response.fold(
      (exception) {
        return group_state.Failure(exception);
      },
      (_) => group_state.Success(),
    );
  }
}

//--------------------------------------------------------------------------------------------------
//delete group
final deleteGroupProvider =
    StateNotifierProvider.autoDispose<
      DeleteGroupNotifier,
      group_state.GroupState
    >(
      (ref) => DeleteGroupNotifier(ref.watch(groupRepositoryProvider)),
    );

class DeleteGroupNotifier extends StateNotifier<group_state.GroupState> {
  DeleteGroupNotifier(this.groupRepository) : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> deleteGroup({required String id}) async {
    state = group_state.Loading();
    final response = await groupRepository.deleteGroup(group: Group(id: id));
    state = response.fold(
      (exception) {
        return group_state.Failure(exception);
      },
      (_) {
        return group_state.Success();
      },
    );
  }
}

//toggle group (true: đang bơm, false: không bơm)
final toggleGroupProvider = StateNotifierProvider<ToggleGroupNotifier, bool>(
  (ref) => ToggleGroupNotifier(ref.watch(groupRepositoryProvider)),
);

class ToggleGroupNotifier extends StateNotifier<bool> {
  ToggleGroupNotifier(this.groupRepository) : super(false);
  final GroupRepositoryImpl groupRepository;

  Future<bool> toggleGroup({
    required Group group,
  }) async {
    final originalState = state;

    if (group.action == 'START') {
      state = true;
    } else if (group.action == 'STOP') {
      state = false;
    }

    final response = await groupRepository.toggleGroup(
      group: group,
    );

    return response.fold(
      (exception) {
        state = originalState;
        return false;
      },
      (_) {
        return true;
      },
    );
  }
}
