import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/api_strings.dart';
import 'package:watering_app/core/constants/shared_preference_key.dart';
import 'package:watering_app/features/authentication/presentation/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final Ref _ref;
  String? _accessToken;
  String? _refreshToken;

  AuthInterceptor(this._dio, this._ref);

  //lấy access_token từ SharedPreferences và gán vào biến _accessToken
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(SharedPreferenceKey.accessToken);
    return _accessToken;
  }

  //cần set token ở cả local và RAM (gán vào _accessToken)
  Future<void> _setAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPreferenceKey.accessToken, accessToken);
    print('Accesstoken is saved');
    _accessToken = accessToken;
  }

  //tương tự với _refreshToken
  //tuy nhiên không cần set _refreshToken, vì nếu _refreshToken hết hạn sẽ yêu cầu logout
  //việc set _refreshToken đã được thực hiện ở auth_repository_imp
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    _refreshToken = prefs.getString(SharedPreferenceKey.refreshToken);
    return _refreshToken;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    //gán 2 loại token vào instance AuthInterceptor
    final accessToken = await _getAccessToken();
    final refreshToken = await _getRefreshToken();

    //TODO: remove this
    print('access token: $accessToken');
    print('refresh token: $refreshToken');
    if (accessToken != null && options.extra['skipAuth'] != true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      print(
        'Added access token to header (or refreshed access token successfully)',
      );
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final errRes = err.response;
    final reqOpt = err.requestOptions;
    final bool isCheckingAuth = reqOpt.extra['isCheckingAuth'] == true;

    print('error when requesting something: ${err.response}');
    if (errRes?.statusCode == 401 &&
        errRes?.data[ApiStrings.message] == ApiStrings.tokenExpired &&
        reqOpt.path != ApiPath.auth.refresh) {
      try {
        print('refreshing token...');
        final res = await _dio.post(
          ApiPath.auth.refresh,
          data: {
            ApiStrings.accessToken: _accessToken,
            ApiStrings.refreshToken: _refreshToken,
          },
          options: Options(
            extra: {
              'skipAuth': true,
              'isCheckingAuth': isCheckingAuth,
            },
          ),
        );
        final String newAccessToken = res.data['data'][ApiStrings.accessToken];
        print('get new access token successfully!');
        await _setAccessToken(newAccessToken);

        //retry request
        print('Retrying request...');
        final headers = Map<String, dynamic>.from(reqOpt.headers);
        headers['Authorization'] = 'Bearer $newAccessToken';

        //if is not checking auth -> retry request again
        final retryResponse = await _dio.fetch(
          reqOpt.copyWith(headers: headers),
        );
        print('Retrying completed');
        return handler.resolve(retryResponse);
      } on DioException catch (e) {
        print(
          'Error in requesting new access token\nmessage: ${e.response?.data[ApiStrings.message]}',
        );
        return handler.next(err);
      } catch (e) {
        print('Loi khac khi refresh token: $e');
      }
    } else if (errRes?.statusCode == 401 &&
        errRes?.data[ApiStrings.message] == ApiStrings.tokenExpired &&
        reqOpt.path == ApiPath.auth.refresh) {
      print('Token is expired when requesting refresh');

      //if is not checking auth -> call provider to log out if refresh fail
      if (!isCheckingAuth) {
        // await _ref.read(authProvider.notifier).logout();
        _ref.read(requestLogoutProvider.notifier).state = true;
      }
      return handler.reject(err);
    }
    return handler.next(err);
  }
}
