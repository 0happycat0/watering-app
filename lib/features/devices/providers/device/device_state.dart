import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/core/data/models/history_watering_model.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';

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
  const Success({
    this.listHistoryWatering,
    this.listHistorySensor,
    this.listSchedule,
  });
  final List<HistoryWatering>? listHistoryWatering;
  final List<HistorySensor>? listHistorySensor;
  final List<Schedule>? listSchedule;
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
        return 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }
}
