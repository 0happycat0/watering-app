import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/network/stomp_service.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/features/authentication/data/source/auth_local.dart';
import 'package:watering_app/features/authentication/data/source/auth_remote.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<DioException, User>> loginUser(
    WidgetRef ref, {
    required User user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);

    // Remove access token before log in
    // await prefs.remove(SharedPreferenceKey.accessToken);
    final response = await authRemoteDataSource.loginUser(user: user);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (user) async {
        //save user info
        await local.loginUser(user);
        ref.read(stompServiceProvider.notifier).state = StompService();
        return Right(user);
      },
    );
  }

  @override
  Future<void> logout(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);
    final accessToken = local.accessToken;

    //logout: gọi api, xóa local, dispose Stomp
    await authRemoteDataSource.logoutUser(user: User(accessToken: accessToken));
    await local.deleteUser();
    final currentService = ref.read(stompServiceProvider);
    if (currentService != null) {
      currentService.dispose();
      ref.read(stompServiceProvider.notifier).state = null;
    }
  }

  @override
  Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);
    final bool isLocalLoggedIn = local.isLoggedIn;

    //kiểm tra user còn hạn refresh không
    //thêm option để biết đang kiểm tra log in
    final response = await authRemoteDataSource.getMe(
      options: Options(extra: {'isCheckingAuth': true}),
    );

    response.fold(
      (exception) {
        return Left(exception);
      },
      (user) async {
        await local.saveUser(user);
        return Right(user);
      },
    );

    final bool isRemoteLoggedIn = response.isRight();
    return isLocalLoggedIn && isRemoteLoggedIn;
  }

  @override
  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);
    final username = local.username;
    final email = local.email;
    final verified = local.verified;
    final user = User(username: username, email: email, verified: verified);
    print('DEBUG: user = $user');
    return user;
  }

  @override
  Future<Either<DioException, Response>> createUser({
    required User user,
  }) async {
    final response = await authRemoteDataSource.createUser(user: user);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) async {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> sendOtp({
    required String email,
  }) async {
    final response = await authRemoteDataSource.sendOtp(email: email);
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) async {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);

    final response = await authRemoteDataSource.verifyEmail(
      email: email,
      otp: otp,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) async {
        await local.setVerified(true);
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> changePassword({
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await authRemoteDataSource.changePassword(
      code: code,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) async {
        return Right(res);
      },
    );
  }
}
