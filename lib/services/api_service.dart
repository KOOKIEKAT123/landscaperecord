import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/landmark.dart';

const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

class ApiService {
  Future<List<Landmark>> getLandmarks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Landmark.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load landmarks (code: ${response.statusCode})');
    }
  }

  Future<int> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['title'] = title;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    
    // Determine MIME type based on file extension
    String mimeType = 'image/jpeg';
    final fileName = imageFile.path.toLowerCase();
    if (fileName.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (fileName.endsWith('.gif')) {
      mimeType = 'image/gif';
    } else if (fileName.endsWith('.webp')) {
      mimeType = 'image/webp';
    }
    
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path, contentType: http.MediaType.parse(mimeType)),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return int.parse(data['id'].toString());
    } else {
      // Log the response for debugging
      print('Upload failed. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create landmark (code: ${response.statusCode}) - ${response.body}');
    }
  }

  Future<void> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse(baseUrl));
    request.fields['id'] = id.toString();
    request.fields['title'] = title;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Failed to update landmark (code: ${response.statusCode})');
    }
  }

  Future<void> deleteLandmark(int id) async {
    // Many simple PHP APIs expect ID in body for DELETE
    final response = await http.delete(
      Uri.parse(baseUrl),
      body: {'id': id.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete landmark (code: ${response.statusCode})');
    }
  }
}
