import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/api_strings.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';

class GroupRemoteDataSource {
  final DioNetworkService networkService;

  GroupRemoteDataSource(this.networkService);

  Future<Either<DioException, List<Group>>> getAllGroups({
    String? name,
    int? page,
    int? size,
  }) async {
    print('fetching group data...');
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
      final result = await networkService.get(
        endpoint: (name != null)
            ? ApiPath.group.searchGroups
            : ApiPath.group.allGroups,
        queryParameters: queryParameters,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final List<dynamic> listData = response.data;
          final List<Group> listGroup = listData
              .map((groupJson) => Group.fromJson(groupJson))
              .toList();
          return Right(listGroup);
        },
      );
    } catch (e) {
      print('Loi khac (getAllGroups) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

    Future<Either<DioException, List<Device>>> getFreeDevices({
    String? name,
    int? page,
    int? size,
    AllDevicesSortField? sortField,
    bool? isAscending,
  }) async {
    print('fetching free devices...');
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
        endpoint: (name != null) ? '' : ApiPath.device.freeDevices,
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
      print('Loi khac (getFreeDevices) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> createGroup({
    required Group group,
  }) async {
    try {
      final result = await networkService.post(
        endpoint: ApiPath.group.createGroup,
        data: group.toJson(),
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
      print('Loi khac (createGroup) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Group>> getGroupById({
    required String id,
  }) async {
    print('fetching group by id...');
    try {
      final result = await networkService.get(
        endpoint: ApiPath.group.groupById(id),
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final Group group = Group.fromJson(response.data);
          return Right(group);
        },
      );
    } catch (e) {
      print('Loi khac (getGroupById) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> deleteGroup({
    required Group group,
  }) async {
    try {
      final result = await networkService.delete(
        endpoint: ApiPath.group.groupById(group.id),
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
      print('Loi khac (deleteGroup) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> updateGroup({
    required Group group,
  }) async {
    try {
      final result = await networkService.put(
        endpoint: ApiPath.group.groupById(group.id),
        data: group.toJson(),
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
      print('Loi khac (updateGroup) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }
}

