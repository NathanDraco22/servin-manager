import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/users.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/tools/reactive_repo/reactive_repository.dart';

part 'read_users_state.dart';

class ReadUserCubit extends Cubit<ReadUserState> {
  ReadUserCubit({
    required this.usersRepository,
  }) : super(ReadUserInitial()) {
    usersRepository.eventStream.listen(
      (event) {
        if (event is RepoItemCreated<UserInDb>) {
          markUserCreated(event.item);
        }
        if (event is RepoItemUpdated<UserInDb>) {
          markUserUpdated(event.item);
        }
        if (event is RepoItemDeleted<UserInDb>) {
          markUserDeleted(event.item);
        }
      },
    );
  }

  final UsersRepository usersRepository;

  Future<void> getAll() async {
    final currentState = state;
    if (currentState is ReadUserSuccess) {
      emit(ReadUserRefreshing.fromSuccess(currentState));
    } else {
      emit(ReadUserLoading());
    }

    try {
      final users = await usersRepository.getAllUsers();
      if (isClosed) return;
      emit(ReadUserSuccess(users));
    } catch (error) {
      if (isClosed) return;
      emit(ReadUserError(error.toString()));
    }
  }

  Future<void> getById(String userId) async {
    emit(ReadUserLoading());
    try {
      final user = await usersRepository.getUserById(userId);
      if (isClosed) return;
      if (user == null) {
        emit(ReadUserError('User not found'));
      } else {
        emit(ReadUserSuccess([user]));
      }
    } catch (error) {
      if (isClosed) return;
      emit(ReadUserError(error.toString()));
    }
  }

  void markUserCreated(UserInDb item) {
    final currentState = state;
    if (currentState is ReadUserSuccess) {
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadUserSuccess(items, newItems: newItems));
    }
  }

  void markUserUpdated(UserInDb item) {
    final currentState = state;
    if (currentState is ReadUserSuccess) {
      final items = currentState.items.map((u) => u.id == item.id ? item : u).toList();
      final updatedItems = [...currentState.updatedItems, item];
      emit(ReadUserSuccess(items, updatedItems: updatedItems));
    }
  }

  void markUserDeleted(UserInDb item) {
    final currentState = state;
    if (currentState is ReadUserSuccess) {
      final deletedItems = [...currentState.deletedItems, item];
      emit(ReadUserSuccess(currentState.items, deletedItems: deletedItems));
    }
  }
}
