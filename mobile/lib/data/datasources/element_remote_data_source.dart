import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/element_model.dart';
import 'element_response_parser.dart';

abstract class ElementRemoteDataSource {
  Future<List<ElementModel>> getAllElements();
}

class ElementRemoteDataSourceImpl implements ElementRemoteDataSource {
  final Dio dio;

  ElementRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ElementModel>> getAllElements() async {
    final response = await dio.get<List<int>>(
      '/elements',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    final code = response.statusCode ?? 0;
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.unknown,
        message: 'elements: bo‘sh javob',
      );
    }

    final raw = utf8.decode(bytes, allowMalformed: true);

    if (code != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'elements: HTTP $code',
      );
    }

    try {
      return parseElementsResponseBody(raw);
    } on FormatException catch (e) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: e.message,
        error: e,
      );
    }
  }
}
