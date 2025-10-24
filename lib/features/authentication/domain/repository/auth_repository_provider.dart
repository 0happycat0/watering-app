import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/network/network_service_provider.dart';
import 'package:watering_app/features/authentication/data/source/auth_remote.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_impl.dart';

final Provider<AuthRepositoryImpl> authRepositoryProvider =
    Provider<AuthRepositoryImpl>((ref) {
      final authRemoteDataSource = ref.watch(authRemoteDataSourceProvider);
      return AuthRepositoryImpl(authRemoteDataSource);
    });

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final authNetworkService = ref.watch(authNetworkServiceProvider);
  return AuthRemoteDataSource(networkService, authNetworkService);
});