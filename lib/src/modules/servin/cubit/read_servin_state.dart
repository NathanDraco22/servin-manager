part of 'read_servin_cubit.dart';

sealed class ReadServinState {}

final class ReadServinInitial extends ReadServinState {}

final class ReadServinLoading extends ReadServinState {}

class ReadServinSuccess extends ReadServinState {
  final List<ServinInDb> items;
  List<ServinInDb> newItems;
  List<ServinInDb> updatedItems;

  ReadServinSuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
  });
}

final class ReadServinRefreshing extends ReadServinSuccess {
  ReadServinRefreshing(
    super.items, {
    super.newItems,
    super.updatedItems,
  });

  factory ReadServinRefreshing.fromSuccess(
    ReadServinSuccess success,
  ) =>
      ReadServinRefreshing(
        success.items,
        newItems: success.newItems,
        updatedItems: success.updatedItems,
      );
}

final class ReadServinError extends ReadServinState {
  final String message;
  ReadServinError(this.message);
}
