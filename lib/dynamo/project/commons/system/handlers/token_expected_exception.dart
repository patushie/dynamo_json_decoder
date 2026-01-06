class TokenExpectedException implements Exception {
  final String message;
  const TokenExpectedException(this.message);

  /// string representation of the class
  @override
  String toString() => 'TokenExpectedException: $message';
}
