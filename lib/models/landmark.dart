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
    
    return Landmark(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      imageUrl: imagePath,
    );
  }
}
