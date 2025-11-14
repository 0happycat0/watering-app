import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Exception, User>> loginUser(
    WidgetRef ref, {
    required User user,
  });
  Future<void> logout(WidgetRef ref);
  Future<bool> get isLoggedIn;
  Future<User> getUser();
  Future<Either<Exception, Response>> createUser({required User user});
  Future<Either<Exception, Response>> sendOtp({required String email});
  Future<Either<Exception, Response>> verifyEmail({
    required String email,
    required String otp,
  });
  Future<Either<Exception, Response>> changePassword({
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  });
}
