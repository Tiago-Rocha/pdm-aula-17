import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/session_store.dart';
import '../models/user.dart';

/// Who is logged in. Knows the repository, not the widgets.
class SessionNotifier extends ChangeNotifier {
  SessionNotifier(this._auth, this._store); // injected

  final AuthRepository _auth;
  final SessionStore _store;

  Session? session;
  bool isRestoring = true; // until we know if there was a saved session
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => session != null;
  AppUser? get user => session?.user;

  /// On start: with a saved refresh token, ask for a new session.
  Future<void> restore() async {
    try {
      final saved = await _store.read();
      if (saved != null) session = await _auth.refresh(saved);
    } on ApiException {
      await _store.clear(); // expired, logged out or account deleted
    } catch (_) {
      // offline: show the login, keep the token for the next start
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) =>
      _start(() => _auth.login(email, password));

  Future<void> register(String name, String email, String password) =>
      _start(() => _auth.register(name, email, password));

  Future<void> logout() async {
    final old = session;
    session = null;
    notifyListeners(); // back to the login screen straight away
    await _store.clear();
    if (old == null) return;
    try {
      await _auth.logout(old.refreshToken);
    } catch (_) {
      // offline: the token expires on its own in 30 days
    }
  }

  /// Classroom tool: the next request goes with a broken token.
  void spoilToken() => _auth.spoilToken();

  Future<void> _start(Future<Session> Function() request) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final s = await request();
      await _store.save(s.refreshToken); // before the UI knows
      session = s;
    } on ApiException catch (e) {
      error = e.message; // the API already writes it in Portuguese
    } catch (_) {
      error = 'Sem ligação. Tenta de novo.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
