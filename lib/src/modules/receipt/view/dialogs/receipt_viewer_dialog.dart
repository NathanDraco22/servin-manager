import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/receipts.dart';
import 'package:service_manager_front/src/modules/receipt/cubit/write_receipt_cubit.dart';
import 'package:service_manager_front/src/modules/receipt/view/dialogs/receipt_editor_dialog.dart';
import 'package:service_manager_front/widgets/dialogs/dialog_manager.dart';
import 'package:service_manager_front/widgets/dialogs/loading_dialog.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showReceiptViewerScreen(
  BuildContext context, {
  required ReceiptInDb receipt,
}) async {
  final writeCubit = context.read<WriteReceiptCubit>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: writeCubit,
        child: ReceiptViewerScreen(receipt: receipt),
      ),
    ),
  );
}

class ReceiptViewerScreen extends StatefulWidget {
  const ReceiptViewerScreen({super.key, required this.receipt});
  final ReceiptInDb receipt;

  @override
  State<ReceiptViewerScreen> createState() => _ReceiptViewerScreenState();
}

class _ReceiptViewerScreenState extends State<ReceiptViewerScreen> {
  final GlobalKey _receiptCardKey = GlobalKey();
  bool _isGeneratingImage = false;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _shareAsImage() async {
    setState(() => _isGeneratingImage = true);
    try {
      final boundary =
          _receiptCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('No se pudo encontrar la tarjeta del comprobante');
      }

      // Render at 3.0 pixel ratio for crystal-clear image quality (bank style)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('No se pudieron obtener los bytes de la imagen');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final String fileName =
          'comprobante_${widget.receipt.servinNickname}_${widget.receipt.id.length > 8 ? widget.receipt.id.substring(0, 8) : widget.receipt.id}.png';

      final xFile = XFile.fromData(
        pngBytes,
        mimeType: 'image/png',
        name: fileName,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Comprobante de Pago - ${widget.receipt.servinName}',
          subject: 'Comprobante de Pago - ${widget.receipt.servinName}',
        ),
      );
    } catch (e) {
      if (mounted) {
        DialogManager.showErrorDialog(
          context,
          'No se pudo generar la imagen del recibo: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImage = false);
      }
    }
  }

  void _shareAsText() {
    final r = widget.receipt;
    final notesText = (r.notes != null && r.notes!.isNotEmpty)
        ? 'Notas: ${r.notes}\n'
        : '';
    final String textToShare =
        '🧾 === COMPROBANTE DE PAGO ===\n'
        '🏢 Establecimiento: ${r.servinName} (@${r.servinNickname})\n'
        '👤 Propietario: ${r.ownerName}\n'
        '💰 Monto: \$${r.amount}\n'
        '📅 Fecha de Pago: ${_formatDate(r.paymentDate)}\n'
        '🗓️ Período: ${_formatDate(r.periodStartDate)} al ${_formatDate(r.periodEndDate)}\n'
        '💳 Método: ${r.paymentMethod}\n'
        '$notesText'
        '🔖 Folio: ${r.id}';

    SharePlus.instance.share(
      ShareParams(
        text: textToShare,
        subject: 'Comprobante de Pago - ${r.servinName}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receipt = widget.receipt;
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
        if (state is ReceiptDeleted) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, 'Recibo eliminado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Comprobante de Pago'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.text_snippet_outlined),
              tooltip: 'Compartir como Texto',
              onPressed: _shareAsText,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Recibo',
              onPressed: () {
                showReceiptEditorDialog(context, receipt: receipt);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Eliminar Recibo',
              onPressed: () async {
                final confirm = await DialogManager.confirmActionDialog(
                  context,
                  '¿Deseas eliminar este comprobante?',
                );
                if (confirm == true && context.mounted) {
                  context.read<WriteReceiptCubit>().delete(receipt.id);
                }
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  // --- RepaintBoundary para captura fotográfica bancaria ---
                  RepaintBoundary(
                    key: _receiptCardKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge de Estado Pagado
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PAGO REGISTRADO',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Monto Grande
                          Center(
                            child: Text(
                              '\$${receipt.amount}',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.blueGrey.shade900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Total del Servicio',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Línea divisoria segmentada (efecto ticket)
                          Row(
                            children: List.generate(
                              28,
                              (index) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  height: 1.5,
                                  color: index.isEven
                                      ? Colors.grey.shade300
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Sección Servin / Cliente ---
                          Container(
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.blueGrey.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
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
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Colors.blueGrey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              receipt.ownerName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blueGrey.shade700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '@${receipt.servinNickname}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Grid de Fechas y Método ---
                          Row(
                            children: [
                              Expanded(
                                child: _MetricTile(
                                  icon: Icons.calendar_today_rounded,
                                  title: 'Fecha de Pago',
                                  value: _formatDate(receipt.paymentDate),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricTile(
                                  icon: Icons.payment_rounded,
                                  title: 'Método de Pago',
                                  value: receipt.paymentMethod,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // --- Período Cubierto ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range_rounded,
                                  color: Colors.teal.shade800,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Período que Cubre',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_formatDate(receipt.periodStartDate)}  ➔  ${_formatDate(receipt.periodEndDate)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // --- Notas / Observaciones ---
                          if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.notes_rounded,
                                    size: 18,
                                    color: Colors.amber.shade900,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notas',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          receipt.notes!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blueGrey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),
                          const Divider(),
                          const SizedBox(height: 8),

                          // --- Folio / ID y Fecha de Emisión ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Folio ID',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        receipt.id.length > 12
                                            ? '${receipt.id.substring(0, 12)}...'
                                            : receipt.id,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 14),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Copiar ID',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: receipt.id));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('ID copiado al portapapeles'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Emitido el',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(receipt.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Botón Principal de Compartir Imagen ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingImage ? null : _shareAsImage,
                      icon: _isGeneratingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.image_outlined),
                      label: Text(
                        _isGeneratingImage ? 'Generando Comprobante...' : 'Compartir Imagen del Comprobante',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.blueGrey.shade500),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
