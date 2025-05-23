// lib/features/auth/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reksti_app/services/token_service.dart';
import 'package:reksti_app/Exception.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LogicService {
  //'http://103.59.160.119:3240/api'; // Define your base URL
  final TokenStorageService tokenStorage = TokenStorageService();
  // This is your postData function, now as a method of AuthService

  Future<dynamic> getOrder() async {
    // Renamed for clarity
    final url = Uri.parse('http://103.59.160.119:3240/api/orders');

    String? token = await tokenStorage.getAccessToken();
    String? tokenType = await tokenStorage.getTokenType();

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': '$tokenType $token',
    };

    if (token == null || tokenType == null) {
      print("No token found. User needs to log in.");
      throw AuthenticationException(
        message: "Not authenticated. Please log in.",
      );
    }

    if (JwtDecoder.isExpired(token)) {
      print("Access token has expired. Please log in again.");
      await tokenStorage.deleteAllTokens();
      throw AuthenticationException(
        message: "Session expired. Please log in again.",
      );
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('Get orders failed: ${response.statusCode} - ${response.body}');
        // Consider throwing a custom exception or returning a specific error object
        throw ServerException(message: 'Error in server response.');
      }
    } catch (e) {
      print('Error making POST request: $e');
      // Consider throwing a custom exception
      return null;
    }
  }
}
