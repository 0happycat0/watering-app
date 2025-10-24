import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/network/auth_dio_network_service.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/core/constants/api_path.dart';

class AuthRemoteDataSource {
  final AuthDioNetworkService authNetworkService;
  final DioNetworkService networkService;

  AuthRemoteDataSource(this.networkService, this.authNetworkService);

  Future<Either<DioException, User>> loginUser({required User user}) async {
    try {
      final result = await authNetworkService.post(
        endpoint: ApiPath.auth.login,
        data: user.toJson(),
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          //response.data co dang {"accessToken": "abc", "refreshToken": "cde"}
          final user = User.fromJson(response.data);
          return Right(user);
        },
      );
    } catch (e) {
      print('Loi khac (loginUser): $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> logoutUser({
    required User user,
  }) async {
    try {
      //TODO: remove this
      print('logging out...');
      final result = await authNetworkService.post(
        endpoint: ApiPath.auth.logout,
        data: user.toJson(),
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
      print('Loi khac (logoutUser) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> getMe({Options? options}) async {
    try {
      print('getting user data...');
      final result = await networkService.get(
        endpoint: ApiPath.auth.getUser,
        options: options,
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
      print('Loi khac (getUser) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> createUser({
    required User user,
  }) async {
    try {
      final result = await authNetworkService.post(
        endpoint: ApiPath.auth.createUser,
        data: user.toJson(),
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
      print('Loi khac (createUser) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }
}
