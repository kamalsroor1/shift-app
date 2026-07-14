import 'package:dio/dio.dart';

/// ApiException — Arabic error handler for FastAPI HTTP responses.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioException(DioException error) {
    // Network/timeout errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException('⏱ انتهى وقت الاتصال. يرجى التحقق من الشبكة والمحاولة مجدداً.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        '📡 تعذر الاتصال بخادم شِفْتَك.\n'
        'تأكد من تشغيل الخادم على المنفذ 8000.',
      );
    }

    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract FastAPI / Pydantic error detail
    String? detail;
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final d = data['detail'];
      if (d is String) {
        detail = d;
      } else if (d is List && d.isNotEmpty) {
        detail = d.first['msg']?.toString() ?? d.toString();
      }
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          detail ?? '⚠️ طلب غير صالح. تحقق من البيانات المدخلة.',
          statusCode,
        );
      case 401:
        return ApiException(
          '🔐 رقم الهاتف أو كلمة المرور غير صحيحة.\n'
          'تأكد من البيانات أو استخدم زر الدخول التجريبي.',
          statusCode,
        );
      case 403:
        return ApiException(
          '🚫 ليس لديك صلاحية للقيام بهذا الإجراء في هذا القسم.',
          statusCode,
        );
      case 404:
        return ApiException(
          detail ?? '🔍 العنصر المطلوب غير موجود في النظام.',
          statusCode,
        );
      case 409:
        return ApiException(
          detail ?? '⚡ تعارض في البيانات — ربما تم تسجيل هذه العملية مسبقاً.',
          statusCode,
        );
      case 422:
        return ApiException(
          detail ?? '📋 بيانات غير مكتملة أو تنسيق خاطئ. راجع الحقول المطلوبة.',
          statusCode,
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            '🛠 حدث خطأ داخلي في خادم شِفْتَك. يرجى التواصل مع الدعم الفني.',
            statusCode,
          );
        }
    }

    return ApiException(
      detail ?? '❌ حدث خطأ غير متوقع في الاتصال بالنظام.',
      statusCode,
    );
  }

  /// Returns true if this is a 401 unauthorized error (session expired)
  bool get isUnauthorized => statusCode == 401;

  /// Returns true if this is a 404 not found (no data, not a real error)
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}
