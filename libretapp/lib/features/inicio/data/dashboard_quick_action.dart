/// features › inicio › data › dashboard_quick_action — configurable home quick actions.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:libretapp/core/router/app_routes.dart';

/// Icons offered by [defaultQuickActions] / the dashboard customize sheet,
/// keyed by codepoint so [DashboardQuickAction.fromJson] can resolve a
/// persisted icon back to a `const IconData` instead of constructing one
/// from arbitrary JSON — a non-const `IconData(...)` call defeats Flutter's
/// icon font tree-shaking and breaks release builds.
final Map<int, IconData> _iconByCodePoint = {
  Icons.add_circle_outline.codePoint: Icons.add_circle_outline,
  Icons.add_location_alt_outlined.codePoint: Icons.add_location_alt_outlined,
  Icons.paid_outlined.codePoint: Icons.paid_outlined,
  Icons.attach_money.codePoint: Icons.attach_money,
  Icons.event_available.codePoint: Icons.event_available,
  Icons.swap_horiz.codePoint: Icons.swap_horiz,
  Icons.note_add_outlined.codePoint: Icons.note_add_outlined,
  Icons.calendar_month_outlined.codePoint: Icons.calendar_month_outlined,
  Icons.touch_app.codePoint: Icons.touch_app,
};

class DashboardQuickAction extends Equatable {

  factory DashboardQuickAction.fromJson(Map<String, dynamic> json) {
    return DashboardQuickAction(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      icon: _iconByCodePoint[json['iconCodePoint'] as int?] ?? Icons.touch_app,
      routeName: json['routeName'] as String? ?? AppRoutes.nameInicio,
      enabled: json['enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      tone: json['tone'] != null ? Color(json['tone'] as int) : null,
    );
  }
  const DashboardQuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.routeName,
    required this.enabled,
    required this.order,
    this.tone,
  });

  final String id;
  final String label;
  final IconData icon;
  final String routeName;
  final bool enabled;
  final int order;
  final Color? tone;

  DashboardQuickAction copyWith({
    String? id,
    String? label,
    IconData? icon,
    String? routeName,
    bool? enabled,
    int? order,
    Color? tone,
  }) {
    return DashboardQuickAction(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      routeName: routeName ?? this.routeName,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      tone: tone ?? this.tone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'iconCodePoint': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'routeName': routeName,
    'enabled': enabled,
    'order': order,
    if (tone != null) 'tone': tone!.toARGB32(),
  };

  @override
  List<Object?> get props => [id, label, icon, routeName, enabled, order, tone];
}

List<DashboardQuickAction> defaultQuickActions() {
  return const [
    DashboardQuickAction(
      id: 'animal',
      label: 'Registrar animal',
      icon: Icons.add_circle_outline,
      routeName: AppRoutes.nameAnimalNuevoRapido,
      enabled: true,
      order: 0,
      tone: Color(0xFF2F855A),
    ),
    DashboardQuickAction(
      id: 'ubicacion',
      label: 'Registrar ubicación',
      icon: Icons.add_location_alt_outlined,
      routeName: AppRoutes.nameUbicacionNueva,
      enabled: true,
      order: 1,
      tone: Color(0xFF2F855A),
    ),
    DashboardQuickAction(
      id: 'gasto',
      label: 'Registrar gasto',
      icon: Icons.paid_outlined,
      routeName: AppRoutes.nameRegistroGastoGeneral,
      enabled: true,
      order: 2,
      tone: Color(0xFF6B5A4A),
    ),
    DashboardQuickAction(
      id: 'ingreso',
      label: 'Registrar ingreso',
      icon: Icons.attach_money,
      routeName: AppRoutes.nameRegistroIngreso,
      enabled: true,
      order: 3,
      tone: Color(0xFF2F5D50),
    ),
    DashboardQuickAction(
      id: 'evento',
      label: 'Registrar evento',
      icon: Icons.event_available,
      routeName: AppRoutes.nameAgendaNuevo,
      enabled: true,
      order: 4,
      tone: Color(0xFFD97706),
    ),
    DashboardQuickAction(
      id: 'movimiento',
      label: 'Movimiento',
      icon: Icons.swap_horiz,
      routeName: AppRoutes.nameRegistroMovimiento,
      enabled: true,
      order: 5,
      tone: Color(0xFF4A7C95),
    ),
    DashboardQuickAction(
      id: 'nota',
      label: 'Agregar nota',
      icon: Icons.note_add_outlined,
      routeName: AppRoutes.nameAgendaNuevo,
      enabled: true,
      order: 6,
      tone: Color(0xFF7B4B2A),
    ),
    DashboardQuickAction(
      id: 'calendario',
      label: 'Ver calendario',
      icon: Icons.calendar_month_outlined,
      routeName: AppRoutes.nameAgenda,
      enabled: true,
      order: 7,
      tone: Color(0xFF4A7C95),
    ),
  ];
}
