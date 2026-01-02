import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      // استخدام رابط السيرفر الموحد من الثوابت
      baseUrl: AppConstants.apiBaseUrl,

      // استخدام مهلة الانتظار المحسنة (20 ثانية) لتناسب ظروف المنطقة
      connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // إضافة Interceptors لمعالجة الأخطاء وإضافة التوكن تلقائياً
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // هنا يمكن إضافة التوكن من SharedPreferences لكل طلب تلقائياً
        print("🚀 Sending Request: ${options.path}");
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print("❌ API Error: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  /// دالة جلب البيانات (GET)
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// دالة إرسال البيانات (POST)
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// دالة معالجة الأخطاء بشكل مفصل
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "انتهت مهلة الاتصال، يرجى التحقق من جودة الإنترنت.";
      case DioExceptionType.receiveTimeout:
        return "السيرفر لا يستجيب، حاول مرة أخرى لاحقاً.";
      case DioExceptionType.badResponse:
        return "خطأ من السيرفر: ${error.response?.statusCode}";
      case DioExceptionType.cancel:
        return "تم إلغاء الطلب.";
      default:
        return "حدث خطأ غير متوقع في الاتصال.";
    }
  }
}
