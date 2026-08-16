import 'package:dio/dio.dart';

class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.github.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/vnd.github+json'},
        ),
      );

  final Dio dio;
}
