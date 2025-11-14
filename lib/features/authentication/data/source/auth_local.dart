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
    await _prefs.setString(SharedPreferenceKey.username, user.username);
    await _prefs.setString(SharedPreferenceKey.email, user.email);
    await _prefs.setBool(SharedPreferenceKey.verified, user.verified);
  }

  Future<void> saveUser(User user) async {
    await _prefs.setBool(SharedPreferenceKey.isLoggedIn, true);
    await _prefs.setString(SharedPreferenceKey.username, user.username);
    await _prefs.setString(SharedPreferenceKey.email, user.email);
    await _prefs.setBool(SharedPreferenceKey.verified, user.verified);
  }

  Future<void> setVerified(bool isVerified) async {
    await _prefs.setBool(SharedPreferenceKey.verified, isVerified);
  }

  bool get isLoggedIn =>
      _prefs.getBool(SharedPreferenceKey.isLoggedIn) ?? false;

  bool get verified => _prefs.getBool(SharedPreferenceKey.verified) ?? false;

  String get accessToken =>
      _prefs.getString(SharedPreferenceKey.accessToken) ?? '';

  String get refreshToken =>
      _prefs.getString(SharedPreferenceKey.refreshToken) ?? '';

  String get username => _prefs.getString(SharedPreferenceKey.username) ?? '';

  String get email => _prefs.getString(SharedPreferenceKey.email) ?? '';

  Future<void> deleteUser() async {
    await _prefs.remove(SharedPreferenceKey.accessToken);
    await _prefs.remove(SharedPreferenceKey.refreshToken);
    await _prefs.remove(SharedPreferenceKey.isLoggedIn);
    await _prefs.remove(SharedPreferenceKey.username);
    await _prefs.remove(SharedPreferenceKey.email);
    await _prefs.remove(SharedPreferenceKey.verified);
  }
}
