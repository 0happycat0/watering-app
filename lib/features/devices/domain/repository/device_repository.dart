import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_watering_model.dart';

abstract class DeviceRepository {
  Future<Either<Exception, List<Device>>> getAllDevices();
  Future<Either<Exception, Response>> createDevice({required Device device});
  Future<Either<Exception, Response>> deleteDevice({required Device device});
  Future<Either<Exception, Response>> updateDevice({required Device device});
  Future<Either<Exception, Response>> toggleDevice({required Device device});
  Future<Either<Exception, List<HistoryWatering>>> getHistoryWatering({required Device device});

}
