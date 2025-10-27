import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/source/device_remote.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository.dart';

class DeviceRepositoryImpl extends DeviceRepository{
  DeviceRemoteDataSource deviceRemoteDataSource;

  DeviceRepositoryImpl(this.deviceRemoteDataSource);

  @override
  Future<Either<DioException, List<Device>>> getAllDevices() async {
    final response = await deviceRemoteDataSource.getAllDevices();
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listDevices) {
        return Right(listDevices);
      }
    );
  }
  
  @override
  Future<Either<DioException, Response>> createDevice({required Device device}) async {
    final response = await deviceRemoteDataSource.createDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      }
    );
  }

  @override
  Future<Either<DioException, Response>> deleteDevice({required Device device}) async {
    final response = await deviceRemoteDataSource.deleteDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      }
    );
  }

  @override
  Future<Either<DioException, Response>> updateDevice({required Device device}) async {
    final response = await deviceRemoteDataSource.updateDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      }
    );
  }

  @override
  Future<Either<DioException, Response>> toggleDevice({required Device device}) async {
    final response = await deviceRemoteDataSource.toggleDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      }
    );
  }
}