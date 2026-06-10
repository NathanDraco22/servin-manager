import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

part 'write_servin_state.dart';

class WriteServinCubit extends Cubit<WriteServinState> {
  WriteServinCubit({required this.servinsRepository}) : super(WriteServinInitial());

  final ServinsRepository servinsRepository;

  Future<void> create(CreateServin createServin) async {
    emit(WritingServin());
    try {
      final item = await servinsRepository.createServin(createServin);
      emit(ServinCreated(item));
      emit(WriteServinInitial());
    } catch (error) {
      emit(WriteServinError(error.toString()));
    }
  }

  Future<void> update(String servinId, UpdateServin servin) async {
    emit(WritingServin());
    try {
      final item = await servinsRepository.updateServinById(servinId, servin);
      emit(ServinUpdated(item!));
      emit(WriteServinInitial());
    } catch (error) {
      emit(WriteServinError(error.toString()));
    }
  }

  Future<void> delete(String servinId) async {
    emit(WritingServin());
    try {
      final item = await servinsRepository.deleteServinById(servinId);
      emit(ServinDeleted(item!));
      emit(WriteServinInitial());
    } catch (error) {
      emit(WriteServinError(error.toString()));
    }
  }
}
