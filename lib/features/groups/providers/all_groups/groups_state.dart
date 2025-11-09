import 'package:dio/dio.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';

sealed class GroupsState {
  const GroupsState();
}

class Initial extends GroupsState {
  const Initial();
}

class Loading extends GroupsState {
  const Loading();
}

class Success extends GroupsState {
  Success(this.groupsList, {this.searchQuery});

  final List<Group> groupsList;
  final String? searchQuery;

  //biến để kiểm tra danh sách trống do tìm kiếm hay do chưa có nhóm
  bool get isEmpty => groupsList.isEmpty;
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;
  bool get isSearchResultEmpty => isSearching && isEmpty;
  bool get isNoGroups => !isSearching && isEmpty;
}

class Failure extends GroupsState {
  const Failure(this.exception);
  final DioException exception;
  String get message {
    switch (exception.message) {
      case 'Internal Server Error':
        return 'Lỗi máy chủ. Vui lòng thử lại';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}

