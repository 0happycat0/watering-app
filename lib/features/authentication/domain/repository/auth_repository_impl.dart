import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/network/stomp_service.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';
import 'package:watering_app/core/utils/debug_print.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/features/authentication/data/source/auth_local.dart';
import 'package:watering_app/features/authentication/data/source/auth_remote.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  Future<AuthLocalDataSource> _getLocalDataSource() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthLocalDataSource(prefs);
  }

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
      (userData) async {
        //user in response only have JWT token, so must decode it to save username and email
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(
          userData.accessToken,
        );
        final username = decodedToken['sub'] ?? '--';
        final email = decodedToken['email'] ?? '--';
        final userToSave = User(
          accessToken: userData.accessToken,
          refreshToken: userData.refreshToken,
          username: username,
          password: user.password,
          email: email,
          verified: userData.verified,
        );
        //save user info
        await local.loginUser(userToSave);
        ref.read(stompServiceProvider.notifier).state = StompService();
        return Right(userToSave);
      },
    );
  }

  @override
  Future<void> logout(WidgetRef ref) async {
    final local = await _getLocalDataSource();
    final accessToken = await local.accessToken ?? '';

    //logout: gọi api, xóa local, dispose Stomp
    // (giữ lại password, username, email, verified, isEnabledBiometric)
    await authRemoteDataSource.logoutUser(user: User(accessToken: accessToken));
    await local.logout();
    final currentService = ref.read(stompServiceProvider);
    if (currentService != null) {
      currentService.dispose();
      ref.read(stompServiceProvider.notifier).state = null;
    }
  }

  Future<void> deleteUser() async {
    final local = await _getLocalDataSource();
    local.deleteUser();
  }

  @override
  Future<bool> get isLoggedIn async {
    final local = await _getLocalDataSource();
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
  Future<bool> get isEnabledBiometric async {
    final local = await _getLocalDataSource();
    return local.isEnabledBiometric;
  }

  @override
  Future<void> setEnabledBiometric(bool isEnabledBiometric) async {
    final local = await _getLocalDataSource();
    return local.setEnabledBiometric(isEnabledBiometric);
  }

  @override
  Future<User> getUser() async {
    final local = await _getLocalDataSource();
    final username = local.username;
    final email = local.email;
    final verified = local.verified;
    final user = User(username: username, email: email, verified: verified);
    printDebug('DEBUG: user = $user');
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
    final local = await _getLocalDataSource();

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
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await authRemoteDataSource.changePassword(
      email: email,
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
