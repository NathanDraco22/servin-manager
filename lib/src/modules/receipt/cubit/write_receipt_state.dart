part of 'write_receipt_cubit.dart';

sealed class WriteReceiptState {}

class WriteReceiptInitial extends WriteReceiptState {}

class WritingReceipt extends WriteReceiptState {}

class ReceiptCreated extends WriteReceiptState {
  final ReceiptInDb receipt;
  ReceiptCreated(this.receipt);
}

class ReceiptUpdated extends WriteReceiptState {
  final ReceiptInDb receipt;
  ReceiptUpdated(this.receipt);
}

class ReceiptDeleted extends WriteReceiptState {
  final ReceiptInDb receipt;
  ReceiptDeleted(this.receipt);
}

class WriteReceiptError extends WriteReceiptState {
  final String message;
  WriteReceiptError(this.message);
}
