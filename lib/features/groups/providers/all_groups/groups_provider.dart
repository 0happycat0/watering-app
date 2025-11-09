import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;
import 'package:watering_app/features/groups/domain/repository/group_repository_impl.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_provider.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_state.dart'
    as groups_state;

//get all groups
final groupsProvider =
    StateNotifierProvider.autoDispose<
      GroupsNotifier,
      groups_state.GroupsState
    >(
      (ref) {
        final groupRepository = ref.watch(groupRepositoryProvider);
        return GroupsNotifier(groupRepository);
      },
    );

class GroupsNotifier extends StateNotifier<groups_state.GroupsState> {
  GroupsNotifier(this.groupRepository) : super(groups_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> getAllGroups({
    String? name,
    int? page,
    int size = 100,
  }) async {
    state = groups_state.Loading();
    final response = await groupRepository.getAllGroups(
      name: name,
      page: page,
      size: size,
    );
    state = response.fold(
      (exception) {
        return groups_state.Failure(exception);
      },
      (groupsList) {
        return groups_state.Success(groupsList, searchQuery: name);
      },
    );
  }

  Future<void> refresh() async {
    await getAllGroups();
  }

  void setLoading() {
    state = groups_state.Loading();
  }
}

//--------------------------------------------------------------------------------------------------
//get free devices
final freeDevicesProvider =
    StateNotifierProvider.autoDispose<
      FreeDevicesNotifier,
      devices_state.DevicesState
    >(
      (ref) {
        final groupRepository = ref.watch(groupRepositoryProvider);
        return FreeDevicesNotifier(groupRepository);
      },
    );

class FreeDevicesNotifier extends StateNotifier<devices_state.DevicesState> {
  FreeDevicesNotifier(this.groupRepository) : super(devices_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> getAllGroups({
    String? name,
    int? page,
    int size = 100,
  }) async {
    state = devices_state.Loading();
    final response = await groupRepository.getFreeDevices(
      name: name,
      page: page,
      size: size,
    );
    state = response.fold(
      (exception) {
        return devices_state.Failure(exception);
      },
      (devicesList) {
        return devices_state.Success(devicesList);
      },
    );
  }
}
