import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/features/auth/models/auth_model.dart';
import 'package:voca_flip_mobile/features/auth/repositories/auth_repository.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import '../../../core/services/google_auth_service.dart';

// ──────────────────────────────────────────────
//  State
// ──────────────────────────────────────────────

enum AuthStatus { initial, loading, success, failure }

class AuthState {
  final AuthStatus status;
  final AuthResponseModel? authResponse;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authResponse,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthResponseModel? authResponse,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    authResponse: authResponse ?? this.authResponse,
    errorMessage: errorMessage,
  );
}

// ──────────────────────────────────────────────
//  Notifier
// ──────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _repo.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success, authResponse: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // 1. Lấy GoogleAuthService
      final googleAuthService = ref.read(googleAuthServiceProvider);

      // 2. Sign in với Google → Nhận ID Token
      final idToken = await googleAuthService.signIn();

      if (idToken == null) {
        // User cancel hoặc có lỗi
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Google sign-in cancelled',
        );
        return false;
      }

      // 3. Gửi ID Token lên backend
      final result = await _repo.loginWithGoogle(idToken: idToken);

      // 4. Update state thành công
      state = state.copyWith(status: AuthStatus.success, authResponse: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _repo.register(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(status: AuthStatus.success, authResponse: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repo.forgotPassword(email: email);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

// ──────────────────────────────────────────────
//  Providers
// ──────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider with the actual instance',
  );
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiService(prefs);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepository(api, prefs);
});

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  final service = GoogleAuthService();
  service.initialize();
  return service;
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
