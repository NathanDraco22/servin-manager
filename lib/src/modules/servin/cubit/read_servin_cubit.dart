import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

part 'read_servin_state.dart';

class ReadServinCubit extends Cubit<ReadServinState> {
  ReadServinCubit({required this.servinsRepository}) : super(ReadServinInitial());

  final ServinsRepository servinsRepository;
  List<ServinInDb> _servinsCache = [];

  Future<void> loadAllServins() async {
    emit(ReadServinLoading());
    try {
      final servins = await servinsRepository.getAllServins();
      _servinsCache = servins;
      if (isClosed) return;
      emit(ReadServinSuccess(servins));
    } catch (error) {
      if (isClosed) return;
      emit(ReadServinError(error.toString()));
    }
  }

  void searchServin(String keyword) {
    if (keyword.isEmpty) {
      emit(ReadServinSuccess(_servinsCache));
      return;
    }
    final filteredList = _servinsCache.where((servin) {
      return servin.name.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
    emit(ReadServinSuccess(filteredList));
  }

  Future<void> putServinFirst(ServinInDb servin) async {
    _servinsCache = [servin, ..._servinsCache];
    final currentState = state;
    if (currentState is! ReadServinSuccess) return;

    if (currentState is HighlightedServin) {
      emit(
        HighlightedServin(
          _servinsCache,
          newServins: [servin, ...currentState.newServins],
          updatedServins: currentState.updatedServins,
        ),
      );
    } else {
      emit(HighlightedServin(_servinsCache, newServins: [servin]));
    }
  }

  Future<void> markServinUpdated(ServinInDb servin) async {
    final index = _servinsCache.indexWhere((s) => s.id == servin.id);
    if (index != -1) _servinsCache[index] = servin;

    final currentState = state;
    if (currentState is! ReadServinSuccess) return;

    if (currentState is HighlightedServin) {
      emit(
        HighlightedServin(
          _servinsCache,
          newServins: currentState.newServins,
          updatedServins: [servin, ...currentState.updatedServins],
        ),
      );
    } else {
      emit(HighlightedServin(_servinsCache, updatedServins: [servin]));
    }
  }

  Future<void> removeServin(ServinInDb servin) async {
    _servinsCache.removeWhere((s) => s.id == servin.id);
    emit(ReadServinSuccess(_servinsCache));
  }
}
