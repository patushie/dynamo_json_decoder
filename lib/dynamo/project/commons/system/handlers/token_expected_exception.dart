class TokenExpectedException implements Exception {

  final String message;
  const TokenExpectedException(this.message);

  @override
  String toString() => 'TokenExpectedException: $message';

}