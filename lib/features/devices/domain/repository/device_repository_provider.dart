import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/network/network_service_provider.dart';
import 'package:watering_app/features/devices/data/source/device_remote.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';

final deviceRepositoryProvider = Provider<DeviceRepositoryImpl>((ref) {
  final deviceRemoteDataSource = ref.watch(deviceRemoteDataSourceProvider);
  return DeviceRepositoryImpl(deviceRemoteDataSource);
});

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  return DeviceRemoteDataSource(networkService);
});