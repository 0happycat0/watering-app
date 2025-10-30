class ApiPath {
  //FIXME: baseUrl
  static const String baseUrl = 'https://be-smart-watering-production.up.railway.app';
  // static const String baseUrl =
  //     'https://unmoaned-dale-nonspherical.ngrok-free.dev'; //work on emulator (not physical device)

  static final auth = _AuthPath();
  static final device = _DevicePath();
}

class _AuthPath {
  const _AuthPath();
  final String login = '/auth/log-in';
  final String refresh = '/auth/refresh';
  final String logout = '/auth/log-out';
  final String getUser = '/users';

  final String createUser = '/users';
}

class _DevicePath {
  _DevicePath();
  final String allDevice = '/devices';
  final String createDevice = '/devices';
  String deviceById(String id) => '/devices/$id';
  String toggleDevice(String id) => '/devices/$id/watering';
  String getHistoryWatering(String id) => '/devices/$id/watering/history';
  String getHistorySensor(String id) => '/devices/$id/sensor/history';
}
