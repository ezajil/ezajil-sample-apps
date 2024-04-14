class APIError implements Exception {
  final int status;
  final String message;
  final dynamic details;

  APIError(this.status, this.message, [this.details]);

  @override
  String toString() {
    return 'APIError: $message (Status: $status, Details: $details)';
  }
}
