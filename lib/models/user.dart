/// A person with an account in this app.
class AppUser {
  const AppUser({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}

/// What login, register and refresh return: who it is and the two tokens.
class Session {
  const Session({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AppUser user;
  final String accessToken; // 15 minutes, only in memory
  final String refreshToken; // 30 days, to get a new access token

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
