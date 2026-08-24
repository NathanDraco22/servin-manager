import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/receipts.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/query_params/receipt_filter_params.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/modules/receipt/cubit/read_receipt_cubit.dart';
import 'package:service_manager_front/src/modules/receipt/cubit/write_receipt_cubit.dart';
import 'package:service_manager_front/src/modules/receipt/view/dialogs/receipt_editor_dialog.dart';
import 'package:service_manager_front/src/modules/receipt/view/dialogs/receipt_viewer_dialog.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final receiptsRepo = context.read<ReceiptsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadReceiptCubit(
            receiptsRepository: receiptsRepo,
          )..getAll(),
        ),
        BlocProvider(
          create: (context) => WriteReceiptCubit(
            receiptsRepository: receiptsRepo,
          ),
        ),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Recibos de Pago'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar',
              onPressed: () {
                context.read<ReadReceiptCubit>().getAll();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showReceiptEditorDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Recibo'),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<ServinInDb> _servins = [];
  String? _selectedServinId;
  bool _isLoadingServins = false;

  @override
  void initState() {
    super.initState();
    _loadServins();
  }

  Future<void> _loadServins() async {
    setState(() => _isLoadingServins = true);
    try {
      final servinsRepo = context.read<ServinsRepository>();
      final servins = await servinsRepo.getAllServins();
      if (mounted) {
        setState(() {
          _servins = servins;
          _isLoadingServins = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingServins = false);
      }
    }
  }

  void _onServinFilterChanged(String? servinId) {
    setState(() => _selectedServinId = servinId);
    context.read<ReadReceiptCubit>().getAll(
      filter: ReceiptFilterParams(servinId: servinId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          children: [
            // --- Barra Superior de Filtro por Servin ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedServinId,
                            isExpanded: true,
                            hint: const Text('Filtrar por Servin'),
                            icon: _isLoadingServins
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.arrow_drop_down),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Todos los Servins',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ..._servins.map(
                                (s) => DropdownMenuItem<String?>(
                                  value: s.id,
                                  child: Text(
                                    '${s.name} (@${s.nickname})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: _onServinFilterChanged,
                          ),
                        ),
                      ),
                      if (_selectedServinId != null) ...[
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Limpiar filtro',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _onServinFilterChanged(null),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // --- Lista de Recibos ---
            Expanded(
              child: BlocBuilder<ReadReceiptCubit, ReadReceiptState>(
                builder: (context, state) {
                  if (state is ReadReceiptLoading || state is ReadReceiptInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ReadReceiptError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            Text(
                              'Error: ${state.message}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<ReadReceiptCubit>().getAll(
                                filter: ReceiptFilterParams(servinId: _selectedServinId),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  state as ReadReceiptSuccess;
                  final receipts = state.items;

                  if (receipts.isEmpty) {
                    final hasFilter = _selectedServinId != null;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasFilter
                                  ? 'No hay recibos registrados para este Servin'
                                  : 'No hay recibos registrados aún',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            if (hasFilter) ...[
                              OutlinedButton.icon(
                                onPressed: () => _onServinFilterChanged(null),
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Ver Todos los Recibos'),
                              ),
                            ] else ...[
                              TextButton.icon(
                                onPressed: () => showReceiptEditorDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Crear Primer Recibo'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ReadReceiptCubit>().getAll(
                        filter: ReceiptFilterParams(servinId: _selectedServinId),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = receipts[index];
                        final isNew = state.newItems.contains(receipt);
                        final isUpdated = state.updatedItems.contains(receipt);

                        return _ReceiptCard(
                          receipt: receipt,
                          isNew: isNew,
                          isUpdated: isUpdated,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.receipt,
    this.isNew = false,
    this.isUpdated = false,
  });

  final ReceiptInDb receipt;
  final bool isNew;
  final bool isUpdated;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    Color? cardBorderColor;
    if (isNew) {
      cardBorderColor = Colors.green.shade400;
    } else if (isUpdated) {
      cardBorderColor = Colors.blue.shade400;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cardBorderColor ?? Colors.grey.shade200,
          width: cardBorderColor != null ? 1.5 : 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showReceiptViewerScreen(context, receipt: receipt),
        onLongPress: () => showReceiptEditorDialog(context, receipt: receipt),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header: Servin + Monto ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.servinName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${receipt.servinNickname} • ${receipt.ownerName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${receipt.amount}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blueGrey.shade200),
                        ),
                        child: Text(
                          receipt.paymentMethod,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // --- Footer: Período y Fecha de Pago ---
              Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 14,
                    color: Colors.teal.shade700,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Período: ${_formatDate(receipt.periodStartDate)}  ➔  ${_formatDate(receipt.periodEndDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ),
                  Text(
                    'Pago: ${_formatDate(receipt.paymentDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey.shade500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
