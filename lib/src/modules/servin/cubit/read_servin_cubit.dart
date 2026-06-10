import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/tools/reactive_repo/reactive_repository.dart';

part 'read_servin_state.dart';

class ReadServinCubit extends Cubit<ReadServinState> {
  ReadServinCubit({required this.servinsRepository}) : super(ReadServinInitial()) {
    servinsRepository.eventStream.listen((event) {
      if (event is RepoItemCreated<ServinInDb>) markServinCreated(event.item);
      if (event is RepoItemUpdated<ServinInDb>) markServinUpdated(event.item);
      if (event is RepoItemDeleted<ServinInDb>) markServinDeleted(event.item);
    });
  }

  final ServinsRepository servinsRepository;

  Future<void> getAll() async {
    final currentState = state;
    if (currentState is ReadServinSuccess) {
      emit(ReadServinRefreshing.fromSuccess(currentState));
    } else {
      emit(ReadServinLoading());
    }
    try {
      final items = await servinsRepository.getAllServins();
      if (isClosed) return;
      emit(ReadServinSuccess(items));
    } catch (error) {
      if (isClosed) return;
      emit(ReadServinError(error.toString()));
    }
  }

  Future<void> getById(String servinId) async {
    emit(ReadServinLoading());
    try {
      final item = await servinsRepository.getServinById(servinId);
      if (isClosed) return;
      if (item == null) {
        emit(ReadServinError('Servin no encontrado'));
        return;
      }
      emit(ReadServinSuccess([item]));
    } catch (error) {
      if (isClosed) return;
      emit(ReadServinError(error.toString()));
    }
  }

  void markServinCreated(ServinInDb item) {
    final currentState = state;
    if (currentState is ReadServinSuccess) {
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadServinSuccess(items, newItems: newItems, updatedItems: currentState.updatedItems));
    }
  }

  void markServinUpdated(ServinInDb item) {
    final currentState = state;
    if (currentState is ReadServinSuccess) {
      final items = currentState.items.map((u) => u.id == item.id ? item : u).toList();
      final updatedItems = [...currentState.updatedItems, item];
      emit(ReadServinSuccess(items, newItems: currentState.newItems, updatedItems: updatedItems));
    }
  }

  void markServinDeleted(ServinInDb item) {
    final currentState = state;
    if (currentState is ReadServinSuccess) {
      final items = currentState.items.where((u) => u.id != item.id).toList();
      emit(ReadServinSuccess(items, newItems: currentState.newItems, updatedItems: currentState.updatedItems));
    }
  }
}
