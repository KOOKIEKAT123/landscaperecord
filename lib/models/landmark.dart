class Landmark {
  static const String _baseUrl = 'https://labs.anontech.info/cse489/t3/';

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
    String imagePath = json['image'] ?? '';

    // If the image path doesn't start with http, prepend the base URL
    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      imagePath = _baseUrl + imagePath;
    }

    // API sometimes returns empty strings; guard parsing to avoid FormatException
    final latValue = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
    final lonValue = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;

    return Landmark(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      lat: latValue,
      lon: lonValue,
      imageUrl: imagePath,
    );
  }
}
