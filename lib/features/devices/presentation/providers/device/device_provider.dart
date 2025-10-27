import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart'
    as device_state;

// final deleteDeviceProvider =
//     StateNotifierProvider.autoDispose<
//       DeleteDeviceProvider,
//       device_state.DeviceState
//     >(
//       (ref) {
//         final deviceRepository = ref.watch(deviceRepositoryProvider);
//         return DeleteDeviceProvider(deviceRepository);
//       },
//     );

final toggleDeviceProvider = FutureProvider.autoDispose.family<void, Device>((
  ref,
  device,
) {
  final deviceRepository = ref.watch(deviceRepositoryProvider);
  return deviceRepository.toggleDevice(device: device);
});
