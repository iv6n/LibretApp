/// features › ubicaciones › widgets › inventory_item_form_sheet — bottom sheet to add/edit an inventory item.
library;

import 'package:libretapp/core/utils/number_parsing.dart';


import 'package:flutter/material.dart';
import 'package:libretapp/core/core.dart';
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
  late final TextEditingController _activeIngredientController;
  late final TextEditingController _batchController;
  late final TextEditingController _withdrawalController;
  late final TextEditingController _unitCostController;
  late InventoryCategory _category;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _category = i?.category ?? InventoryCategory.other;
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
    _activeIngredientController = TextEditingController(
      text: i?.activeIngredient ?? '',
    );
    _batchController = TextEditingController(text: i?.batchNumber ?? '');
    _withdrawalController = TextEditingController(
      text: i?.withdrawalDays?.toString() ?? '',
    );
    _unitCostController = TextEditingController(
      text: i?.unitCost?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _reorderController.dispose();
    _notesController.dispose();
    _activeIngredientController.dispose();
    _batchController.dispose();
    _withdrawalController.dispose();
    _unitCostController.dispose();
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
                  AppIconButton(
                    icon: Icons.close,
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppSelectField<InventoryCategory>(
                value: _category,
                items: InventoryCategory.values,
                itemLabel: (category) => category.label,
                labelText: 'Categoría',
                prefixIcon: const Icon(Icons.label_outline),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameController,
                key: const ValueKey('inventory-item-name'),
                textCapitalization: TextCapitalization.sentences,
                labelText: 'Nombre del artículo',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                requiredField: true,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _quantityController,
                      key: const ValueKey('inventory-item-quantity'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      labelText: 'Cantidad',
                      prefixIcon: const Icon(Icons.numbers),
                      requiredField: true,
                      validator: (v) {
                        final n = parseFormDouble(
                          v?.replaceAll(',', '.') ?? '',
                        );
                        if (n == null || n < 0) return 'Cantidad inválida';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _unitController,
                      key: const ValueKey('inventory-item-unit'),
                      textCapitalization: TextCapitalization.words,
                      labelText: 'Unidad',
                      prefixIcon: const Icon(Icons.straighten),
                      hintText: 'kg, lt, bolsas…',
                      requiredField: true,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa la unidad'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _reorderController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                labelText: 'Punto de reorden (opcional)',
                prefixIcon: const Icon(Icons.warning_amber_outlined),
                hintText: 'Alerta cuando baje de este valor',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = parseFormDouble(v.replaceAll(',', '.'));
                  if (n == null || n < 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ExpiryDateField(
                value: _expiryDate,
                onChanged: (date) => setState(() => _expiryDate = date),
              ),
              if (_category == InventoryCategory.medicine) ...[
                const SizedBox(height: 12),
                AppTextField(
                  controller: _activeIngredientController,
                  labelText: 'Principio activo (opcional)',
                  prefixIcon: const Icon(Icons.science_outlined),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _batchController,
                        labelText: 'Lote del producto',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _withdrawalController,
                        keyboardType: TextInputType.number,
                        labelText: 'Retiro (días)',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final days = int.tryParse(value.trim());
                          return days == null || days < 0
                              ? 'Valor inválido'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  labelText: 'Costo por unidad (opcional)',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final cost = parseFormDouble(value.replaceAll(',', '.'));
                    return cost == null || cost < 0 ? 'Valor inválido' : null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              AppTextField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                labelText: 'Notas (opcional)',
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              const SizedBox(height: 16),
              AppButton(
                key: const ValueKey('inventory-item-save'),
                expanded: true,
                icon: isEditing ? Icons.save_outlined : Icons.add_box_outlined,
                label: isEditing ? 'Guardar cambios' : 'Agregar artículo',
                onPressed: _submit,
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
        : parseFormDouble(reorderRaw.replaceAll(',', '.'));
    final notes = _notesController.text.trim();
    final activeIngredient = _activeIngredientController.text.trim();
    final batch = _batchController.text.trim();
    final withdrawalDays = int.tryParse(_withdrawalController.text.trim());
    final unitCost = parseFormDouble(
      _unitCostController.text.trim().replaceAll(',', '.'),
    );

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
      activeIngredient: activeIngredient.isEmpty ? null : activeIngredient,
      batchNumber: batch.isEmpty ? null : batch,
      withdrawalDays: withdrawalDays,
      unitCost: unitCost,
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
    return AppDateField(
      value: value,
      onChanged: onChanged,
      labelText: 'Fecha de vencimiento (opcional)',
      emptyLabel: 'Sin vencimiento',
      clearTooltip: 'Borrar fecha',
      allowClear: true,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
  }
}
