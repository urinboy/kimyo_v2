import 'package:dio/dio.dart';
import '../models/mine_model.dart';

abstract class MineRemoteDataSource {
  Future<List<MineModel>> getAllMines();
}

class MineRemoteDataSourceImpl implements MineRemoteDataSource {
  final Dio dio;

  MineRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MineModel>> getAllMines() async {
    final response = await dio.get('/mines');

    if (response.statusCode == 200) {
      final List data = response.data['data']['mines'];
      return data.map((json) => MineModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mines');
    }
  }
}
