# pdm-aula-17 · Tokens and favourites kept in the account

Repository for lesson 17 of PDM (Mobile Device Programming), CTeSP DAW, ESTA, University of the Azores, 2026/27.

Tempo Açores with the islands from the course API (`https://api-pdm.sublimecipher.com`) and user accounts, as in lesson 16. Now each island has a heart, and the favourite islands are kept in the person's account on the server: log in on another phone or browser and they are there.

```
lib/
  main.dart                          loads the settings, puts the pieces together
  models/
    island.dart                      Island
    forecast.dart                    WeatherType, DayForecast, Forecast
    user.dart                        AppUser, Session
  data/
    api_client.dart                  HTTP: tokens, headers, status codes, JSON
    forecast_repository.dart         what the app can ask for (the interface)
    http_forecast_repository.dart    how: asks the API, returns Island
    auth_repository.dart             login, register, refresh, logout
    favorites_repository.dart        GET, PUT and DELETE on /v1/me/favorites
    session_store.dart               refresh token in secure storage
  state/
    forecast_notifier.dart           loading, error and islands
    session_notifier.dart            who is logged in
    favorites_notifier.dart          the favourite islands of who is logged in
    settings.dart                    last email and theme (shared_preferences)
  screens/
    islands_screen.dart              the islands with a heart each, theme, logout
    login_screen.dart                log in or create an account
```

## Two tokens

The API gives out two kinds of access token, and both go in `Authorization: Bearer`:

| Token | How you get it | Lasts | What it opens |
|---|---|---|---|
| The app's | `POST /v1/auth/token` with `clientId` and `clientSecret` | 1 hour | Islands, forecasts, warnings: data that is the same for everyone |
| The user's | `POST /v1/auth/login` or `/v1/auth/register` | 15 minutes | Everything above, plus `/v1/me` and `/v1/me/favorites`: data of one person |

With the app's token, `/v1/me/favorites` answers `403`: the API knows which app is asking, but not which person.

## Getting started

```bash
git clone https://github.com/Tiago-Rocha/pdm-aula-17.git
cd pdm-aula-17
flutter pub get
flutter run -d chrome --dart-define=CLIENT_ID=pdm-ab12cd --dart-define=CLIENT_SECRET=your-secret
```

Your `clientId` and `clientSecret` are in issue #1 of your `pdm-miniprojeto` repository (or, for the group project, in issue #1 of your group's repository). They go on the command line, never in the code and never in git. Pressing F5 in VS Code does not pass them. Keep the `flutter run` command on one line: PowerShell does not accept `\` to split it.

Create an account or log in. On `main` you see the islands, and above them a red banner: `403: Este pedido é de um utilizador...`. That is the starting point. In the terminal where `flutter run` is running, `r` is hot reload, `R` is hot restart and `q` quits. Open a second terminal for the `git` commands.

## The steps

There is one branch per step. `main` is the starting point; `passo-2` is the final state. Each step is a `TODO` with its number in the code.

| Step | Branch | What you do | In the app |
|---|---|---|---|
| 1 | `passo-1` | `lib/data/api_client.dart`: when someone is logged in, requests go with the user's token instead of the app's (`TODO 1`). | The 403 is gone. Tap a heart, stop the app with `q`, run it again: the heart is still red. |
| 2 | `passo-2` | `lib/data/api_client.dart`: on a `401`, ask the session for a new access token with the refresh token and repeat the request once; `lib/state/session_notifier.dart`: `renew()`; `lib/main.dart` connects the two (`TODO 2`). | Tap the bug button ("Estragar o token"), then a heart: it still works. |

The bug button only exists in debug builds (`kDebugMode`). It replaces the user's access token with a broken one, so you get a `401` without waiting 15 minutes.

## Syncing with the lesson

At the end of each step, finished or not, run the commands on the slide, one at a time, in the second terminal. They put aside what you wrote and give you the code of that step:

```bash
git stash -u
git checkout passo-1
flutter pub get
```

Then press `R` in the `flutter run` terminal (hot restart).

To go back to the start: `git stash -u` and then `git checkout main`. To see a step in one place: `git diff main passo-1` and `git diff passo-1 passo-2`.

## Where things are kept

| What | Where | Why |
|---|---|---|
| Refresh token | `flutter_secure_storage` (Keychain on iOS, Keystore on Android) | It is a password that lasts 30 days. |
| User's access token | memory only (`ApiClient.userToken`) | It lasts 15 minutes; a new one comes from the refresh token. |
| App's access token | memory only | It lasts 1 hour; a new one comes from `clientId` and `clientSecret`. |
| Favourite islands | the server, in the person's account | They follow the person to any phone. |
| Last email, theme | `shared_preferences` | Small, not secret, needed on the first frame. |

The texts on screen are in Portuguese, like the app in the project; the code and the comments are in English.

API documentation: https://api-pdm.sublimecipher.com/docs

Teacher's content licensed CC BY-NC-SA 4.0.
