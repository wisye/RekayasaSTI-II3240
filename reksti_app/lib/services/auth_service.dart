// lib/features/auth/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:reksti_app/Exception.dart';
import 'package:reksti_app/services/token_service.dart';

class AuthService {
  //'http://103.59.160.119:3240/api'

  Future<String> loginUser(String username, String password) async {
    final url = Uri.parse('http://103.59.160.119:3240/api/login');
    final Map<String, String> fields = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: fields,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login successful: ${response.body}');

        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final String? accessToken = responseData['access_token'] as String?;
        final String? tokenType = responseData['token_type'] as String?;

        if (accessToken != null && tokenType != null) {
          final TokenStorageService tokenStorage = TokenStorageService();
          await tokenStorage.saveToken(accessToken, tokenType);
          await tokenStorage.saveUsername(username);
          print('Token saved successfully!');
        } else {
          print(
            'Error: Access token or token type is missing in the response.',
          );

          throw ServerException(
            message: 'Token data missing in server response.',
          );
        }
        return "ok";
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Login failed: ${response.statusCode} - ${response.body}');

        final errorData = json.decode(response.body);
        throw AuthenticationException(
          message: errorData['detail'] ?? 'Invalid credentials.',
        );
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        final errorData = json.decode(response.body);
        throw ServerException(
          message: errorData['detail'] ?? 'An error occurred on the server.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      print(
        'Network error during login: No Internet connection or server unreachable.',
      );
      throw NetworkException(
        message:
            'Could not connect to the server. Please check your internet connection.',
      );
    } catch (e) {
      print('Error making POST request: $e');

      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>?> registerUser(
    String username,
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse('http://103.59.160.119:3240/api/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Registration failed: ${response.statusCode} ${response.body}');
        final errorData = json.decode(response.body);
        throw ServerException(
          message: errorData['detail'] ?? 'An error occurred on the server.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error in AuthService.register: $e');

      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
