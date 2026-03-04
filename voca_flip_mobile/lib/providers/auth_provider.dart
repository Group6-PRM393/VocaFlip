import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';

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
  }) =>
      AuthState(
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
      state = state.copyWith(
        status: AuthStatus.success,
        authResponse: result,
      );
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
      final result =
          await _repo.register(name: name, email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.success,
        authResponse: result,
      );
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
      'Override sharedPreferencesProvider with the actual instance');
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

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
