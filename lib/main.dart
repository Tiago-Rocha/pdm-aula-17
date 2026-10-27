import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_client.dart';
import 'data/auth_repository.dart';
import 'data/favorites_repository.dart';
import 'data/http_forecast_repository.dart';
import 'data/session_store.dart';
import 'screens/islands_screen.dart';
import 'screens/login_screen.dart';
import 'state/favorites_notifier.dart';
import 'state/forecast_notifier.dart';
import 'state/session_notifier.dart';
import 'state/settings.dart';

const clientId = String.fromEnvironment('CLIENT_ID');
const clientSecret = String.fromEnvironment('CLIENT_SECRET');

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin
  final settings = await Settings.load();
  final api = ApiClient(clientId: clientId, clientSecret: clientSecret);
  final session = SessionNotifier(AuthRepository(api), const SessionStore())
    ..restore();
  api.renewSession = session.renew; // on a 401, the ApiClient asks here
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(
          create: (_) => ForecastNotifier(HttpForecastRepository(api))..load(),
        ),
      ],
      child: Consumer<Settings>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Tempo Açores',
          theme: ThemeData(colorSchemeSeed: Colors.teal),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
          ),
          themeMode: settings.theme,
          home: _Home(FavoritesRepository(api)),
        ),
      ),
    ),
  );
}

/// While restoring, a spinner. Without a session, the login.
class _Home extends StatelessWidget {
  const _Home(this.favorites);

  final FavoritesRepository favorites;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionNotifier>();
    if (session.isRestoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!session.isLoggedIn) return const LoginScreen();
    // a new FavoritesNotifier at each login; the logout throws it away
    return ChangeNotifierProvider(
      create: (_) => FavoritesNotifier(favorites)..load(),
      child: const IslandsScreen(),
    );
  }
}
