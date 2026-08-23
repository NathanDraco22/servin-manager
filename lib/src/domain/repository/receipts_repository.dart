import 'package:service_manager_front/src/data/data.dart';
import 'package:service_manager_front/src/domain/models/receipts.dart';
import 'package:service_manager_front/src/domain/responses/list_responses.dart';
import 'package:service_manager_front/src/tools/reactive_repo/reactive_repository.dart';

class ReceiptsRepository with ReactiveRepository<ReceiptInDb> {
  final ReceiptsDataSource receiptsDataSource;

  ReceiptsRepository(this.receiptsDataSource);

  Future<ReceiptInDb> createReceipt(CreateReceipt createReceipt) async {
    final result = await receiptsDataSource.createReceipt(createReceipt.toJson());
    final receipt = ReceiptInDb.fromJson(result);
    notifyItemCreated(receipt);
    return receipt;
  }

  Future<List<ReceiptInDb>> getAllReceipts() async {
    final results = await receiptsDataSource.getAllReceipts();
    final response = ListResponse<ReceiptInDb>.fromJson(
      results,
      ReceiptInDb.fromJson,
    );
    return response.data;
  }

  Future<ReceiptInDb?> getReceiptById(String receiptId) async {
    final result = await receiptsDataSource.getReceiptById(receiptId);
    if (result == null) return null;
    return ReceiptInDb.fromJson(result);
  }

  Future<ReceiptInDb?> updateReceiptById(String receiptId, UpdateReceipt receipt) async {
    final result = await receiptsDataSource.updateReceiptById(receiptId, receipt.toJson());
    if (result == null) return null;
    final updatedReceipt = ReceiptInDb.fromJson(result);
    notifyItemUpdated(updatedReceipt);
    return updatedReceipt;
  }

  Future<ReceiptInDb?> deleteReceiptById(String receiptId) async {
    final result = await receiptsDataSource.deleteReceiptById(receiptId);
    if (result == null) return null;
    final deletedReceipt = ReceiptInDb.fromJson(result);
    notifyItemDeleted(deletedReceipt);
    return deletedReceipt;
  }
}
