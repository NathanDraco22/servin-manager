import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/users.dart';
import 'package:service_manager_front/src/modules/user/cubit/read_users_cubit.dart';
import 'package:service_manager_front/src/modules/user/cubit/write_users_cubit.dart';
import 'package:service_manager_front/widgets/dialogs/dialog_manager.dart';
import 'package:service_manager_front/widgets/dialogs/loading_dialog.dart';

Future<void> showUserEditorDialog(BuildContext context, {UserInDb? user}) async {
  final readCubit = context.read<ReadUserCubit>();
  final writeCubit = context.read<WriteUserCubit>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: readCubit),
          BlocProvider.value(value: writeCubit),
        ],
        child: UserEditorScreen(
          user: user,
        ),
      ),
    ),
  );
}

class UserEditorScreen extends StatefulWidget {
  const UserEditorScreen({
    super.key,
    this.user,
  });

  final UserInDb? user;

  @override
  State<UserEditorScreen> createState() => _UserEditorScreenState();
}

class _UserEditorScreenState extends State<UserEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late UpdateUser updateUser;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.user == null) {
      updateUser = UpdateUser(
        username: '',
        password: '',
        isActive: true,
      );
    } else {
      updateUser = UpdateUser.fromJson(widget.user!.toJson());
      // Dejamos la contraseña en nulo inicialmente para la edición para no sobrescribirla
      updateUser.password = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    final title = isEditing ? "Editar Usuario" : "Crear Nuevo Usuario";
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

        if (state is UserCreated || state is UserUpdated) {
          LoadingDialogManager.closeLoadingDialog(context);
          if (!context.mounted) return;
          await DialogManager.showInfoDialog(context, 'Guardado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final isValidate = formKey.currentState!.validate();
              if (!isValidate) return;

              final res = await DialogManager.confirmActionDialog(context, '¿Guardar cambios?');
              if (res != true) return;

              if (!context.mounted) return;
              if (!isEditing) {
                // Para creación se requiere obligatoriamente password
                final createUser = CreateUser(
                  username: updateUser.username!,
                  password: updateUser.password!,
                  isActive: updateUser.isActive ?? true,
                );
                context.read<WriteUserCubit>().create(createUser);
              } else {
                context.read<WriteUserCubit>().update(widget.user!.id, updateUser);
              }
            },
            label: const Text('Guardar'),
            icon: const Icon(Icons.save),
          ),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Nombre de Usuario ---
                    TextFormField(
                      initialValue: updateUser.username,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Usuario',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        updateUser.username = value.trim();
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Contraseña ---
                    TextFormField(
                      initialValue: updateUser.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: isEditing ? 'Nueva Contraseña (dejar en blanco para no cambiar)' : 'Contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        // En creación el password es obligatorio
                        if (!isEditing && (value == null || value.isEmpty)) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isEmpty) {
                          updateUser.password = isEditing ? null : '';
                        } else {
                          updateUser.password = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Activo ---
                    SwitchListTile(
                      title: const Text('Usuario Activo'),
                      subtitle: const Text('Permitir el acceso al sistema'),
                      value: updateUser.isActive ?? true,
                      onChanged: (bool value) {
                        setState(() {
                          updateUser.isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
