import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/modules/user/cubit/read_users_cubit.dart';
import 'package:service_manager_front/src/modules/user/cubit/write_users_cubit.dart';
import 'package:service_manager_front/src/modules/user/view/dialogs/user_editor_dialog.dart';
import 'package:service_manager_front/src/modules/user/view/dialogs/user_viewer_dialog.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRepo = context.read<UsersRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadUserCubit(
            usersRepository: usersRepo,
          )..getAll(),
        ),
        BlocProvider(
          create: (context) => WriteUserCubit(
            usersRepository: usersRepo,
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
        appBar: AppBar(
          title: const Text('Usuarios'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showUserEditorDialog(context);
          },
          child: const Icon(Icons.add),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadUserCubit, ReadUserState>(
      builder: (context, state) {
        if (state is ReadUserLoading || state is ReadUserInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReadUserError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        state as ReadUserSuccess;

        final users = state.items;
        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No hay usuarios registrados.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<ReadUserCubit>().getAll();
          },
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              final tileColor = index.isEven ? Colors.blueGrey.shade50 : Colors.white;
              final initial = user.username.isNotEmpty ? user.username.substring(0, 1).toUpperCase() : '?';

              return ListTile(
                tileColor: tileColor,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user.isActive ? 'Activo' : 'Inactivo'),
                trailing: Icon(
                  Icons.circle,
                  size: 12,
                  color: user.isActive ? Colors.green : Colors.red,
                ),
                onTap: () {
                  showUserViewerScreen(context, user: user);
                },
                onLongPress: () {
                  showUserEditorDialog(context, user: user);
                },
              );
            },
          ),
        );
      },
    );
  }
}
