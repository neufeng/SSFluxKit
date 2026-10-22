import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

class SSAuthState {
  const SSAuthState({
    this.initialized = false,
    this.user,
    this.loading = false,
    this.errorMessage,
  });

  final bool initialized;
  final SSUser? user;
  final bool loading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  SSAuthState copyWith({
    bool? initialized,
    SSUser? user,
    bool clearUser = false,
    bool? loading,
    String? errorMessage,
  }) {
    return SSAuthState(
      initialized: initialized ?? this.initialized,
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}

class SSAuthController extends StateNotifier<SSAuthState> {
  SSAuthController(this._ref) : super(const SSAuthState()) {
    _init();
  }

  final Ref _ref;

  SSAuthApi get _authApi => _ref.read(ssAuthApiProvider);
  SSAuthSession get _session => _ref.read(ssAuthSessionProvider);

  Future<void> _init() async {
    if (SSEnv.config.useMock) {
      state = const SSAuthState(initialized: true);
      return;
    }
    await _session.ensureLoaded();
    if (!_session.isAuthenticated) {
      state = const SSAuthState(initialized: true);
      return;
    }
    final me = await _authApi.me(accessToken: _session.accessToken!);
    if (me case SSSuccess(:final data)) {
      state = SSAuthState(initialized: true, user: data);
    } else {
      await _session.clear();
      state = const SSAuthState(initialized: true);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, errorMessage: null);
    final result = await _authApi.login(email: email, password: password);
    if (result case SSFailure(:final error)) {
      state = state.copyWith(loading: false, errorMessage: error.message);
      return false;
    }
    if (result case SSSuccess(:final data)) {
      await _session.setTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      );
      var user = data.user;
      if (user == null) {
        final me = await _authApi.me(accessToken: data.accessToken);
        user = me.dataOrNull;
      }
      state = SSAuthState(initialized: true, user: user, loading: false);
      return true;
    }
    state = state.copyWith(loading: false);
    return false;
  }

  Future<void> logout() async {
    final token = _session.accessToken;
    if (token != null) {
      await _authApi.logout(accessToken: token);
    }
    await _session.clear();
    state = const SSAuthState(initialized: true);
  }

  Future<void> onAccountDisabled() async {
    await _session.clear();
    state = const SSAuthState(
      initialized: true,
      errorMessage: '账号已被禁用，请重新登录',
    );
  }
}

final ssAuthControllerProvider =
    StateNotifierProvider<SSAuthController, SSAuthState>((ref) {
  return SSAuthController(ref);
});

final ssAuthRefreshListenableProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(ssAuthControllerProvider, (_, __) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});
