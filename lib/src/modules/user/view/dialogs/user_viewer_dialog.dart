import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/users.dart';
import 'package:service_manager_front/src/modules/user/cubit/write_users_cubit.dart';
import 'package:service_manager_front/widgets/dialogs/dialog_manager.dart';
import 'package:service_manager_front/widgets/dialogs/loading_dialog.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showUserViewerScreen(BuildContext context, {required UserInDb user}) async {
  final writeCubit = context.read<WriteUserCubit>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: writeCubit,
        child: UserViewerScreen(user: user),
      ),
    ),
  );
}

class UserViewerScreen extends StatelessWidget {
  const UserViewerScreen({super.key, required this.user});
  final UserInDb user;

  String _formatDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final write = context.read<WriteUserCubit>();
    return BlocListener<WriteUserCubit, WriteUserState>(
      bloc: write,
      listener: (context, state) async {
        if (state is WritingUser) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteUserError) {
          LoadingDialogManager.closeLoadingDialog(context);
          if (!context.mounted) return;
          DialogManager.showErrorDialog(context, state.message);
        }
        if (state is UserDeleted) {
          LoadingDialogManager.closeLoadingDialog(context);
          if (!context.mounted) return;
          await DialogManager.showInfoDialog(context, 'Usuario eliminado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.username),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: "Compartir",
              onPressed: () {
                final String textToShare =
                    "Usuario: ${user.username}\n"
                    "Estado: ${user.isActive ? 'Activo' : 'Inactivo'}\n"
                    "Creado: ${_formatDate(user.createdAt)}";

                SharePlus.instance.share(
                  ShareParams(
                    text: textToShare,
                    subject: "Información de Usuario",
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: "Eliminar Usuario",
              onPressed: () async {
                final res = await DialogManager.confirmActionDialog(
                  context,
                  '¿Estás seguro de que deseas eliminar este usuario?',
                );
                if (res == true) {
                  if (!context.mounted) return;
                  write.delete(user.id);
                }
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
                _InfoRow(title: 'ID', value: user.id),
                const Divider(),
                _InfoRow(title: 'Nombre de Usuario', value: user.username),
                const Divider(),
                _InfoRow(
                  title: 'Fecha de Creación',
                  value: _formatDate(user.createdAt),
                ),
                if (user.updatedAt != null) ...[
                  const Divider(),
                  _InfoRow(
                    title: 'Última Actualización',
                    value: _formatDate(user.updatedAt!),
                  ),
                ],
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Estado Activo'),
                  trailing: Icon(
                    user.isActive ? Icons.check_circle : Icons.cancel,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});
  final String title;
  final String value;

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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
