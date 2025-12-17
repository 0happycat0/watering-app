import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/core/utils/secure_storage_service.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';

class AuthLocalDataSource {
  final SharedPreferences _prefs;
  AuthLocalDataSource(this._prefs);

  Future<void> loginUser(User user) async {
    await SecureStorageService.instance.write(
      key: SharedPreferenceKey.accessToken,
      value: user.accessToken,
    );
    await SecureStorageService.instance.write(
      key: SharedPreferenceKey.refreshToken,
      value: user.refreshToken,
    );

    await SecureStorageService.instance.write(
      key: SharedPreferenceKey.password,
      value: user.password,
    );
    // await _prefs.setString(SharedPreferenceKey.accessToken, user.accessToken);
    // await _prefs.setString(SharedPreferenceKey.refreshToken, user.refreshToken);
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

  Future<void> setEnabledBiometric(bool value) async {
    await _prefs.setBool(
      SharedPreferenceKey.isEnabledBiometric,
      value,
    );
  }

  bool get isLoggedIn =>
      _prefs.getBool(SharedPreferenceKey.isLoggedIn) ?? false;

  bool get verified => _prefs.getBool(SharedPreferenceKey.verified) ?? false;

  bool get isEnabledBiometric =>
      _prefs.getBool(SharedPreferenceKey.isEnabledBiometric) ?? false;

  //Sensitive data
  Future<String?> get accessToken async {
    return await SecureStorageService.instance.read(key: SharedPreferenceKey.accessToken);
  }

  Future<String?> get refreshToken async {
    return await SecureStorageService.instance.read(key: SharedPreferenceKey.refreshToken);
  }

  Future<String?> get password async {
    return await SecureStorageService.instance.read(key: SharedPreferenceKey.password);
  }
  //-----

  String get username => _prefs.getString(SharedPreferenceKey.username) ?? '';

  String get email => _prefs.getString(SharedPreferenceKey.email) ?? '';

  Future<void> logout() async {
    await SecureStorageService.instance.delete(key: SharedPreferenceKey.accessToken);
    await SecureStorageService.instance.delete(key: SharedPreferenceKey.refreshToken);
    await _prefs.remove(SharedPreferenceKey.isLoggedIn);
  }

  Future<void> deleteUser() async {
    await SecureStorageService.instance.delete(key: SharedPreferenceKey.accessToken);
    await SecureStorageService.instance.delete(key: SharedPreferenceKey.refreshToken);
    await SecureStorageService.instance.delete(key: SharedPreferenceKey.password);
    // await _prefs.remove(SharedPreferenceKey.accessToken);
    // await _prefs.remove(SharedPreferenceKey.refreshToken);
    await _prefs.remove(SharedPreferenceKey.isLoggedIn);
    await _prefs.remove(SharedPreferenceKey.username);
    await _prefs.remove(SharedPreferenceKey.email);
    await _prefs.remove(SharedPreferenceKey.verified);
    await _prefs.remove(SharedPreferenceKey.isEnabledBiometric);
  }
}
