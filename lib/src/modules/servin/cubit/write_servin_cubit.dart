import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

part 'write_servin_state.dart';

class WriteServinCubit extends Cubit<WriteServinState> {
  WriteServinCubit({required this.servinsRepository}) : super(WriteServinInitial());

  final ServinsRepository servinsRepository;

  Future<void> createNewServin(CreateServin createServin) async {
    emit(WriteServinInProgress());
    try {
      final servin = await servinsRepository.createServin(createServin);
      emit(WriteServinSuccess(servin));
      emit(WriteServinInitial());
    } catch (error) {
      emit(WriteServinError(error.toString()));
    }
  }

  Future<void> updateServin(String servinId, UpdateServin updateServin) async {
    emit(WriteServinInProgress());
    try {
      final servin = await servinsRepository.updateServinById(servinId, updateServin);
      emit(WriteServinSuccess(servin!));
      emit(WriteServinInitial());
    } catch (error) {
      emit(WriteServinError(error.toString()));
    }
  }

  Future<void> deleteServin(String servinId) async {
    emit(WriteServinInProgress());
    try {
      final servin = await servinsRepository.deleteServinById(servinId);
      emit(DeleteServinSuccess(servin!));
      emit(WriteServinInitial());
    } catch (error) {
      emit(WriteServinError(error.toString()));
    }
  }
}
