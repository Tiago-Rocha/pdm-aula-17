import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/favorites_repository.dart';

/// The favorite islands of whoever is logged in. It only exists while
/// there is a session: created at login, thrown away at logout.
class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier(this._repository); // injected, not created here

  final FavoritesRepository _repository;

  Set<String> ids = {};
  String? error;

  bool isFavorite(String islandId) => ids.contains(islandId);

  Future<void> load() async {
    try {
      ids = await _repository.fetchIslandIds();
      error = null;
    } catch (e) {
      error = _message(e);
    }
    notifyListeners();
  }

  /// Waits for the API, then changes the heart.
  Future<void> toggle(String islandId) async {
    try {
      if (isFavorite(islandId)) {
        await _repository.remove(islandId);
        ids.remove(islandId);
      } else {
        await _repository.add(islandId);
        ids.add(islandId);
      }
      error = null;
    } catch (e) {
      error = _message(e);
    }
    notifyListeners();
  }

  String _message(Object e) =>
      e is ApiException ? '$e' : 'Sem ligação. Tenta de novo.';
}
