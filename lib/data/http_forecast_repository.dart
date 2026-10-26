import '../models/forecast.dart';
import '../models/island.dart';
import 'api_client.dart';
import 'forecast_repository.dart';

/// How: HTTP to the course API, through the ApiClient.
class HttpForecastRepository implements ForecastRepository {
  HttpForecastRepository(this._api); // injected, not created here

  final ApiClient _api;

  @override
  Future<List<Island>> fetchIslands() async {
    final list = await _api.get('/v1/islands') as List<dynamic>;
    return list
        .map((item) => Island.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Forecast> fetchForecast(String islandId) async {
    final json = await _api.get('/v1/islands/$islandId/forecast');
    return Forecast.fromJson(json as Map<String, dynamic>);
  }
}
