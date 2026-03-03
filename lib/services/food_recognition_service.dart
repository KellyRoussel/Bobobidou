import 'dart:convert';
import 'dart:io';
import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FoodImageRecognitionService {
  final String apiUrlBase = '${AppConfig.backendUrl}/bobobidou/ingredients';
  final AuthService _authService = AuthService();


  /// Sends an image to the backend and returns a list of detected ingredients
  Future<List<String>> recognizeIngredientsFromImage(File imageFile, {String language = 'en'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Build full URL with query parameter
      final uri = Uri.parse(apiUrlBase).replace(queryParameters: {
        'language': language,
      });

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add the image file to the request (field must be named "file")
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'file', // <-- match the parameter name in FastAPI
        fileStream,
        fileLength,
        filename: 'food_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);
      request.headers['Authorization'] = 'Bearer $token';


      // Send the request
      final streamedResponse = await request.send();
      final responseBytes = await streamedResponse.stream.toBytes();
      final responseBody = utf8.decode(responseBytes); // Ensures UTF-8 decoding
      final response = http.Response(responseBody, streamedResponse.statusCode);

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
    } catch (e) {
      throw Exception('Error recognizing ingredients: $e');
    }
  }
}
