import 'package:service_manager_front/src/services/http_service.dart';
import 'package:service_manager_front/src/tools/http_tool.dart';

class ServinsDataSource with HttpService {
  ServinsDataSource._();
  static final ServinsDataSource instance = ServinsDataSource._();
  factory ServinsDataSource() {
    return instance;
  }

  final _endpoint = "/servins";

  Future<Map<String, dynamic>> createServin(Map<String, dynamic> servin) async {
    final uri = HttpTools.generateUri(_endpoint);
    return await postQuery(uri, servin);
  }

  Future<Map<String, dynamic>> getAllServins() async {
    final uri = HttpTools.generateUri(_endpoint);
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> getServinById(String servinId) async {
    final uri = HttpTools.generateUri("$_endpoint/$servinId");
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> getServinByApiKeyAndNickname({required String apiKey, required String nickname}) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/nickname/$nickname",
      queryParameters: {'api_key': apiKey},
    );
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> updateServinById(String servinId, Map<String, dynamic> servin) async {
    final uri = HttpTools.generateUri("$_endpoint/$servinId");
    return await patchQuery(uri, body: servin);
  }

  Future<Map<String, dynamic>?> deleteServinById(String servinId) async {
    final uri = HttpTools.generateUri("$_endpoint/$servinId");
    return await deleteQuery(uri);
  }
}
