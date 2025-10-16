part of 'write_servin_cubit.dart';

sealed class WriteServinState {}

final class WriteServinInitial extends WriteServinState {}

final class WriteServinInProgress extends WriteServinState {}

final class WriteServinSuccess extends WriteServinState {
  final ServinInDb servin;
  WriteServinSuccess(this.servin);
}

final class DeleteServinSuccess extends WriteServinState {
  final ServinInDb servin;
  DeleteServinSuccess(this.servin);
}

final class WriteServinError extends WriteServinState {
  final String error;
  WriteServinError(this.error);
}
