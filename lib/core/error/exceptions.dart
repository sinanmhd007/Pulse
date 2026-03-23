class ServerException implements Exception {
  final String message;
  ServerException([this.message = "An unexpected error occurred. Please try again later."]);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = "Failed to load cached data."]);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "No internet connection."]);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
