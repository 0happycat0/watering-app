import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/authentication/data/models/user_model.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_impl.dart';
import 'package:watering_app/features/authentication/domain/repository/auth_repository_provider.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

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
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await authRepository.isLoggedIn;
    if (isLoggedIn) {
      state = auth_state.Success();
    } else {
      state = auth_state.UnAuthenticated();
    }
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
