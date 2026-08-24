import 'package:service_manager_front/src/domain/query_params/receipt_filter_params.dart';
import 'package:service_manager_front/src/services/http_service.dart';
import 'package:service_manager_front/src/tools/http_tool.dart';

class ReceiptsDataSource with HttpService {
  ReceiptsDataSource._();
  static final ReceiptsDataSource instance = ReceiptsDataSource._();
  factory ReceiptsDataSource() {
    return instance;
  }

  final _endpoint = "/receipts";

  Future<Map<String, dynamic>> createReceipt(Map<String, dynamic> receipt) async {
    final uri = HttpTools.generateUri(_endpoint);
    return await postQuery(uri, receipt);
  }

  Future<Map<String, dynamic>> getAllReceipts({ReceiptFilterParams? filter}) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: filter?.toMap(),
    );
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> getReceiptById(String receiptId) async {
    final uri = HttpTools.generateUri("$_endpoint/$receiptId");
    return await getQuery(uri);
  }

  Future<Map<String, dynamic>?> updateReceiptById(
    String receiptId,
    Map<String, dynamic> receipt,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$receiptId");
    return await patchQuery(uri, body: receipt);
  }

  Future<Map<String, dynamic>?> deleteReceiptById(String receiptId) async {
    final uri = HttpTools.generateUri("$_endpoint/$receiptId");
    return await deleteQuery(uri);
  }
}
