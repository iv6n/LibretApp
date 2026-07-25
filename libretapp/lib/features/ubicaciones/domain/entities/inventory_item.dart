/// features \u203a ubicaciones \u203a domain \u203a entities \u203a inventory_item \u2014 stored goods / supply item.
///
/// InventoryCategory values are now English identifiers.
/// Migration note: old Spanish Isar values were migrated by LocationEnumMigrationService.
library;

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

String _generateInventoryId() =>
    'inv-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

enum InventoryCategory { feed, medicine, tool, equipment, other }

extension InventoryCategoryX on InventoryCategory {
  /// Fallback English label. Production UI should use ARB keys.
  String get label {
    switch (this) {
      case InventoryCategory.feed:
        return 'Feed / Fodder';
      case InventoryCategory.medicine:
        return 'Medicine / Veterinary';
      case InventoryCategory.tool:
        return 'Tool';
      case InventoryCategory.equipment:
        return 'Equipment';
      case InventoryCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case InventoryCategory.feed:
        return Icons.grass_outlined;
      case InventoryCategory.medicine:
        return Icons.medication_outlined;
      case InventoryCategory.tool:
        return Icons.handyman_outlined;
      case InventoryCategory.equipment:
        return Icons.precision_manufacturing_outlined;
      case InventoryCategory.other:
        return Icons.inventory_2_outlined;
    }
  }

  /// Mapping from old Spanish Isar-stored enum names to new English names.
  /// Used exclusively by LocationEnumMigrationService.
  static const Map<String, String> legacyNameMap = {
    'pienso': 'feed',
    'medicina': 'medicine',
    'herramienta': 'tool',
    'equipo': 'equipment',
    'otro': 'other',
  };
}

class InventoryItem extends Equatable {
  InventoryItem({
    String? uuid,
    required this.name,
    required this.quantity,
    required this.unit,
    this.reorderThreshold,
    this.expiryDate,
    DateTime? lastUpdated,
    this.category = InventoryCategory.other,
    this.notes,
    this.activeIngredient,
    this.batchNumber,
    this.withdrawalDays,
    this.unitCost,
  }) : uuid = uuid ?? _generateInventoryId(),
       lastUpdated = lastUpdated ?? DateTime.now();

  final String uuid;
  final String name;
  final double quantity;
  final String unit;
  final double? reorderThreshold;
  final DateTime? expiryDate;
  final DateTime lastUpdated;
  final InventoryCategory category;
  final String? notes;
  final String? activeIngredient;
  final String? batchNumber;
  final int? withdrawalDays;
  final double? unitCost;

  bool get isLowStock =>
      reorderThreshold != null && quantity <= reorderThreshold!;

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  InventoryItem copyWith({
    String? uuid,
    String? name,
    double? quantity,
    String? unit,
    Object? reorderThreshold = _sentinel,
    Object? expiryDate = _sentinel,
    DateTime? lastUpdated,
    InventoryCategory? category,
    Object? notes = _sentinel,
    Object? activeIngredient = _sentinel,
    Object? batchNumber = _sentinel,
    Object? withdrawalDays = _sentinel,
    Object? unitCost = _sentinel,
  }) {
    return InventoryItem(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      reorderThreshold: reorderThreshold == _sentinel
          ? this.reorderThreshold
          : reorderThreshold as double?,
      expiryDate: expiryDate == _sentinel
          ? this.expiryDate
          : expiryDate as DateTime?,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      notes: notes == _sentinel ? this.notes : notes as String?,
      activeIngredient: activeIngredient == _sentinel
          ? this.activeIngredient
          : activeIngredient as String?,
      batchNumber: batchNumber == _sentinel
          ? this.batchNumber
          : batchNumber as String?,
      withdrawalDays: withdrawalDays == _sentinel
          ? this.withdrawalDays
          : withdrawalDays as int?,
      unitCost: unitCost == _sentinel ? this.unitCost : unitCost as double?,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    name,
    quantity,
    unit,
    reorderThreshold,
    expiryDate,
    lastUpdated,
    category,
    notes,
    activeIngredient,
    batchNumber,
    withdrawalDays,
    unitCost,
  ];
}

const Object _sentinel = Object();
