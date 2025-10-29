import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';

final toggleDeviceProvider = FutureProvider.autoDispose.family<void, Device>((
  ref,
  device,
) {
  final deviceRepository = ref.watch(deviceRepositoryProvider);
  return deviceRepository.toggleDevice(device: device);
});
