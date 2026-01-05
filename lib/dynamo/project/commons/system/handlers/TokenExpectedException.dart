class TokenExpectedException implements Exception {

  final String message;
  const TokenExpectedException(this.message);

  String toString() => 'TokenExpectedException: $message';

}