class ErrorDetail {
  final String? field;
  final String message;
  final dynamic value;

  ErrorDetail({this.field, required this.message, this.value});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      field: json['field'],
      message: json['message'] ?? '',
      value: json['value'],
    );
  }
}

class ApiException implements Exception {
  final String code;
  final String message;
  final List<ErrorDetail>? details;
  final int? statusCode;

  ApiException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException[$code]: $message';
}
