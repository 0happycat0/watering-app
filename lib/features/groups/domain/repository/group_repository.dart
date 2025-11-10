import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/data/models/history_watering_model.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';

abstract class GroupRepository {
  Future<Either<Exception, List<Group>>> getAllGroups();
  Future<Either<Exception, List<Device>>> getFreeDevices();
  Future<Either<Exception, Response>> createGroup({
    required Group group,
    required List<String> listIdOfDevices,
  });
  Future<Either<Exception, Group>> getGroupById({required String id});
  Future<Either<Exception, Response>> deleteGroup({required Group group});
  Future<Either<Exception, Response>> updateGroup({
    required Group group,
    required List<String> listIdOfDevices,
  });
  Future<Either<Exception, Response>> toggleGroup({required Group group});
  Future<Either<Exception, List<HistoryWatering>>> getHistoryWatering({
    required Group group,
  });
  Future<Either<Exception, List<Schedule>>> getListSchedule({
    required Group group,
  });
  Future<Either<Exception, Response>> createSchedule({
    required Group group,
    required Schedule schedule,
  });
  Future<Either<Exception, Response>> updateSchedule({
    required Group group,
    required Schedule schedule,
  });
  Future<Either<Exception, Response>> deleteSchedule({
    required Group group,
    required Schedule schedule,
  });
  Future<Either<Exception, Response>> toggleSchedule({
    required Group group,
    required Schedule schedule,
  });
}
