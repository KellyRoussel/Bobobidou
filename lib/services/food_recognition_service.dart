import 'dart:convert';
import 'dart:io';
import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FoodImageRecognitionService {
  final String apiUrlBase = '${AppConfig.backendUrl}/bobobidou/ingredients';
  final AuthService _authService = AuthService();


  /// Sends an image to the backend and returns a list of detected ingredients.
  /// Throws [SessionExpiredException] when the user has to login again.
  Future<List<String>> recognizeIngredientsFromImage(File imageFile, {String language = 'en'}) async {
    final token = await _authService.getValidToken();
    if (token == null) {
      throw SessionExpiredException();
    }

    var response = await _send(imageFile, language, token);

    // Token rejected (expired or revoked): renew it once and retry
    if (response.statusCode == 401) {
      final newToken = await _authService.getValidToken(forceRefresh: true);
      if (newToken == null) {
        throw SessionExpiredException();
      }
      response = await _send(imageFile, language, newToken);
      if (response.statusCode == 401) {
        await _authService.logout();
        throw SessionExpiredException();
      }
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('ingredients') && data['ingredients'] is List) {
        return List<String>.from(data['ingredients']);
      } else {
        throw Exception('Invalid response format from the server');
      }
    } else {
      throw Exception('Failed to recognize ingredients: ${response.statusCode}');
    }
  }

  Future<http.Response> _send(File imageFile, String language, String token) async {
    // Build full URL with query parameter
    final uri = Uri.parse(apiUrlBase).replace(queryParameters: {
      'language': language,
    });

    // Create multipart request
    final request = http.MultipartRequest('POST', uri);

    // Add the image file to the request (field must be named "file")
    final multipartFile = http.MultipartFile(
      'file', // <-- match the parameter name in FastAPI
      http.ByteStream(imageFile.openRead()),
      await imageFile.length(),
      filename: 'food_image.jpg',
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);
    request.headers['Authorization'] = 'Bearer $token';

    // Send the request
    final streamedResponse = await request.send();
    final responseBytes = await streamedResponse.stream.toBytes();
    final responseBody = utf8.decode(responseBytes); // Ensures UTF-8 decoding
    return http.Response(responseBody, streamedResponse.statusCode);
  }
}
