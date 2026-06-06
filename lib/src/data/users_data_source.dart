import 'package:service_manager_front/src/services/http_service.dart';
import 'package:service_manager_front/src/tools/http_tool.dart';

class UsersDataSource with HttpService {
  UsersDataSource._();
  static final UsersDataSource instance = UsersDataSource._();
  factory UsersDataSource() {
    return instance;
  }

  final _endpoint = "/users";

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) async {
    final uri = HttpTools.generateUri(_endpoint);
    return await postQuery(uri, user);
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    final uri = HttpTools.generateUri(_endpoint);
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final uri = HttpTools.generateUri("$_endpoint/$userId");
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final uri = HttpTools.generateUri("$_endpoint/by-username/$username");
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> updateUserById(
    String userId,
    Map<String, dynamic> user,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$userId");
    return await patchQuery(uri, body: user);
  }

  Future<Map<String, dynamic>?> deleteUserById(String userId) async {
    final uri = HttpTools.generateUri("$_endpoint/$userId");
    return await deleteQuery(uri);
  }
}
