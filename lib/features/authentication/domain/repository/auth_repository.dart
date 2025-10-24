import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Exception, User>> loginUser({required User user});
  Future<void> logout();
  Future<bool> get isLoggedIn;
  Future<Either<Exception, Response>> createUser({required User user});
}
