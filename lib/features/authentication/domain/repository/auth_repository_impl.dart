import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/utils/stomp_service.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/features/authentication/data/source/auth_local.dart';
import 'package:watering_app/features/authentication/data/source/auth_remote.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<DioException, User>> loginUser({required User user}) async {
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
        return Right(user);
      },
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);
    final accessToken = local.accessToken;

    //logout: gọi api, xóa local, dispose Stomp
    await authRemoteDataSource.logoutUser(user: User(accessToken: accessToken));
    await local.logout();
    StompService().dispose();
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
    final bool isRemoteLoggedIn = response.isRight();
    return isLocalLoggedIn && isRemoteLoggedIn;
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
}
