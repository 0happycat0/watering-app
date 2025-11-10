import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/data/models/history_watering_model.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/data/source/group_remote.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository.dart';

class GroupRepositoryImpl extends GroupRepository {
  GroupRemoteDataSource groupRemoteDataSource;

  GroupRepositoryImpl(this.groupRemoteDataSource);

  @override
  Future<Either<DioException, List<Group>>> getAllGroups({
    String? name,
    int? page,
    int? size,
  }) async {
    final response = await groupRemoteDataSource.getAllGroups(
      name: name,
      page: page,
      size: size,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listGroups) {
        return Right(listGroups);
      },
    );
  }

  @override
  Future<Either<DioException, List<Device>>> getFreeDevices({
    String? name,
    int? page,
    int? size,
    AllDevicesSortField? sortField,
    bool? isAscending,
  }) async {
    final response = await groupRemoteDataSource.getFreeDevices(
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
  Future<Either<DioException, Response>> createGroup({
    required Group group,
    required List<String> listIdOfDevices,
  }) async {
    final response = await groupRemoteDataSource.createGroup(
      group: group,
      listIdOfDevices: listIdOfDevices,
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
  Future<Either<DioException, Group>> getGroupById({
    required String id,
  }) async {
    final response = await groupRemoteDataSource.getGroupById(id: id);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (group) {
        return Right(group);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> deleteGroup({
    required Group group,
  }) async {
    final response = await groupRemoteDataSource.deleteGroup(group: group);
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
  Future<Either<DioException, Response>> updateGroup({
    required Group group,
    required List<String> listIdOfDevices,
  }) async {
    final response = await groupRemoteDataSource.updateGroup(
      group: group,
      listIdOfDevices: listIdOfDevices,
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
  Future<Either<DioException, Response>> toggleGroup({
    required Group group,
  }) async {
    final response = await groupRemoteDataSource.toggleGroup(group: group);
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
    required Group group,
  }) async {
    final response = await groupRemoteDataSource.getHistoryWatering(
      group: group,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (list) {
        return Right(list);
      },
    );
  }

  @override
  Future<Either<DioException, List<Schedule>>> getListSchedule({
    required Group group,
  }) async {
    final response = await groupRemoteDataSource.getListSchedule(group: group);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (list) {
        return Right(list);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> createSchedule({
    required Group group,
    required Schedule schedule,
  }) async {
    final response = await groupRemoteDataSource.createSchedule(
      group: group,
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
    required Group group,
    required Schedule schedule,
  }) async {
    final response = await groupRemoteDataSource.updateSchedule(
      group: group,
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
    required Group group,
    required Schedule schedule,
  }) async {
    final response = await groupRemoteDataSource.deleteSchedule(
      group: group,
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
  Future<Either<DioException, Response>> toggleSchedule({
    required Group group,
    required Schedule schedule,
  }) async {
    final response = await groupRemoteDataSource.toggleSchedule(
      group: group,
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
