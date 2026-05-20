import 'package:dio/dio.dart';
import '../models/formula_model.dart';

abstract class FormulaRemoteDataSource {
  Future<List<FormulaModel>> getAllFormulas();
}

class FormulaRemoteDataSourceImpl implements FormulaRemoteDataSource {
  final Dio dio;

  FormulaRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FormulaModel>> getAllFormulas() async {
    final response = await dio.get('/formulas');

    if (response.statusCode == 200) {
      final List data = response.data['data']['formulas'];
      return data.map((json) => FormulaModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load formulas');
    }
  }
}
