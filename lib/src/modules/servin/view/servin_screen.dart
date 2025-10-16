import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/modules/servin/cubit/read_servin_cubit.dart';
import 'package:service_manager_front/src/modules/servin/cubit/write_servin_cubit.dart';
import 'package:service_manager_front/src/modules/servin/view/dialogs/servin_editor_dialog.dart';
import 'package:service_manager_front/src/modules/servin/view/dialogs/servin_viewer_dialog.dart';

class ServinScreen extends StatelessWidget {
  const ServinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servinRepo = context.read<ServinsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadServinCubit(
            servinsRepository: servinRepo,
          )..loadAllServins(),
        ),
        BlocProvider(
          create: (context) => WriteServinCubit(
            servinsRepository: servinRepo,
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
        appBar: AppBar(title: const Text('Servins')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showServinEditorServinDialog(context);
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
    return BlocBuilder<ReadServinCubit, ReadServinState>(
      builder: (context, state) {
        if (state is ReadServinLoading || state is ReadServinInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReadServinError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        state as ReadServinSuccess;

        final servins = state.servins;
        return ListView.separated(
          itemCount: servins.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final servin = servins[index];
            final tileColor = index.isEven ? Colors.blueGrey.shade100 : Colors.white;
            return ListTile(
              tileColor: tileColor,
              leading: CircleAvatar(
                child: Text(servin.name.substring(0, 1)),
              ),
              title: Text(servin.name),
              subtitle: Text('Propietario: ${servin.ownerName}'),
              trailing: Icon(
                Icons.circle,
                size: 12,
                color: servin.isActive ? Colors.green : Colors.red,
              ),
              onTap: () {
                showServinViewerScreen(context, servin: servin);
              },
              onLongPress: () {
                showServinEditorServinDialog(context, servin: servin);
              },
            );
          },
        );
      },
    );
  }
}
