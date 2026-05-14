/// features › ubicaciones › domain › entities › inventory_item — stored goods / supply item.
library;

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

String _generateInventoryId() =>
    'inv-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

enum InventoryCategory { pienso, medicina, herramienta, equipo, otro }

extension InventoryCategoryX on InventoryCategory {
  String get label {
    switch (this) {
      case InventoryCategory.pienso:
        return 'Pienso / Alimento';
      case InventoryCategory.medicina:
        return 'Medicina / Veterinario';
      case InventoryCategory.herramienta:
        return 'Herramienta';
      case InventoryCategory.equipo:
        return 'Equipo';
      case InventoryCategory.otro:
        return 'Otro';
    }
  }

  IconData get icon {
    switch (this) {
      case InventoryCategory.pienso:
        return Icons.grass_outlined;
      case InventoryCategory.medicina:
        return Icons.medication_outlined;
      case InventoryCategory.herramienta:
        return Icons.handyman_outlined;
      case InventoryCategory.equipo:
        return Icons.precision_manufacturing_outlined;
      case InventoryCategory.otro:
        return Icons.inventory_2_outlined;
    }
  }
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
    this.category = InventoryCategory.otro,
    this.notes,
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
  ];
}

const Object _sentinel = Object();
