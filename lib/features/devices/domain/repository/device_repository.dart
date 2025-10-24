import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

abstract class DeviceRepository {
  Future<Either<Exception, List<Device>>> getAllDevices();
  Future<Either<Exception, Response>> createDevice({required Device device});
  Future<Either<Exception, Response>> deleteDevice({required Device device});
}
