import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/receipts.dart';
import 'package:service_manager_front/src/domain/query_params/receipt_filter_params.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/tools/reactive_repo/reactive_repository.dart';

part 'read_receipt_state.dart';

class ReadReceiptCubit extends Cubit<ReadReceiptState> {
  ReadReceiptCubit({required this.receiptsRepository})
      : super(ReadReceiptInitial()) {
    receiptsRepository.eventStream.listen((event) {
      if (event is RepoItemCreated<ReceiptInDb>) markReceiptCreated(event.item);
      if (event is RepoItemUpdated<ReceiptInDb>) markReceiptUpdated(event.item);
      if (event is RepoItemDeleted<ReceiptInDb>) markReceiptDeleted(event.item);
    });
  }

  final ReceiptsRepository receiptsRepository;
  ReceiptFilterParams? currentFilter;

  Future<void> getAll({ReceiptFilterParams? filter}) async {
    if (filter != null || currentFilter == null) {
      currentFilter = filter;
    }
    final currentState = state;
    if (currentState is ReadReceiptSuccess) {
      emit(ReadReceiptRefreshing.fromSuccess(currentState));
    } else {
      emit(ReadReceiptLoading());
    }
    try {
      final items = await receiptsRepository.getAllReceipts(filter: currentFilter);
      if (isClosed) return;
      emit(ReadReceiptSuccess(items));
    } catch (error) {
      if (isClosed) return;
      emit(ReadReceiptError(error.toString()));
    }
  }

  Future<void> getById(String receiptId) async {
    emit(ReadReceiptLoading());
    try {
      final item = await receiptsRepository.getReceiptById(receiptId);
      if (isClosed) return;
      if (item == null) {
        emit(ReadReceiptError('Recibo no encontrado'));
        return;
      }
      emit(ReadReceiptSuccess([item]));
    } catch (error) {
      if (isClosed) return;
      emit(ReadReceiptError(error.toString()));
    }
  }

  void markReceiptCreated(ReceiptInDb item) {
    if (currentFilter?.servinId != null &&
        currentFilter!.servinId!.isNotEmpty &&
        item.servinId != currentFilter!.servinId) {
      return;
    }
    final currentState = state;
    if (currentState is ReadReceiptSuccess) {
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadReceiptSuccess(
        items,
        newItems: newItems,
        updatedItems: currentState.updatedItems,
      ));
    }
  }

  void markReceiptUpdated(ReceiptInDb item) {
    if (currentFilter?.servinId != null &&
        currentFilter!.servinId!.isNotEmpty &&
        item.servinId != currentFilter!.servinId) {
      // If no longer matches the filter, remove it
      markReceiptDeleted(item);
      return;
    }
    final currentState = state;
    if (currentState is ReadReceiptSuccess) {
      final items = currentState.items.map((u) => u.id == item.id ? item : u).toList();
      final updatedItems = [...currentState.updatedItems, item];
      emit(ReadReceiptSuccess(
        items,
        newItems: currentState.newItems,
        updatedItems: updatedItems,
      ));
    }
  }

  void markReceiptDeleted(ReceiptInDb item) {
    final currentState = state;
    if (currentState is ReadReceiptSuccess) {
      final items = currentState.items.where((u) => u.id != item.id).toList();
      emit(ReadReceiptSuccess(
        items,
        newItems: currentState.newItems,
        updatedItems: currentState.updatedItems,
      ));
    }
  }
}
