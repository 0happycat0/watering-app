import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/network/network_service_provider.dart';
import 'package:watering_app/features/groups/data/source/group_remote.dart';
import 'package:watering_app/features/groups/domain/repository/group_repository_impl.dart';

final groupRepositoryProvider = Provider<GroupRepositoryImpl>((ref) {
  final groupRemoteDataSource = ref.watch(groupRemoteDataSourceProvider);
  return GroupRepositoryImpl(groupRemoteDataSource);
});

final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return GroupRemoteDataSource(networkService);
});

