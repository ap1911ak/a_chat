class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}
