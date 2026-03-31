import 'package:dio/dio.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://harold-lobby-flood-liable.trycloudflare.com/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => print(o),
    ));
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
