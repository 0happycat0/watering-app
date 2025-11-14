import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_impl.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_provider.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

// auth
final authProvider = StateNotifierProvider<AuthNotifier, auth_state.AuthState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthNotifier(authRepository);
  },
);

final requestLogoutProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<auth_state.AuthState> {
  AuthNotifier(this.authRepository) : super(auth_state.Initial()) {
    // checkAuthStatus();
  }

  final AuthRepositoryImpl authRepository;

  Future<void> loginUser(
    WidgetRef ref, {
    required String username,
    required String password,
  }) async {
    state = const auth_state.Loading();
    final response = await authRepository.loginUser(
      ref,
      user: User(username: username, password: password),
    );

    state = response.fold(
      (exeption) {
        return auth_state.LoginFailure(exeption);
      },
      (user) {
        print('Da dang nhap');
        return auth_state.Success(user);
      },
    );
  }

  //TODO: fix this (do not call log out api when token is expired)
  Future<void> logout(WidgetRef ref) async {
    await authRepository.logout(ref);
    state = auth_state.UnAuthenticated();
    print('Da dang xuat');
  }

  Future<bool> isLoggedIn() {
    return authRepository.isLoggedIn;
  }

  //TODO: review this
  // Future<void> checkAuthStatus() async {
  //   final isLoggedIn = await authRepository.isLoggedIn;
  //   if (isLoggedIn) {
  //     state = auth_state.Success();
  //   } else {
  //     state = auth_state.UnAuthenticated();
  //   }
  // }

  Future<void> getUserInfo() async {
    state = auth_state.Loading();
    final user = await authRepository.getUser();
    state = auth_state.Success(user);
  }

  Future<void> createUser({
    required String username,
    required String password,
  }) async {
    state = const auth_state.Loading();
    final response = await authRepository.createUser(
      user: User(username: username, password: password),
    );

    state = response.fold(
      (exeption) {
        return auth_state.SignupFailure(exeption);
      },
      (user) {
        print('Da dang ky');
        return auth_state.SignupSuccess();
      },
    );
  }
}

//--------------------------------------------------------------------------------------------------
// send otp
final sendOtpProvider =
    StateNotifierProvider.autoDispose<SendOtpNotifier, auth_state.AuthState>(
      (ref) {
        final authRepository = ref.watch(authRepositoryProvider);
        return SendOtpNotifier(authRepository);
      },
    );

class SendOtpNotifier extends StateNotifier<auth_state.AuthState> {
  SendOtpNotifier(this.authRepository) : super(auth_state.Initial());
  final AuthRepositoryImpl authRepository;

  Future<void> sendOtp({required String email}) async {
    state = auth_state.Loading();
    final response = await authRepository.sendOtp(email: email);
    if (!mounted) return;
    state = response.fold(
      (exception) {
        return auth_state.SendOtpFailure(exception);
      },
      (_) {
        return auth_state.Success();
      },
    );
  }
}

//--------------------------------------------------------------------------------------------------
// verify otp
final verifyEmailProvider =
    StateNotifierProvider.autoDispose<
      verifyEmailNotifier,
      auth_state.AuthState
    >(
      (ref) {
        final authRepository = ref.watch(authRepositoryProvider);
        return verifyEmailNotifier(authRepository);
      },
    );

class verifyEmailNotifier extends StateNotifier<auth_state.AuthState> {
  verifyEmailNotifier(this.authRepository) : super(auth_state.Initial());
  final AuthRepositoryImpl authRepository;

  Future<void> verifyEmail({required String email, required String otp}) async {
    state = auth_state.Loading();
    final response = await authRepository.verifyEmail(email: email, otp: otp);
    if (!mounted) return;
    state = response.fold(
      (exception) {
        return auth_state.VerifyEmailFailure(exception);
      },
      (_) {
        return auth_state.Success();
      },
    );
  }
}

//--------------------------------------------------------------------------------------------------
// change password
final changePasswordProvider =
    StateNotifierProvider.autoDispose<
      ChangePasswordNotifier,
      auth_state.AuthState
    >(
      (ref) {
        final authRepository = ref.watch(authRepositoryProvider);
        return ChangePasswordNotifier(authRepository);
      },
    );

class ChangePasswordNotifier extends StateNotifier<auth_state.AuthState> {
  ChangePasswordNotifier(this.authRepository) : super(auth_state.Initial());
  final AuthRepositoryImpl authRepository;

  Future<void> changePassword({
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = auth_state.Loading();
    final response = await authRepository.changePassword(
      code: code,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
    if (!mounted) return;
    state = response.fold(
      (exception) {
        return auth_state.ChangePasswordFailure(exception);
      },
      (_) {
        return auth_state.Success();
      },
    );
  }
}
