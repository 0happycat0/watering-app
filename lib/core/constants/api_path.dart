class ApiPath {
  static const String baseUrl =
      'https://be-smart-watering-production.up.railway.app';
  // static const String baseUrl =
  //     'https://unmoaned-dale-nonspherical.ngrok-free.dev'; //work on emulator (not physical device)

  static final auth = _AuthPath();
  static final device = _DevicePath();
  static final group = _GroupPath();
}

class _AuthPath {
  const _AuthPath();
  final String login = '/auth/log-in';
  final String refresh = '/auth/refresh';
  final String logout = '/auth/log-out';
  final String getUser = '/users';

  final String createUser = '/users';

  final String sendOtp = '/mail/send';
  final String verifyEmail = '/auth/verify';
  final String changePassword = '/auth/change-password';
}

class _DevicePath {
  _DevicePath();
  final String allDevices = '/devices';
  final String searchDevices = '/devices/search';
  final String createDevice = '/devices';
  final String freeDevices = '/devices/free';
  String deviceById(String id) => '/devices/$id';
  String toggleDevice(String id) => '/devices/$id/watering';
  String getHistoryWatering(String id) => '/devices/$id/watering/history';
  String getHistorySensor(String id) => '/devices/$id/sensor/history';

  //schedule
  String getListSchedule(String id) => '/devices/$id/schedule';
  String toggleSchedule(String id, String scheduleId) =>
      '/devices/$id/schedule/$scheduleId/trigger';
  String createSchedule(String id) => '/devices/$id/schedule';
  String updateSchedule(String id, String scheduleId) =>
      '/devices/$id/schedule/$scheduleId';
  String deleteSchedule(String id, String scheduleId) =>
      '/devices/$id/schedule/$scheduleId';
}

class _GroupPath {
  _GroupPath();
  final String allGroups = '/groups';
  final String createGroup = '/groups';
  final String searchGroups = '/groups/search';
  String groupById(String id) => '/groups/$id';
  String toggleGroup(String id) => '/groups/$id/watering';
  String getHistoryWatering(String id) => '/groups/$id/watering/history';

  //schedule
  String getListSchedule(String id) => '/groups/$id/schedule';
  String toggleSchedule(String id, String scheduleId) =>
      '/groups/$id/schedule/$scheduleId/trigger';
  String createSchedule(String id) => '/groups/$id/schedule';
  String updateSchedule(String id, String scheduleId) =>
      '/groups/$id/schedule/$scheduleId';
  String deleteSchedule(String id, String scheduleId) =>
      '/groups/$id/schedule/$scheduleId';
}
