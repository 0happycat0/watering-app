import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

class DeviceRemoteDataSource {
  final DioNetworkService networkService;

  DeviceRemoteDataSource(this.networkService);

  Future<Either<DioException, List<Device>>> getAllDevices() async {
    print('fetching device data...');
    try {
      final result = await networkService.get(
        endpoint: ApiPath.device.allDevice,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final List<dynamic> listData = response.data;
          final List<Device> listDevice = listData
              .map((deviceJson) => Device.fromJson(deviceJson))
              .toList();
          return Right(listDevice);
        },
      );
    } catch (e) {
      print('Loi khac (getAllDevices) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> createDevice({
    required Device device,
  }) async {
    try {
      final result = await networkService.post(
        endpoint: ApiPath.device.allDevice,
        data: device.toJson(),
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          return Right(response);
        },
      );
    } catch (e) {
      print('Loi khac (createDevice) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> deleteDevice({
    required Device device,
  }) async {
    try {
      final result = await networkService.delete(
        endpoint: ApiPath.device.deviceById(device.id),
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          return Right(response);
        },
      );
    } catch (e) {
      print('Loi khac (deleteDevice) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> updateDevice({
    required Device device,
  }) async {
    try {
      final result = await networkService.put(
        endpoint: ApiPath.device.deviceById(device.id),
        data: device.toJson()
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          return Right(response);
        },
      );
    } catch (e) {
      print('Loi khac (updateDevice) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }
}
