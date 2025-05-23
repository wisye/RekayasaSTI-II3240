// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  final int? statusCode; // Optional: to store the HTTP status code

  ServerException({required this.message, this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException: $statusCode - $message';
    }
    return 'ServerException: $message';
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException({
    this.message = "A network error occurred. Please check your connection.",
  });

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException({
    this.message = "Authentication failed. Please check your credentials.",
  });

  @override
  String toString() => 'AuthenticationException: $message';
}
