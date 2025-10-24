import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/network/auth_dio_network_service.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/core/network/interceptors/auth_interceptor.dart';

//provider of network service
final networkServiceProvider = Provider<DioNetworkService>((ref) {
  final dio = ref.watch(dioProvider);
  final interceptor = AuthInterceptor(dio, ref);
  dio.interceptors.add(interceptor);
  return DioNetworkService(dio);
});

final dioProvider = Provider<Dio>((ref) {
  final baseOptions = ref.watch(baseOptionsProvider);
  return Dio(baseOptions);
});

//provider for authentication only
final authNetworkServiceProvider = Provider<AuthDioNetworkService>((ref) {
  final dio = ref.watch(authDioProvider);
  return AuthDioNetworkService(dio);
});

final authDioProvider = Provider<Dio>((ref) {
  final baseOptions = ref.watch(baseOptionsProvider);
  return Dio(baseOptions);
});

final baseOptionsProvider = Provider<BaseOptions>((ref) {
  return BaseOptions(
    baseUrl: ApiPath.baseUrl,
    headers: {
      'accept': 'application/json',
      'content-type': 'application/json',
    },
  );
});

