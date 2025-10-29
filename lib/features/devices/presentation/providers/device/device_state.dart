import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/history_watering_model.dart';

sealed class DeviceState {
  const DeviceState();
}

class Initial extends DeviceState {
  const Initial();
}

class Loading extends DeviceState {
  const Loading();
}

class Success extends DeviceState {
  const Success({this.listHistoryWatering});
  final List<HistoryWatering>? listHistoryWatering;
}

class Failure extends DeviceState {
  const Failure(this.exception);
  final DioException exception;

  String get message {
    final serverMessage = exception.message;

    switch (serverMessage) {
      case 'Device has been existed':
        return 'Thiết bị này đã tồn tại';
      case 'Invalid device ID format':
        return 'Mã thiết bị không hợp lệ';
      case 'Internal Server Error':
        return 'Lỗi máy chủ. Vui lòng thử lại';
      default:
        return 'Không thể thêm thiết bị, vui lòng thử lại';
    }
  }
}
