import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/features/devices/data/models/history_watering_model.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';

abstract class DeviceRepository {
  Future<Either<Exception, List<Device>>> getAllDevices();
  Future<Either<Exception, Response>> createDevice({required Device device});
  Future<Either<Exception, Response>> deleteDevice({required Device device});
  Future<Either<Exception, Response>> updateDevice({required Device device});
  Future<Either<Exception, Response>> toggleDevice({required Device device});
  Future<Either<Exception, List<HistoryWatering>>> getHistoryWatering({
    required Device device,
  });
  Future<Either<Exception, List<HistorySensor>>> getHistorySensor({
    required Device device,
    int? page,
    int? size,
    HistorySensorSortField? sortField,
    bool? isAscending,
  });
  Future<Either<Exception, List<Schedule>>> getListSchedule({
    required Device device,
    int? page,
    int? size,
  });
  Future<Either<Exception, Response>> toggleSchedule({
    required Device device,
    required Schedule schedule,
  });
}
