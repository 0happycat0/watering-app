import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';

abstract class GroupRepository {
  Future<Either<Exception, List<Group>>> getAllGroups();
  Future<Either<Exception, List<Device>>> getFreeDevices();
  Future<Either<Exception, Response>> createGroup({required Group group});
  Future<Either<Exception, Group>> getGroupById({required String id});
  Future<Either<Exception, Response>> deleteGroup({required Group group});
  Future<Either<Exception, Response>> updateGroup({required Group group});
}

