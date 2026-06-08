import 'package:service_manager_front/src/data/data.dart';
import 'package:service_manager_front/src/domain/models/users.dart';

class LoginResult {
  final UserInDb user;
  final String accessToken;
  final String refreshToken;

  LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthsRepository {
  final AuthsDataSource authsDataSource;

  AuthsRepository(this.authsDataSource);

  Future<LoginResult> login(String username, String password) async {
    final result = await authsDataSource.login(username, password);
    final user = UserInDb.fromJson(result['user']);
    final accessToken = result['accessToken'] as String;
    final refreshToken = result['refreshToken'] as String;

    return LoginResult(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
