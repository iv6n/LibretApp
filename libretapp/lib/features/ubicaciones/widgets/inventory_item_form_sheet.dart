/// features › ubicaciones › widgets › inventory_item_form_sheet — bottom sheet to add/edit an inventory item.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';

class InventoryItemFormSheet extends StatefulWidget {
  const InventoryItemFormSheet({super.key, this.initial, this.onSubmit});

  final InventoryItem? initial;
  final ValueChanged<InventoryItem>? onSubmit;

  @override
  State<InventoryItemFormSheet> createState() => _InventoryItemFormSheetState();
}

class _InventoryItemFormSheetState extends State<InventoryItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _reorderController;
  late final TextEditingController _notesController;
  late InventoryCategory _category;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _category = i?.category ?? InventoryCategory.otro;
    _expiryDate = i?.expiryDate;
    _nameController = TextEditingController(text: i?.name ?? '');
    _quantityController = TextEditingController(
      text: i?.quantity.toString() ?? '',
    );
    _unitController = TextEditingController(text: i?.unit ?? '');
    _reorderController = TextEditingController(
      text: i?.reorderThreshold?.toString() ?? '',
    );
    _notesController = TextEditingController(text: i?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _reorderController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + viewInsets),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEditing ? 'Editar artículo' : 'Nuevo artículo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<InventoryCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                items: InventoryCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del artículo',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) {
                        final n = double.tryParse(
                          v?.replaceAll(',', '.') ?? '',
                        );
                        if (n == null || n < 0) return 'Cantidad inválida';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        prefixIcon: Icon(Icons.straighten),
                        hintText: 'kg, lt, bolsas…',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa la unidad'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reorderController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Punto de reorden (opcional)',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                  hintText: 'Alerta cuando baje de este valor',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n < 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ExpiryDateField(
                value: _expiryDate,
                onChanged: (date) => setState(() => _expiryDate = date),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: Icon(
                    isEditing ? Icons.save_outlined : Icons.add_box_outlined,
                  ),
                  label: Text(
                    isEditing ? 'Guardar cambios' : 'Agregar artículo',
                  ),
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.parse(_quantityController.text.replaceAll(',', '.'));
    final reorderRaw = _reorderController.text.trim();
    final reorder = reorderRaw.isEmpty
        ? null
        : double.tryParse(reorderRaw.replaceAll(',', '.'));
    final notes = _notesController.text.trim();

    final item = InventoryItem(
      uuid: widget.initial?.uuid,
      name: _nameController.text.trim(),
      quantity: qty,
      unit: _unitController.text.trim(),
      reorderThreshold: reorder,
      expiryDate: _expiryDate,
      lastUpdated: DateTime.now(),
      category: _category,
      notes: notes.isEmpty ? null : notes,
    );

    if (widget.onSubmit != null) {
      widget.onSubmit!(item);
      return;
    }
    Navigator.of(context).pop(item);
  }
}

class _ExpiryDateField extends StatelessWidget {
  const _ExpiryDateField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = value == null
        ? 'Sin vencimiento'
        : '${value!.day.toString().padLeft(2, '0')}/'
              '${value!.month.toString().padLeft(2, '0')}/'
              '${value!.year}';

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Fecha de vencimiento (opcional)',
        prefixIcon: Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: value == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (value != null)
            GestureDetector(
              onTap: () => onChanged(null),
              child: Icon(
                Icons.clear,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) onChanged(picked);
            },
            child: Icon(
              Icons.edit_calendar_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
