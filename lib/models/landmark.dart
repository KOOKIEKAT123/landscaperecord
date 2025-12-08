class Landmark {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String imageUrl;

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.imageUrl,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      imageUrl: json['image'] ?? '',
    );
  }
}
