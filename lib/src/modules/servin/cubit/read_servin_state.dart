part of 'read_servin_cubit.dart';

sealed class ReadServinState {}

final class ReadServinInitial extends ReadServinState {}

final class ReadServinLoading extends ReadServinState {}

class ReadServinSuccess extends ReadServinState {
  final List<ServinInDb> servins;
  ReadServinSuccess(this.servins);
}

class HighlightedServin extends ReadServinSuccess {
  List<ServinInDb> newServins;
  List<ServinInDb> updatedServins;
  HighlightedServin(
    super.servins, {
    this.newServins = const [],
    this.updatedServins = const [],
  });
}

final class ReadServinError extends ReadServinState {
  final String message;
  ReadServinError(this.message);
}
