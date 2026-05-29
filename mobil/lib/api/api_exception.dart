class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final Object? body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
