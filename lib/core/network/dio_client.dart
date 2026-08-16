import 'package:dio/dio.dart';

class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.github.com',

          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),

          headers: {'Accept': 'application/vnd.github+json'},

          validateStatus: (status) {
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

  final Dio dio;
}
