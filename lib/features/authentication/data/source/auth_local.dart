import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';

class AuthLocalDataSource {
  final SharedPreferences _prefs;
  AuthLocalDataSource(this._prefs);

  Future<void> loginUser(User user) async {
    await _prefs.setString(SharedPreferenceKey.accessToken, user.accessToken);
    await _prefs.setString(SharedPreferenceKey.refreshToken, user.refreshToken);
    await _prefs.setBool(SharedPreferenceKey.isLoggedIn, true);
  }

  bool get isLoggedIn =>
      _prefs.getBool(SharedPreferenceKey.isLoggedIn) ?? false;

  String get accessToken =>
      _prefs.getString(SharedPreferenceKey.accessToken) ?? '';

  String get refreshToken =>
      _prefs.getString(SharedPreferenceKey.refreshToken) ?? '';

  Future<void> logout() async {
    await _prefs.remove(SharedPreferenceKey.accessToken);
    await _prefs.remove(SharedPreferenceKey.refreshToken);
    await _prefs.remove(SharedPreferenceKey.isLoggedIn);
  }
}
