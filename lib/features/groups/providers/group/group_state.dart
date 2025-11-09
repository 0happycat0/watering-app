import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

sealed class GroupState {
  const GroupState();
}

class Initial extends GroupState {
  const Initial();
}

class Loading extends GroupState {
  const Loading();
}

class Success extends GroupState {
  Success({this.listDevices});
  final List<Device>? listDevices;
}

class Failure extends GroupState {
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

