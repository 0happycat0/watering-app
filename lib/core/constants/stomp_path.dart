class StompPath {
  static const String websocketUrl =
      'https://be-smart-watering-production.up.railway.app/streaming';

  static final topic = _Topic();
}

class _Topic {
  const _Topic();

  final String devicesSensor = '/user/devices/sensor';
  final String devicesStatus = '/user/devices/status';
  final String devicesWatering = '/user/devices/watering';

  String deviceSensor(String deviceId) => '/user/device/sensor/$deviceId';
  String deviceStatus(String deviceId) => '/user/device/status/$deviceId';
  String deviceWatering(String deviceId) => '/user/device/watering/$deviceId';
}
