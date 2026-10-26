import 'api_client.dart';

/// The favorite islands of the logged-in user, kept in their account.
/// Only the token of a logged-in user can read and change them.
class FavoritesRepository {
  FavoritesRepository(this._api); // injected, not created here

  final ApiClient _api;

  Future<Set<String>> fetchIslandIds() async {
    final json = await _api.get('/v1/me/favorites') as Map<String, dynamic>;
    final islands = json['islands'] as List<dynamic>;
    return islands
        .map((island) => (island as Map<String, dynamic>)['id'] as String)
        .toSet();
  }

  // PUT and DELETE: repeating them does no harm.
  Future<void> add(String islandId) =>
      _api.put('/v1/me/favorites/islands/$islandId');

  Future<void> remove(String islandId) =>
      _api.delete('/v1/me/favorites/islands/$islandId');
}
