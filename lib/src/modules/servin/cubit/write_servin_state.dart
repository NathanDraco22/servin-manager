part of 'write_servin_cubit.dart';

sealed class WriteServinState {}

final class WriteServinInitial extends WriteServinState {}

final class WritingServin extends WriteServinState {}

sealed class WriteServinSuccess extends WriteServinState {
  final ServinInDb item;
  WriteServinSuccess(this.item);
}

final class ServinCreated extends WriteServinSuccess {
  ServinCreated(super.item);
}

final class ServinUpdated extends WriteServinSuccess {
  ServinUpdated(super.item);
}

final class ServinDeleted extends WriteServinSuccess {
  ServinDeleted(super.item);
}

final class WriteServinError extends WriteServinState {
  final String message;
  WriteServinError(this.message);
}
