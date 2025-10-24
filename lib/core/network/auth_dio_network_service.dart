import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthDioNetworkService {
  AuthDioNetworkService(this._dio) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  final Dio _dio;
  Dio get dio => _dio;

  Future<Either<DioException, Response>> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Response res;
    try {
      res = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(
        Response(
          requestOptions: res.requestOptions,
          statusCode: res.statusCode,
          data: res.data['data'],
        ),
      );
    } on DioException catch (e) {
      return Left(
        DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: e.response?.data['message'],
        ),
      );
    }
  }

  Future<Either<DioException, Response>> post({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    Response res;
    try {
      res = await _dio.post(endpoint, data: data);
      // print('post response: ${res.data}');

      return Right(
        Response(
          requestOptions: RequestOptions(),
          statusCode: res.statusCode,
          data: res.data['data'],
        ),
      );
    } on DioException catch (e) {
      print('loi post: ${e}');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          response: e.response,
          message: e.response?.data['message'],
        ),
      );
    }
  }
}
