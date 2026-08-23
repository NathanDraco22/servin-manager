import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/receipts.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

part 'write_receipt_state.dart';

class WriteReceiptCubit extends Cubit<WriteReceiptState> {
  WriteReceiptCubit({required this.receiptsRepository})
      : super(WriteReceiptInitial());

  final ReceiptsRepository receiptsRepository;

  Future<void> create(CreateReceipt createReceipt) async {
    emit(WritingReceipt());
    try {
      final item = await receiptsRepository.createReceipt(createReceipt);
      emit(ReceiptCreated(item));
      emit(WriteReceiptInitial());
    } catch (error) {
      emit(WriteReceiptError(error.toString()));
    }
  }

  Future<void> update(String receiptId, UpdateReceipt receipt) async {
    emit(WritingReceipt());
    try {
      final item = await receiptsRepository.updateReceiptById(receiptId, receipt);
      emit(ReceiptUpdated(item!));
      emit(WriteReceiptInitial());
    } catch (error) {
      emit(WriteReceiptError(error.toString()));
    }
  }

  Future<void> delete(String receiptId) async {
    emit(WritingReceipt());
    try {
      final item = await receiptsRepository.deleteReceiptById(receiptId);
      emit(ReceiptDeleted(item!));
      emit(WriteReceiptInitial());
    } catch (error) {
      emit(WriteReceiptError(error.toString()));
    }
  }
}
