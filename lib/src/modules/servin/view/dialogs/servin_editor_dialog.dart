import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';
import 'package:service_manager_front/widgets/dialogs/dialog_manager.dart';
import 'package:service_manager_front/widgets/dialogs/loading_dialog.dart';

import '../../cubit/write_servin_cubit.dart';

Future<void> showServinEditorServinDialog(BuildContext context, {ServinInDb? servin}) async {
  final writeCubit = context.read<WriteServinCubit>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: writeCubit,
        child: ServinCreationScreen(
          servin: servin,
        ),
      ),
    ),
  );
}

class ServinCreationScreen extends StatefulWidget {
  const ServinCreationScreen({
    super.key,
    this.servin,
  });

  final ServinInDb? servin;

  @override
  State<ServinCreationScreen> createState() => _ServinCreationScreenState();
}

class _ServinCreationScreenState extends State<ServinCreationScreen> {
  final formKey = GlobalKey<FormState>();

  late UpdateServin updateServin;

  @override
  void initState() {
    super.initState();
    if (widget.servin == null) {
      updateServin = UpdateServin()
        ..isActive = true
        ..isMultiBranch = false
        ..isUsingExpirationDate = true;

      return;
    }
    updateServin = UpdateServin.fromJson(widget.servin!.toJson());
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.servin == null ? "Crear Nuevo Servin" : "Editar Servin";
    final write = context.read<WriteServinCubit>();
    return BlocListener(
      bloc: write,
      listener: (context, state) async {
        if (state is WritingServin) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteServinError) {
          LoadingDialogManager.closeLoadingDialog(context);
          if (!context.mounted) return;
          DialogManager.showErrorDialog(context, state.message);
        }
        if (state is ServinCreated) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, 'Guardado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
        if (state is ServinUpdated) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, 'Actualizado exitosamente');
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

              final res = await DialogManager.confirmActionDialog(context, 'Guardar cambios?');
              if (res == false) return;

              if (!context.mounted) return;
              if (widget.servin == null) {
                final createServin = CreateServin.fromJson(updateServin.toJson());
                context.read<WriteServinCubit>().create(createServin);
              } else {
                context.read<WriteServinCubit>().update(widget.servin!.id, updateServin);
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
                    // --- Name ---
                    TextFormField(
                      initialValue: updateServin.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },

                      onChanged: (value) {
                        updateServin.name = value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Nickname ---
                    TextFormField(
                      initialValue: updateServin.nickname,
                      textInputAction: TextInputAction.next,

                      decoration: const InputDecoration(
                        labelText: 'Apodo o Alias',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        updateServin.nickname = value.trim();
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Owner Name ---
                    TextFormField(
                      initialValue: updateServin.ownerName,
                      textInputAction: TextInputAction.next,

                      decoration: const InputDecoration(
                        labelText: 'Nombre del Propietario',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        updateServin.ownerName = value.trim();
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Type ---
                    AbsorbPointer(
                      absorbing: updateServin.type != null,
                      child: DropdownButtonFormField<ServinType>(
                        initialValue: updateServin.type,
                        items: ServinType.values
                            .map(
                              (e) => DropdownMenuItem<ServinType>(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          updateServin.type = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- URL ---
                    TextFormField(
                      initialValue: updateServin.url,
                      textInputAction: TextInputAction.next,

                      decoration: const InputDecoration(
                        labelText: 'URL',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        updateServin.url = value.trim();
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Price ---
                    TextFormField(
                      initialValue: (updateServin.price ?? 0).toString(),
                      textInputAction: TextInputAction.done,

                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número';
                        }

                        if (int.parse(value) < 1) {
                          return 'Debe ser un número positivo';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isEmpty) {
                          updateServin.price = 0;
                          return;
                        }
                        if (int.tryParse(value) == null) {
                          updateServin.price = 0;
                          return;
                        }
                        updateServin.price = int.parse(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Payment Date (Día de pago) ---
                    TextFormField(
                      initialValue: updateServin.paymentDate?.toString() ?? '',
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Día de Pago Mensual (Opcional, 1 - 31)',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        helperText: 'Ej: 5 para cobros del 5 al 5 de cada mes. Si está vacío, usa el día 1.',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final day = int.tryParse(value);
                        if (day == null || day < 1 || day > 31) {
                          return 'Debe ser un día válido (1 a 31)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          updateServin.paymentDate = null;
                          return;
                        }
                        updateServin.paymentDate = int.tryParse(value);
                      },
                    ),
                    const SizedBox(height: 8),

                    // --- isMultiBranch ---
                    SwitchListTile(
                      title: const Text('¿Es Multi-Sucursal?'),
                      value: updateServin.isMultiBranch ?? false,
                      onChanged: (bool value) {
                        updateServin.isMultiBranch = value;
                        setState(() {});
                      },
                    ),

                    // --- isUsingExpirationDate ---
                    SwitchListTile(
                      title: const Text('¿Usa Fecha de Expiración?'),
                      value: updateServin.isUsingExpirationDate ?? true,
                      onChanged: (bool value) {
                        updateServin.isUsingExpirationDate = value;
                        setState(() {});
                      },
                    ),

                    // --- isActive ---
                    SwitchListTile(
                      title: const Text('Activo'),
                      value: updateServin.isActive ?? true,
                      onChanged: (bool value) {
                        updateServin.isActive = value;
                        setState(() {});
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
