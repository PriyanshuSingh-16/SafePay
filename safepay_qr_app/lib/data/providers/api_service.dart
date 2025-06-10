// safepay_qr/safepay_qr_app/lib/data/providers/api_service.dart
import 'package:dio/dio.dart';
import 'package:safepay_qr_app/utils/app_constants.dart'; // For API_BASE_URL

class ApiService {
  // Create a static instance for a singleton pattern to reuse the Dio client
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Initialize Dio with base options (base URL, timeouts)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants
        .API_BASE_URL, // Ensure this matches your backend URL (e.g., '[http://10.0.2.2:3000](http://10.0.2.2:3000)' for Android emulator or 'http://localhost:3000' for web/iOS simulator)
    connectTimeout: const Duration(seconds: 10), // 10 seconds for connection
    receiveTimeout: const Duration(seconds: 10), // 10 seconds for receiving data
  ));

  // Generic POST request method
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        // You might add headers here if authentication tokens are needed
        // options: Options(headers: {'Authorization': 'Bearer YOUR_AUTH_TOKEN'}),
      );
      // Ensure the response data is a Map
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        // If the backend sends a non-JSON response or unexpected type,
        // handle it here. For example, if it sends a plain string, you might
        // parse it or wrap it.
        return {'message': response.data.toString()};
      }
    } on DioException catch (e) {
      // DioError represents errors from Dio (network errors, bad HTTP responses)
      if (e.response != null) {
        // The server responded with a status code outside the 2xx range
        print('API Error: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception(
            'Server Error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print('Network Error: ${e.message}');
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      // Catch any other unexpected errors
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // You can add other HTTP methods (GET, PUT, DELETE) as needed
  // Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
  //   try {
  //     final response = await _dio.get(path, queryParameters: queryParameters);
  //     return response.data;
  //   } on DioError catch (e) {
  //     if (e.response != null) {
  //       throw Exception('Server Error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.statusMessage}');
  //     } else {
  //       throw Exception('Network Error: ${e.message}');
  //     }
  //   }
  // }
}

