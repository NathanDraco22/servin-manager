import 'package:flutter/material.dart';
import 'package:service_manager_front/src/modules/login/view/logins_view.dart';
import 'package:service_manager_front/src/modules/receipt/view/receipt_screen.dart';
import 'package:service_manager_front/src/modules/servin/view/servin_screen.dart';
import 'package:service_manager_front/src/modules/user/view/users_view.dart';
import 'package:service_manager_front/widgets/dialogs/dialog_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Manager'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final confirm = await DialogManager.confirmActionDialog(
                context,
                '¿Deseas cerrar la sesión?',
              );
              if (confirm == true && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginsScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        children: [
          _MenuCard(
            icon: Icons.storefront_rounded,
            color: Colors.indigo,
            title: 'Servins (Clientes)',
            subtitle: 'Administración, configuración y activación de instancias',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServinScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.receipt_long_rounded,
            color: Colors.teal,
            title: 'Recibos de Pago',
            subtitle: 'Registro y control de pagos y períodos por Servin',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReceiptScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.people_alt_rounded,
            color: Colors.blueGrey,
            title: 'Usuarios',
            subtitle: 'Gestión de operadores y accesos del Service Manager',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }
}
