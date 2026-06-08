import 'package:service_manager_front/src/services/http_service.dart';
import 'package:service_manager_front/src/tools/http_tool.dart';

class AuthsDataSource with HttpService {
  AuthsDataSource._();
  static final AuthsDataSource instance = AuthsDataSource._();
  factory AuthsDataSource() {
    return instance;
  }

  final _endpoint = "/auths";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = HttpTools.generateUri("$_endpoint/login");
    return await postQuery(uri, {
      "username": username,
      "password": password,
    });
  }
}
