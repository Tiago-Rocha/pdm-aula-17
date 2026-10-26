class Island {
  const Island({required this.id, required this.name, required this.imageUrl});

  final String id;
  final String name;
  final String imageUrl;

  factory Island.fromJson(Map<String, dynamic> json) {
    return Island(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}
