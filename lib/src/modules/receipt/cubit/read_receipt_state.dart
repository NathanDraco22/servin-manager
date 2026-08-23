part of 'read_receipt_cubit.dart';

sealed class ReadReceiptState {}

final class ReadReceiptInitial extends ReadReceiptState {}

final class ReadReceiptLoading extends ReadReceiptState {}

class ReadReceiptSuccess extends ReadReceiptState {
  final List<ReceiptInDb> items;
  List<ReceiptInDb> newItems;
  List<ReceiptInDb> updatedItems;

  ReadReceiptSuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
  });
}

final class ReadReceiptRefreshing extends ReadReceiptSuccess {
  ReadReceiptRefreshing(
    super.items, {
    super.newItems,
    super.updatedItems,
  });

  factory ReadReceiptRefreshing.fromSuccess(
    ReadReceiptSuccess success,
  ) =>
      ReadReceiptRefreshing(
        success.items,
        newItems: success.newItems,
        updatedItems: success.updatedItems,
      );
}

final class ReadReceiptError extends ReadReceiptState {
  final String message;
  ReadReceiptError(this.message);
}
