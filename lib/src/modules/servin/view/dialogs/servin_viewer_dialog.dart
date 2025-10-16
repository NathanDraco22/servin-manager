import 'package:flutter/material.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:share_plus/share_plus.dart';

// Función para navegar a la pantalla del visor
Future<void> showServinViewerScreen(BuildContext context, {required ServinInDb servin}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ServinViewerScreen(servin: servin),
    ),
  );
}

class ServinViewerScreen extends StatelessWidget {
  const ServinViewerScreen({super.key, required this.servin});
  final ServinInDb servin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(servin.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Compartir",
            onPressed: () {
              final String textToShare =
                  "Nombre: ${servin.name}\n"
                  "Alias: ${servin.nickname}\n"
                  "API Key: ${servin.apiKey}";

              SharePlus.instance.share(
                ShareParams(
                  text: textToShare,
                  subject: "Servin Information",
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(title: 'Nombre', value: servin.name),
              const Divider(),
              _InfoRow(title: 'Apodo o Alias', value: servin.nickname),
              const Divider(),
              _InfoRow(title: 'Api Key', value: servin.apiKey),
              const Divider(),
              _InfoRow(title: 'Nombre del Propietario', value: servin.ownerName),
              const Divider(),
              _InfoRow(title: 'URL', value: servin.url, isLink: true),
              const Divider(),
              _InfoRow(title: 'Precio', value: servin.price.toString()),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Multi-Sucursal'),
                trailing: Text(servin.isMultiBranch ? "Sí" : "No"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                trailing: Icon(
                  servin.isActive ? Icons.check_circle : Icons.cancel,
                  color: servin.isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para mostrar la información de forma consistente
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value, this.isLink = false});
  final String title;
  final String value;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isLink ? Colors.blue : null,
              decoration: isLink ? TextDecoration.underline : null,
              decorationColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
