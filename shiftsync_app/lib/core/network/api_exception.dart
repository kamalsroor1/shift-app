import 'package:dio/dio.dart';

/// ApiException — Arabic-friendly exception handler converting Dio HTTP failures
/// and network errors into clear medical personnel messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException('انتهي وقت الاتصال بخادم المستشفى. يرجى التحقق من الشبكة.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException('تعذر الاتصال بخادم شِفْتَك. يرجى التأكد من تشغيل الخادم والاتصال بالشبكة.');
    }

    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract detail from Pydantic / FastAPI response format
    String? detail;
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final d = data['detail'];
      if (d is String) {
        detail = d;
      } else if (d is List && d.isNotEmpty) {
        detail = d.first['msg']?.toString() ?? d.toString();
      }
    }

    if (statusCode == 400) {
      return ApiException(detail ?? 'طلب غير صالح أو تعارض في المواعيد المجدولة.', statusCode);
    } else if (statusCode == 401) {
      return ApiException(detail ?? 'بيانات الاعتماد غير صحيحة أو انتهت صلاحية الجلسة.', statusCode);
    } else if (statusCode == 403) {
      return ApiException(detail ?? 'ليس لديك صلاحية للقيام بهذا الإجراء في هذا القسم.', statusCode);
    } else if (statusCode == 404) {
      return ApiException(detail ?? 'العنصر المطلوب غير موجود في النظام.', statusCode);
    } else if (statusCode != null && statusCode >= 500) {
      return ApiException('حدث خطأ داخلي في خادم شِفْتَك. يرجى التواصل مع الدعم الفني.', statusCode);
    }

    return ApiException(detail ?? 'حدث خطأ غير متوقع في الاتصال بالنظام.', statusCode);
  }

  @override
  String toString() => message;
}
