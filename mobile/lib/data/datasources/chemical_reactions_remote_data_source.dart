import 'package:dio/dio.dart';

import '../models/chemical_reaction_models.dart';

abstract class ChemicalReactionsRemoteDataSource {
  Future<ChemicalReactionsBundle> fetchAll();
}

class ChemicalReactionsRemoteDataSourceImpl
    implements ChemicalReactionsRemoteDataSource {
  ChemicalReactionsRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<ChemicalReactionsBundle> fetchAll() async {
    final response = await dio.get('/chemical-reactions');
    if (response.statusCode != 200) {
      throw StateError('chemical-reactions ${response.statusCode}');
    }
    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw StateError('chemical-reactions: bad envelope');
    }
    final inner = raw['data'] as Map<String, dynamic>? ?? raw;
    final typesJson = inner['reaction_types'] as List<dynamic>? ?? [];
    final symbolsJson = inner['reaction_symbols'] as List<dynamic>? ?? [];
    return ChemicalReactionsBundle(
      types: typesJson
          .map((e) => ChemicalReactionTypeDto.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      symbols: symbolsJson
          .map((e) => ChemicalReactionSymbolDto.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
