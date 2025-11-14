import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/constants/api_strings.dart';
import 'package:watering_app/core/network/auth_dio_network_service.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/core/constants/api_path.dart';

class AuthRemoteDataSource {
  //không có token
  final AuthDioNetworkService authNetworkService;

  //có token
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

  Future<Either<DioException, User>> getMe({Options? options}) async {
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
          final user = User.fromJson(response.data);
          return Right(user);
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

  Future<Either<DioException, Response>> sendOtp({
    required String email,
  }) async {
    try {
      final result = await authNetworkService.post(
        endpoint: ApiPath.auth.sendOtp,
        data: {ApiStrings.email: email},
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
      print('Loi khac (sendOtp) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await authNetworkService.post(
        endpoint: ApiPath.auth.verifyEmail,
        data: {
          ApiStrings.email: email,
          ApiStrings.code: otp,
        },
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
      print('Loi khac (verifyEmail) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> changePassword({
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final result = await networkService.post(
        endpoint: ApiPath.auth.changePassword,
        data: {
          ApiStrings.code: code,
          ApiStrings.newPassword: newPassword,
          ApiStrings.confirmNewPassword: confirmNewPassword,
        },
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
      print('Loi khac (changePassword) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }
}
