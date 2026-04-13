class ValidationResponse {
  const ValidationResponse({
    required this.allowed,
    required this.message,
    required this.statusCode,
  });

  final bool allowed;
  final String message;
  final int statusCode;

  factory ValidationResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    return ValidationResponse(
      allowed: json['allowed'] == true,
      message: (json['message'] as String?) ?? 'Sin mensaje del servidor',
      statusCode: statusCode,
    );
  }

  factory ValidationResponse.fallback(int statusCode, String message) {
    return ValidationResponse(
      allowed: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
