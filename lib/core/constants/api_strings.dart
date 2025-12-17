class ApiStrings {
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String tokenExpired = 'Token has expired';
  static const String invalidToken = 'Invalid token';

  static const String message = 'message';
  
  static const String email = 'email';
  static const String code = 'code';
  static const String newPassword = 'newPassword';
  static const String confirmNewPassword = 'confirmNewPassword';

  static const String name = 'name';
  static const String page = 'page';
  static const String size = 'size';
  static const String sort = 'sort';

  static const String devices = 'devices';

  static const String scheduleId = 'scheduleId';
  static const String status = 'status';

  static final arrange = _Arrange();
}

class _Arrange {
  _Arrange();
  final String ascending = 'asc';
  final String descending = 'desc';
}
