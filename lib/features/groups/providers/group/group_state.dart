import 'package:dio/dio.dart';
import 'package:watering_app/core/data/models/history_watering_model.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
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
  Success({this.listDevices, this.listHistoryWatering, this.listSchedule});
  final List<Device>? listDevices;
  final List<HistoryWatering>? listHistoryWatering;
  final List<Schedule>? listSchedule;
}

class Failure extends GroupState {
  const Failure(this.exception);
  final DioException exception;
  String get message {
    switch (exception.message) {
      case 'Internal Server Error':
        return 'Lỗi máy chủ. Vui lòng thử lại';
      case 'Group has been existed':
        return 'Tên nhóm đã tồn tại. Hãy chọn tên khác';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}
