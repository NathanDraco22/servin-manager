import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';
import 'package:service_manager_front/src/modules/servin/cubit/read_servin_cubit.dart';
import 'package:service_manager_front/src/modules/servin/cubit/write_servin_cubit.dart';
import 'package:service_manager_front/src/modules/servin/view/dialogs/servin_editor_dialog.dart';
import 'package:service_manager_front/src/modules/servin/view/dialogs/servin_viewer_dialog.dart';
import 'package:service_manager_front/src/modules/servin/view/servin_type_visuals.dart';

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
          )..getAll(),
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
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Servins (Establecimientos)'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar',
              onPressed: () {
                context.read<ReadServinCubit>().getAll();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showServinEditorServinDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Servin'),
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
                    onPressed: () => context.read<ReadServinCubit>().getAll(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        state as ReadServinSuccess;
        final servins = state.items;

        if (servins.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay Servins registrados aún',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => showServinEditorServinDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Primer Servin'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<ReadServinCubit>().getAll();
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: servins.length,
                itemBuilder: (context, index) {
                  final servin = servins[index];
                  final isNew = state.newItems.contains(servin);
                  final isUpdated = state.updatedItems.contains(servin);

                  return _ServinCard(
                    servin: servin,
                    isNew: isNew,
                    isUpdated: isUpdated,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ServinCard extends StatelessWidget {
  const _ServinCard({
    required this.servin,
    this.isNew = false,
    this.isUpdated = false,
  });

  final ServinInDb servin;
  final bool isNew;
  final bool isUpdated;

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
        onTap: () => showServinViewerScreen(context, servin: servin),
        onLongPress: () => showServinEditorServinDialog(context, servin: servin),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header: Icono + Nombre + Badge Activo ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: servin.type.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: servin.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          servin.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '@${servin.nickname}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                servin.ownerName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Badge Activo / Inactivo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: servin.isActive
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: servin.isActive
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: servin.isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          servin.isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: servin.isActive
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // --- Fila Inferior de Datos: Precio, Día de Cobro, Sistema ---
              Row(
                children: [
                  // Precio Mensual
                  Text(
                    '\$${servin.price}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  Text(
                    ' /mes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade500,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Día de Pago
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          servin.paymentDate != null
                              ? 'Día ${servin.paymentDate}'
                              : 'Día 1',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tipo de Servin
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: servin.type.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: servin.type.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          servin.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: servin.type.darkTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
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
