import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/features/devices/data/models/history_watering_model.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/data/source/device_remote.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository.dart';

class DeviceRepositoryImpl extends DeviceRepository {
  DeviceRemoteDataSource deviceRemoteDataSource;

  DeviceRepositoryImpl(this.deviceRemoteDataSource);

  @override
  Future<Either<DioException, List<Device>>> getAllDevices({
    String? name,
    int? page,
    int? size,
    AllDevicesSortField? sortField,
    bool? isAscending,
  }) async {
    final response = await deviceRemoteDataSource.getAllDevices(
      name: name,
      page: page,
      size: size,
      sortField: sortField,
      isAscending: isAscending,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listDevices) {
        return Right(listDevices);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> createDevice({
    required Device device,
  }) async {
    final response = await deviceRemoteDataSource.createDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> deleteDevice({
    required Device device,
  }) async {
    final response = await deviceRemoteDataSource.deleteDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> updateDevice({
    required Device device,
  }) async {
    final response = await deviceRemoteDataSource.updateDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> toggleDevice({
    required Device device,
  }) async {
    final response = await deviceRemoteDataSource.toggleDevice(device: device);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, List<HistoryWatering>>> getHistoryWatering({
    required Device device,
  }) async {
    final response = await deviceRemoteDataSource.getHistoryWatering(
      device: device,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listHistory) {
        return Right(listHistory);
      },
    );
  }

  @override
  Future<Either<DioException, List<HistorySensor>>> getHistorySensor({
    required Device device,
    int? page,
    int? size,
    HistorySensorSortField? sortField,
    bool? isAscending,
  }) async {
    final response = await deviceRemoteDataSource.getHistorySensor(
      device: device,
      page: page,
      size: size,
      sortField: sortField,
      isAscending: isAscending,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listHistory) {
        return Right(listHistory);
      },
    );
  }

  @override
  Future<Either<DioException, List<Schedule>>> getListSchedule({
    required Device device,
    int? page,
    int? size,
  }) async {
    final response = await deviceRemoteDataSource.getListSchedule(
      device: device,
      page: page,
      size: size,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listSchedule) {
        return Right(listSchedule);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> toggleSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    final response = await deviceRemoteDataSource.toggleSchedule(
      device: device,
      schedule: schedule,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> createSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    final response = await deviceRemoteDataSource.createSchedule(
      device: device,
      schedule: schedule,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> updateSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    final response = await deviceRemoteDataSource.updateSchedule(
      device: device,
      schedule: schedule,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> deleteSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    final response = await deviceRemoteDataSource.deleteSchedule(
      device: device,
      schedule: schedule,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }
}
