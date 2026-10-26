import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/favorites_notifier.dart';
import '../state/forecast_notifier.dart';
import '../state/session_notifier.dart';
import '../state/settings.dart';

/// Draws the state of the notifiers. Knows no URLs, no JSON, no tokens.
class IslandsScreen extends StatelessWidget {
  const IslandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = context.watch<ForecastNotifier>(); // rebuilds on notify
    final favorites = context.watch<FavoritesNotifier>();
    final user = context.watch<SessionNotifier>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user?.name ?? ''}'),
        actions: [
          if (kDebugMode) // classroom tool, never in a release build
            IconButton(
              tooltip: 'Estragar o token',
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => context.read<SessionNotifier>().spoilToken(),
            ),
          IconButton(
            tooltip: 'Tema',
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final settings = context.read<Settings>();
              final next = settings.theme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              settings.saveTheme(next);
            },
          ),
          IconButton(
            tooltip: 'Terminar sessão',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<SessionNotifier>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (favorites.error != null)
            MaterialBanner(
              content: Text(favorites.error!),
              actions: [
                TextButton(
                  onPressed: favorites.load,
                  child: const Text('Tentar de novo'),
                ),
              ],
            ),
          Expanded(child: _body(context, forecast, favorites)),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ForecastNotifier forecast,
    FavoritesNotifier favorites,
  ) {
    if (forecast.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (forecast.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(forecast.error!),
            TextButton(
              onPressed: () => context.read<ForecastNotifier>().load(),
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: forecast.islands.length,
      itemBuilder: (context, i) {
        final island = forecast.islands[i];
        final favorite = favorites.isFavorite(island.id);
        return ListTile(
          leading: Image.network(island.imageUrl, width: 56),
          title: Text(island.name),
          trailing: IconButton(
            tooltip: favorite ? 'Tirar das favoritas' : 'Marcar como favorita',
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? Colors.red : null,
            ),
            onPressed: () => favorites.toggle(island.id),
          ),
        );
      },
    );
  }
}
