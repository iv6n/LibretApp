/// features \u203a eventos \u203a widgets \u203a event_form_sheet \u2014 bottom sheet form for creating/editing an event.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/widgets/event_constants.dart';

Future<void> showEventFormSheet({
  required BuildContext context,
  required DateTime initialDate,
  required void Function(Evento) onSave,
}) async {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final animalController = TextEditingController();
  DateTime fechaSeleccionada = initialDate;
  String tipoSeleccionado = eventTypes.first;
  String ubicacion = '';

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Programar nueva actividad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese un título'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: tipoSeleccionado,
                      items: eventTypes
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setModalState(
                        () => tipoSeleccionado = value ?? eventTypes.first,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: animalController,
                      decoration: const InputDecoration(
                        labelText: 'Animal / Lote (opcional)',
                        prefixIcon: Icon(Icons.pets_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ubicación (opcional)',
                        prefixIcon: Icon(Icons.place_outlined),
                        hintText: 'Ej: Potrero B',
                      ),
                      onChanged: (value) => ubicacion = value,
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha programada'),
                      subtitle: Text(
                        DateFormat(
                          'EEEE d MMMM, yyyy',
                        ).format(fechaSeleccionada),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => fechaSeleccionada = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final nuevo = Evento(
                            id: DateTime.now().microsecondsSinceEpoch
                                .toString(),
                            titulo: tituloController.text.trim(),
                            descripcion: descripcionController.text.trim(),
                            fecha: fechaSeleccionada,
                            tipo: tipoSeleccionado,
                            animalId: animalController.text.trim().isEmpty
                                ? 'Sin asignar'
                                : animalController.text.trim(),
                            ubicacion: ubicacion.trim().isEmpty
                                ? 'Sin ubicación'
                                : ubicacion.trim(),
                          );
                          onSave(nuevo);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Guardar evento'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
