import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/receipts.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/modules/receipt/cubit/write_receipt_cubit.dart';
import 'package:service_manager_front/widgets/dialogs/dialog_manager.dart';
import 'package:service_manager_front/widgets/dialogs/loading_dialog.dart';

Future<void> showReceiptEditorDialog(
  BuildContext context, {
  ReceiptInDb? receipt,
}) async {
  final writeCubit = context.read<WriteReceiptCubit>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: writeCubit,
        child: ReceiptEditorScreen(receipt: receipt),
      ),
    ),
  );
}

class ReceiptEditorScreen extends StatefulWidget {
  const ReceiptEditorScreen({super.key, this.receipt});
  final ReceiptInDb? receipt;

  @override
  State<ReceiptEditorScreen> createState() => _ReceiptEditorScreenState();
}

class _ReceiptEditorScreenState extends State<ReceiptEditorScreen> {
  final formKey = GlobalKey<FormState>();

  List<ServinInDb> _servins = [];
  bool _isLoadingServins = false;
  ServinInDb? _selectedServin;

  String? _servinId;
  String? _servinName;
  String? _servinNickname;
  String? _ownerName;
  int? _amount;
  DateTime _paymentDate = DateTime.now();
  DateTime _periodStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime _periodEndDate;
  String _paymentMethod = 'Transferencia';
  String? _notes;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _paymentMethods = [
    'Transferencia',
    'Efectivo',
    'Depósito',
    'Tarjeta',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    // Default period end is the last day of the current month
    _periodEndDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    if (widget.receipt != null) {
      final r = widget.receipt!;
      _servinId = r.servinId;
      _servinName = r.servinName;
      _servinNickname = r.servinNickname;
      _ownerName = r.ownerName;
      _amount = r.amount;
      _paymentDate = r.paymentDate;
      _periodStartDate = r.periodStartDate;
      _periodEndDate = r.periodEndDate;
      _paymentMethod = r.paymentMethod;
      _notes = r.notes;
      _amountController.text = r.amount.toString();
      _notesController.text = r.notes ?? '';
    } else {
      _loadServins();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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

  int get _paymentDay => _selectedServin?.paymentDate ?? 1;

  DateTime _calculatePeriodDate(int year, int month, int day) {
    final firstDay = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;
    final safeDay = day > lastDayOfMonth ? lastDayOfMonth : (day < 1 ? 1 : day);
    return DateTime(firstDay.year, firstDay.month, safeDay);
  }

  void _onServinSelected(ServinInDb? servin) {
    if (servin == null) return;
    final now = DateTime.now();
    final day = servin.paymentDate ?? 1;
    setState(() {
      _selectedServin = servin;
      _servinId = servin.id;
      _servinName = servin.name;
      _servinNickname = servin.nickname;
      _ownerName = servin.ownerName;
      _amount = servin.price;
      _amountController.text = servin.price.toString();
      _periodStartDate = _calculatePeriodDate(now.year, now.month, day);
      _periodEndDate = _calculatePeriodDate(now.year, now.month + 1, day);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  Future<void> _selectPeriodStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _periodStartDate = picked);
    }
  }

  Future<void> _selectPeriodEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _periodEndDate = picked);
    }
  }

  void _setPeriodCurrentMonth() {
    final now = DateTime.now();
    final day = _paymentDay;
    setState(() {
      _periodStartDate = _calculatePeriodDate(now.year, now.month, day);
      _periodEndDate = _calculatePeriodDate(now.year, now.month + 1, day);
    });
  }

  void _setPeriodNextMonth() {
    final now = DateTime.now();
    final day = _paymentDay;
    setState(() {
      _periodStartDate = _calculatePeriodDate(now.year, now.month + 1, day);
      _periodEndDate = _calculatePeriodDate(now.year, now.month + 2, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.receipt != null;
    final title = isEditing ? 'Editar Recibo' : 'Nuevo Recibo de Pago';
    final write = context.read<WriteReceiptCubit>();

    return BlocListener(
      bloc: write,
      listener: (context, state) async {
        if (state is WritingReceipt) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteReceiptError) {
          LoadingDialogManager.closeLoadingDialog(context);
          if (!context.mounted) return;
          DialogManager.showErrorDialog(context, state.message);
        }
        if (state is ReceiptCreated) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, 'Recibo creado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
        if (state is ReceiptUpdated) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, 'Recibo actualizado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            if (_servinId == null || _servinId!.isEmpty) {
              DialogManager.showErrorDialog(context, 'Por favor selecciona un Servin/Cliente');
              return;
            }

            final confirm = await DialogManager.confirmActionDialog(
              context,
              isEditing ? '¿Guardar cambios en el recibo?' : '¿Generar recibo de pago?',
            );
            if (confirm != true || !context.mounted) return;

            if (isEditing) {
              final update = UpdateReceipt(
                servinId: _servinId,
                servinName: _servinName,
                servinNickname: _servinNickname,
                ownerName: _ownerName,
                amount: _amount,
                periodStartDate: _periodStartDate,
                periodEndDate: _periodEndDate,
                paymentDate: _paymentDate,
                paymentMethod: _paymentMethod,
                notes: _notes,
              );
              context.read<WriteReceiptCubit>().update(widget.receipt!.id, update);
            } else {
              final create = CreateReceipt(
                servinId: _servinId!,
                servinName: _servinName!,
                servinNickname: _servinNickname!,
                ownerName: _ownerName!,
                amount: _amount ?? 0,
                periodStartDate: _periodStartDate,
                periodEndDate: _periodEndDate,
                paymentDate: _paymentDate,
                paymentMethod: _paymentMethod,
                notes: _notes,
              );
              context.read<WriteReceiptCubit>().create(create);
            }
          },
          label: const Text('Guardar Recibo'),
          icon: const Icon(Icons.save),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Servin / Cliente Selector ---
                if (!isEditing) ...[
                  if (_isLoadingServins)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    DropdownButtonFormField<ServinInDb>(
                      initialValue: _selectedServin,
                      decoration: const InputDecoration(
                        labelText: 'Servin / Cliente *',
                        prefixIcon: Icon(Icons.storefront_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _servins.map((s) {
                        return DropdownMenuItem<ServinInDb>(
                          value: s,
                          child: Text('${s.name} (${s.nickname})'),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null && (_servinId == null || _servinId!.isEmpty)) {
                          return 'Selecciona un Servin';
                        }
                        return null;
                      },
                      onChanged: _onServinSelected,
                    ),
                  const SizedBox(height: 16),
                ] else ...[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(_servinName ?? ''),
                    subtitle: Text('Propietario: $_ownerName • Alias: $_servinNickname'),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_ownerName != null && _ownerName!.isNotEmpty) ...[
                  _ReadonlyField(
                    label: 'Propietario / Cliente',
                    value: _ownerName!,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                ],

                // --- Monto ---
                TextFormField(
                  controller: _amountController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Monto del Pago *',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el monto';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _amount = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),

                // --- Fecha de Pago ---
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Fecha de Pago'),
                  subtitle: Text(_formatDate(_paymentDate)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _selectPaymentDate,
                ),
                const SizedBox(height: 16),

                // --- Periodo Cubierto ---
                Card(
                  elevation: 0,
                  color: Colors.blueGrey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blueGrey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Período que Cubre',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Row(
                              children: [
                                ActionChip(
                                  label: const Text('Este Mes'),
                                  onPressed: _setPeriodCurrentMonth,
                                ),
                                const SizedBox(width: 6),
                                ActionChip(
                                  label: const Text('Próx. Mes'),
                                  onPressed: _setPeriodNextMonth,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectPeriodStartDate,
                                icon: const Icon(Icons.date_range, size: 18),
                                label: Text('Inicio: ${_formatDate(_periodStartDate)}'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectPeriodEndDate,
                                icon: const Icon(Icons.event, size: 18),
                                label: Text('Fin: ${_formatDate(_periodEndDate)}'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Método de Pago ---
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethods.contains(_paymentMethod) ? _paymentMethod : _paymentMethods.first,
                  decoration: const InputDecoration(
                    labelText: 'Método de Pago',
                    prefixIcon: Icon(Icons.payment_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _paymentMethods.map((m) {
                    return DropdownMenuItem<String>(
                      value: m,
                      child: Text(m),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _paymentMethod = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // --- Notas / Observaciones ---
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas / Observaciones',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _notes = value.trim();
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
