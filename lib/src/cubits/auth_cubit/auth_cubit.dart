import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthsRepository authsRepository;

  AuthCubit({required this.authsRepository}) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final result = await authsRepository.login(username, password);
      if (isClosed) return;
      emit(AuthSuccess(result));
    } catch (error) {
      if (isClosed) return;
      emit(AuthError(error.toString()));
    }
  }
}
