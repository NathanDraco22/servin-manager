import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/users.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

part 'write_users_state.dart';

class WriteUserCubit extends Cubit<WriteUserState> {
  WriteUserCubit({required this.usersRepository}) : super(WriteUserInitial());

  final UsersRepository usersRepository;

  Future<void> create(CreateUser createUser) async {
    emit(WritingUser());
    try {
      final newUser = await usersRepository.createUser(createUser);
      if (isClosed) return;
      emit(UserCreated(newUser));
    } catch (error) {
      if (isClosed) return;
      emit(WriteUserError(error.toString()));
    }
  }

  Future<void> update(String userId, UpdateUser user) async {
    emit(WritingUser());
    try {
      final updatedUser = await usersRepository.updateUserById(userId, user);
      if (isClosed) return;
      if (updatedUser == null) {
        emit(WriteUserError('User not found'));
      } else {
        emit(UserUpdated(updatedUser));
      }
    } catch (error) {
      if (isClosed) return;
      emit(WriteUserError(error.toString()));
    }
  }

  Future<void> delete(String userId) async {
    emit(WritingUser());
    try {
      final deletedUser = await usersRepository.deleteUserById(userId);
      if (isClosed) return;
      if (deletedUser == null) {
        emit(WriteUserError('User not found'));
        return;
      }
      emit(UserDeleted(deletedUser));
    } catch (error) {
      if (isClosed) return;
      emit(WriteUserError(error.toString()));
    }
  }
}
