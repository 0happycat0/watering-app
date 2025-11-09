import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/api_strings.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/features/devices/data/models/history_watering_model.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';

class DeviceRemoteDataSource {
  final DioNetworkService networkService;

  DeviceRemoteDataSource(this.networkService);

  Future<Either<DioException, List<Device>>> getAllDevices({
    String? name,
    int? page,
    int? size,
    AllDevicesSortField? sortField,
    bool? isAscending,
  }) async {
    print('fetching device data...');
    try {
      final queryParameters = <String, dynamic>{};
      if (name != null) {
        queryParameters[ApiStrings.name] = name;
      }
      if (page != null) {
        queryParameters[ApiStrings.page] = page;
      }
      if (size != null) {
        queryParameters[ApiStrings.size] = size;
      }
      if (sortField != null && isAscending != null) {
        final String fieldName = sortField.name;
        final String direction = isAscending
            ? ApiStrings.arrange.ascending
            : ApiStrings.arrange.descending;
        queryParameters[ApiStrings.sort] = '$fieldName,$direction';
      }
      final result = await networkService.get(
        endpoint: (name != null)
            ? ApiPath.device.searchDevices
            : ApiPath.device.allDevices,
        queryParameters: queryParameters,
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
        endpoint: ApiPath.device.createDevice,
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
      print('Loi khac (updateDevice) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> toggleDevice({
    required Device device,
  }) async {
    try {
      final result = await networkService.post(
        endpoint: ApiPath.device.toggleDevice(device.id),
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
      print('Loi khac (toggleDevice) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, List<HistoryWatering>>> getHistoryWatering({
    required Device device,
  }) async {
    print('fetching watering history...');
    try {
      final result = await networkService.get(
        endpoint: ApiPath.device.getHistoryWatering(device.id),
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final List<dynamic> listData = response.data;
          final List<HistoryWatering> listHistoryWatering = listData
              .map((historyJson) => HistoryWatering.fromJson(historyJson))
              .toList();
          return Right(listHistoryWatering);
        },
      );
    } catch (e) {
      print('Loi khac (getHistoryWatering) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, List<HistorySensor>>> getHistorySensor({
    required Device device,
    int? page,
    int? size,
    HistorySensorSortField? sortField,
    bool? isAscending,
  }) async {
    print('fetching sensor history...');
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) {
        queryParameters[ApiStrings.page] = page;
      }
      if (size != null) {
        queryParameters[ApiStrings.size] = size;
      }
      if (sortField != null && isAscending != null) {
        final String fieldName = sortField.name;
        final String direction = isAscending
            ? ApiStrings.arrange.ascending
            : ApiStrings.arrange.descending;
        queryParameters[ApiStrings.sort] = '$fieldName,$direction';
      }

      final result = await networkService.get(
        endpoint: ApiPath.device.getHistorySensor(device.id),
        queryParameters: queryParameters,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final List<dynamic> listData = response.data;
          final List<HistorySensor> listHistorySensor = listData
              .map((historyJson) => HistorySensor.fromJson(historyJson))
              .toList();
          return Right(listHistorySensor);
        },
      );
    } catch (e) {
      print('Loi khac (getHistorySensor) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, List<Schedule>>> getListSchedule({
    required Device device,
    int? page,
    int? size,
  }) async {
    print('fetching list schedule...');
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) {
        queryParameters[ApiStrings.page] = page;
      }
      if (size != null) {
        queryParameters[ApiStrings.size] = size;
      }

      final result = await networkService.get(
        endpoint: ApiPath.device.getListSchedule(device.id),
        queryParameters: queryParameters,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final List<dynamic> listData = response.data;
          final List<Schedule> listSchedule = listData
              .map((historyJson) => Schedule.fromJson(historyJson))
              .toList();
          return Right(listSchedule);
        },
      );
    } catch (e) {
      print('Loi khac (getListSchedule) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> toggleSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    try {
      final result = await networkService.post(
        endpoint: ApiPath.device.toggleSchedule(device.id, schedule.id),
        data: {ApiStrings.status: schedule.status},
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
      print('Loi khac (toggleSchedule) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> createSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    try {
      final result = await networkService.post(
        endpoint: ApiPath.device.createSchedule(device.id),
        data: schedule.toJson(),
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
      print('Loi khac (createSchedule) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> updateSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    try {
      final result = await networkService.put(
        endpoint: ApiPath.device.updateSchedule(device.id, schedule.id),
        data: schedule.toJson(),
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
      print('Loi khac (updateSchedule) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> deleteSchedule({
    required Device device,
    required Schedule schedule,
  }) async {
    try {
      final result = await networkService.delete(
        endpoint: ApiPath.device.deleteSchedule(device.id, schedule.id),
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
      print('Loi khac (updateSchedule) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }
}
