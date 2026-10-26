import 'package:flutter/foundation.dart';

import '../data/forecast_repository.dart';
import '../models/island.dart';

/// The state of the islands screen. Knows the repository, not the widgets.
class ForecastNotifier extends ChangeNotifier {
  ForecastNotifier(this._repository); // injected, not created here

  final ForecastRepository _repository;

  bool isLoading = false;
  String? error;
  List<Island> islands = const [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners(); // the screen shows the spinner
    try {
      islands = await _repository.fetchIslands();
    } catch (e) {
      error = '$e';
    } finally {
      isLoading = false;
      notifyListeners(); // the screen shows the islands or the error
    }
  }
}
