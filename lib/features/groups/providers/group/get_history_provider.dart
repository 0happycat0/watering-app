import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_impl.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;

final getGroupHistoryWateringProvider =
    StateNotifierProvider.autoDispose<
      GetGroupHistoryWateringNotifier,
      group_state.GroupState
    >(
      (ref) =>
          GetGroupHistoryWateringNotifier(ref.watch(groupRepositoryProvider)),
    );

class GetGroupHistoryWateringNotifier
    extends StateNotifier<group_state.GroupState> {
  GetGroupHistoryWateringNotifier(this.groupRepository)
    : super(group_state.Initial());
  final GroupRepositoryImpl groupRepository;

  Future<void> getHistoryWatering({
    required String id,
    int? page,
    int? size = 100,
  }) async {
    state = group_state.Loading();

    final response = await groupRepository.getHistoryWatering(
      group: Group(id: id),
    );

    state = response.fold(
      (exception) {
        return group_state.Failure(exception);
      },
      (listHistoryWatering) {
        return group_state.Success(listHistoryWatering: listHistoryWatering);
      },
    );
  }

  Future<void> refresh({required String id}) {
    return getHistoryWatering(id: id);
  }
}
