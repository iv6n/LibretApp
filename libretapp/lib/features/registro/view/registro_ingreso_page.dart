/// features \u203a registro \u203a view \u203a registro_ingreso_page \u2014 page for recording a farm income entry.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/finanzas/application/finanzas_bloc.dart';
import 'package:libretapp/features/finanzas/application/finanzas_event.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/registro/widgets/animal_selector.dart';

class RegistroIngresoPage extends StatefulWidget {
  const RegistroIngresoPage({super.key});

  @override
  State<RegistroIngresoPage> createState() => _RegistroIngresoPageState();
}

class _RegistroIngresoPageState extends State<RegistroIngresoPage> {
  final _amountCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'USD');
  final _notesCtrl = TextEditingController();
  var _type = IncomeType.milkSale;
  var _date = DateTime.now();
  AnimalEntity? _selectedAnimal;
  bool _saving = false;

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final amount = _parseDouble(_amountCtrl.text);
    if (amount == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido.')),
      );
      return;
    }
    if (amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('El monto debe ser mayor a cero.')),
      );
      return;
    }

    setState(() => _saving = true);

    final record = IncomeRecord(
      date: _date,
      type: _type,
      amount: amount,
      currency: _currencyCtrl.text.trim().isEmpty
          ? null
          : _currencyCtrl.text.trim().toUpperCase(),
      animalUuid: _selectedAnimal?.uuid,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      // If a FinanzasBloc is already in the tree, dispatch to it so the list
      // refreshes automatically. Otherwise, save directly via repository.
      final finanzasBloc = context.read<FinanzasBloc?>();
      if (finanzasBloc != null) {
        finanzasBloc.add(AddIncome(record));
      } else {
        await locator<FinanzasRepository>().addIncome(record);
      }
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Ingreso guardado.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ingreso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de ingreso', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            DropdownButtonFormField<IncomeType>(
              value: _type,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: IncomeType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monto', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '0.00',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Moneda', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _currencyCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'USD',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Fecha', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  '${_date.day.toString().padLeft(2, '0')}/'
                  '${_date.month.toString().padLeft(2, '0')}/'
                  '${_date.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Animal (opcional)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            AnimalSelector(
              selectedAnimal: _selectedAnimal,
              onSelected: (a) => setState(() => _selectedAnimal = a),
            ),
            const SizedBox(height: 16),
            Text('Notas (opcional)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Descripción adicional...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar ingreso'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
