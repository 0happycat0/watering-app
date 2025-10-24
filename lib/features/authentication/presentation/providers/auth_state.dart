import 'package:dio/dio.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';

sealed class AuthState {
  const AuthState();
}

class Initial extends AuthState {
  const Initial();
}

class Loading extends AuthState {
  const Loading();
}

class Success extends AuthState {
  const Success([this.user]);
  final User? user;
}

class SignupSuccess extends AuthState {
  const SignupSuccess();
}

class UnAuthenticated extends AuthState {
  const UnAuthenticated();
}

class LoginFailure extends AuthState {
  const LoginFailure(this.exception);
  final DioException exception;
  String get message {
    switch (exception.message) {
      case 'User not existed':
        return 'Sai tên đăng nhập hoặc mật khẩu';
      case 'Password is wrong':
        return 'Sai tên đăng nhập hoặc mật khẩu';
      case 'Internal Server Error':
        return 'Lỗi máy chủ. Vui lòng thử lại';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}

class SignupFailure extends AuthState {
  const SignupFailure(this.exception);
  final DioException exception;
  String get message {
    switch (exception.message) {
      case 'User has been existed':
        return 'Người dùng đã tồn tại';
      case 'Password must be at least 8 characters':
        return 'Mật khẩu phải có ít nhất 8 ký tự';
      case 'Username must be at least 3 characters':
        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}
