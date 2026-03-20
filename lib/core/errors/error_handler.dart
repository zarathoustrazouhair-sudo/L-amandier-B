import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is PostgrestException) {
      return AppException(error.message, code: error.code, originalError: error);
    } else if (error is AuthException) {
      return AppException(error.message, code: error.statusCode, originalError: error);
    } else if (error is AppException) {
      return error;
    }
    return AppException('An unexpected error occurred.', originalError: error);
  }
}
