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
    // Use POST with 'action' or 'method' field set to 'update' if API expects it
    // But try PUT first as some APIs support it
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['id'] = id.toString();
    request.fields['title'] = title;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    // Some APIs use a method/action field to distinguish create vs update
    request.fields['method'] = 'update';

    if (imageFile != null) {
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
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      print('Update failed. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update landmark (code: ${response.statusCode}) - ${response.body}');
    }
  }

  Future<void> deleteLandmark(int id) async {
    // Send ID as query parameter
    final response = await http.delete(
      Uri.parse('$baseUrl?id=$id'),
    );

    if (response.statusCode != 200) {
      print('Delete failed. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete landmark (code: ${response.statusCode}) - ${response.body}');
    }
  }
}
