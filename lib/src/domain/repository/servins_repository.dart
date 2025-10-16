import 'package:service_manager_front/src/data/data.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/responses/list_responses.dart';

class ServinsRepository {
  final ServinsDataSource servinsDataSource;

  ServinsRepository(this.servinsDataSource);

  Future<ServinInDb> createServin(CreateServin createServin) async {
    final result = await servinsDataSource.createServin(createServin.toJson());
    return ServinInDb.fromJson(result);
  }

  Future<List<ServinInDb>> getAllServins() async {
    final results = await servinsDataSource.getAllServins();
    final response = ListResponse<ServinInDb>.fromJson(
      results,
      ServinInDb.fromJson,
    );
    return response.data;
  }

  Future<ServinInDb?> getServinById(String servinId) async {
    final result = await servinsDataSource.getServinById(servinId);
    if (result == null) return null;
    return ServinInDb.fromJson(result);
  }

  Future<ServinInDb?> getServinByApiKeyAndNickname({required String apiKey, required String nickname}) async {
    final result = await servinsDataSource.getServinByApiKeyAndNickname(
      apiKey: apiKey,
      nickname: nickname,
    );
    if (result == null) return null;
    return ServinInDb.fromJson(result);
  }

  Future<ServinInDb?> updateServinById(String servinId, UpdateServin servin) async {
    final result = await servinsDataSource.updateServinById(servinId, servin.toJson());
    if (result == null) return null;
    return ServinInDb.fromJson(result);
  }

  Future<ServinInDb?> deleteServinById(String servinId) async {
    final result = await servinsDataSource.deleteServinById(servinId);
    if (result == null) return null;
    return ServinInDb.fromJson(result);
  }
}
