class StompPath {
  static const String websocketUrl =
      // 'https://be-smart-watering-production.up.railway.app/streaming';
      'http://18.179.47.93:8080/streaming';
      // 'https://18.142.240.186:4443/streaming';

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

  final String groupsWatering = '/user/groups/watering';

}
