import 'package:http/http.dart' as http;
import 'dart:convert';

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _apiKey = 'UCmh756Dghtg3A5yrGav4ut83Y02Ze04N18P5M05L20';

  Future<String> fetchImage(String placeName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/photos/random?query=$placeName&client_id=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['urls']['regular'];
    } else {
      throw Exception('Failed to load image');
    }
  }
}
