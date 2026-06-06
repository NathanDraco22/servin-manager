import 'package:service_manager_front/src/data/data.dart';
import 'package:service_manager_front/src/domain/models/users.dart';
import 'package:service_manager_front/src/domain/responses/list_responses.dart';
import 'package:service_manager_front/src/tools/reactive_repo/reactive_repository.dart';

class UsersRepository with ReactiveRepository<UserInDb> {
  final UsersDataSource usersDataSource;

  UsersRepository(this.usersDataSource);

  Future<UserInDb> createUser(CreateUser createUser) async {
    final result = await usersDataSource.createUser(createUser.toJson());
    final user = UserInDb.fromJson(result);
    notifyItemCreated(user);
    return user;
  }

  Future<List<UserInDb>> getAllUsers() async {
    final results = await usersDataSource.getAllUsers();
    final response = ListResponse<UserInDb>.fromJson(
      results,
      UserInDb.fromJson,
    );
    return response.data;
  }

  Future<UserInDb?> getUserById(String userId) async {
    final result = await usersDataSource.getUserById(userId);
    if (result == null) return null;
    return UserInDb.fromJson(result);
  }

  Future<UserInDb?> getUserByUsername(String username) async {
    final result = await usersDataSource.getUserByUsername(username);
    if (result == null) return null;
    return UserInDb.fromJson(result);
  }

  Future<UserInDb?> updateUserById(String userId, UpdateUser user) async {
    final result = await usersDataSource.updateUserById(userId, user.toJson());
    if (result == null) return null;
    final updatedUser = UserInDb.fromJson(result);
    notifyItemUpdated(updatedUser);
    return updatedUser;
  }

  Future<UserInDb?> deleteUserById(String userId) async {
    final result = await usersDataSource.deleteUserById(userId);
    if (result == null) return null;
    final deletedUser = UserInDb.fromJson(result);
    notifyItemDeleted(deletedUser);
    return deletedUser;
  }
}
