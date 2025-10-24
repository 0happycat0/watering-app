import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_impl.dart';
import 'package:watering_app/features/devices/domain/repository/device_repository_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device_state.dart'
    as device_state;
import 'package:watering_app/features/devices/presentation/providers/devices_provider.dart';

final deviceProvider =
    StateNotifierProvider.autoDispose<
      AddDeviceNotifier,
      device_state.DeviceState
    >(
      (ref) {
        final deviceRepository = ref.watch(deviceRepositoryProvider);

        return AddDeviceNotifier(ref, deviceRepository);
      },
    );

class AddDeviceNotifier extends StateNotifier<device_state.DeviceState> {
  AddDeviceNotifier(this._ref, this.deviceRepository)
    : super(device_state.Initial());

  final Ref _ref;
  final DeviceRepositoryImpl deviceRepository;

  Future<void> createDevice({
    required String name,
    required String deviceId,
  }) async {
    state = device_state.Loading();

    final response = await deviceRepository.createDevice(
      device: Device(name: name, deviceId: deviceId),
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (_) {
        //khởi tạo lại devicesProvider để cập nhật danh sách thiết bị
        _ref.invalidate(devicesProvider);
        return device_state.Success();
      },
    );
  }

  Future<void> deleteDevice({required String id}) async {
    state = device_state.Loading();

    final response = await deviceRepository.deleteDevice(
      device: Device(id: id),
    );

    state = response.fold(
      (exception) {
        return device_state.Failure(exception);
      },
      (_) {
        _ref.invalidate(devicesProvider);
        return device_state.Success();
      },
    );
  }
}
