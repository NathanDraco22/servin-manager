import 'package:flutter/material.dart';

class DialogManager {
  static Future<void> showErrorDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          icon: Icon(Icons.error, color: Colors.red.shade300),
          content: Text(message),
          actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        );
      },
    );
  }

  static Future<void> showInfoDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          icon: Icon(Icons.info, color: Colors.blue.shade300),
          actions: [TextButton(autofocus: true, child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        );
      },
    );
  }

  static Future<bool> confirmActionDialog(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Accion'),
          content: Text(message),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade300),
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              autofocus: true,
              style: TextButton.styleFrom(foregroundColor: Colors.green.shade300),
              child: const Text('Aceptar'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
