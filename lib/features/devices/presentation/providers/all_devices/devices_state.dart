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
  const Success(this.devicesList);
  final List<Device> devicesList;
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
