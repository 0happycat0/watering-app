import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

sealed class DevicesState {
  const DevicesState();
}

class Initial extends DevicesState {
  const Initial();
}

class Loading extends DevicesState {
  const Loading();
}

class Success extends DevicesState {
  Success(this.devicesList, {this.searchQuery});

  final List<Device> devicesList;
  final String? searchQuery;

  //biến để kiểm tra danh sách trống do tìm kiếm hay do chưa có thiết bị
  bool get isEmpty => devicesList.isEmpty;
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;
  bool get isSearchResultEmpty => isSearching && isEmpty;
  bool get isNoDevices => !isSearching && isEmpty;
}

class Failure extends DevicesState {
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
