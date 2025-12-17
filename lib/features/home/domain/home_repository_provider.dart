import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/network/network_service_provider.dart';
import 'package:watering_app/features/home/data/source/home_remote.dart';
import 'package:watering_app/features/home/domain/home_repository_impl.dart';

final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) {
  final homeRemoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(homeRemoteDataSource);
});

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final newsNetworkService = ref.watch(newsNetworkProvider);
  return HomeRemoteDataSource(networkService, newsNetworkService);
});
