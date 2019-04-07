

class AuthenticationException implements Exception {
  String cause;
  AuthenticationException(this.cause);
}

class ServerException implements Exception {
  String cause;
  ServerException(this.cause);
}

class InvalidContentException implements Exception {
  String cause;
  InvalidContentException(this.cause);
}