import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_messages.dart';
import 'package:voca_flip_mobile/core/utils/error_message_utils.dart';
import 'package:voca_flip_mobile/features/auth/models/auth_model.dart';
import 'package:voca_flip_mobile/features/auth/repositories/auth_repository.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/profile/providers/user_provider.dart';
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

  String _formatErrorMessage(Object error) {
    return ErrorMessageUtils.normalize(
      error,
      fallback: AppMessages.genericActionFailed,
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _repo.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success, authResponse: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // 1. Get GoogleAuthService
      final googleAuthService = ref.read(googleAuthServiceProvider);

      // 2. Sign in with Google and get ID token
      final idToken = await googleAuthService.signIn();

      if (idToken == null) {
        // User cancelled sign-in or an error occurred
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage: AuthMessages.googleSignInCancelled,
        );
        return false;
      }

      // 3. Send ID token to backend
      final result = await _repo.loginWithGoogle(idToken: idToken);

      // 4. Update state on success
      state = state.copyWith(status: AuthStatus.success, authResponse: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _formatErrorMessage(e),
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
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repo.requestOtp(email: email);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> requestOtp({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repo.requestOtp(email: email);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repo.verifyOtp(email: email, otpCode: otpCode);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repo.resetPassword(
        email: email,
        otpCode: otpCode,
        newPassword: newPassword,
      );
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    // Clear old profile cache so the next logged-in user is fetched fresh.
    ref.invalidate(currentUserProfileProvider);
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
