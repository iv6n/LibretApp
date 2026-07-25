part of '../location_detail_widgets.dart';

// ─── AdaptivePropertiesSection ──────────────────────────────────────────────

class AdaptivePropertiesSection extends StatelessWidget {
  const AdaptivePropertiesSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final items = _buildDisplayItems(location);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Propiedades específicas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.tune_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items
                  .map(
                    (item) => _PropertyPill(
                      label: locationPropertyLabel(context, item.key),
                      value: _formatPropertyValue(context, item.attribute),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  List<_AdaptivePropertyItem> _buildDisplayItems(LocationEntity current) {
    final keyed = <String, DynamicAttribute>{
      for (final item in current.attributes) item.key: item,
    };

    if (!keyed.containsKey('geometry') &&
        current.geometry != null &&
        current.geometry!.trim().isNotEmpty) {
      keyed['geometry'] = DynamicAttribute.text(
        key: 'geometry',
        label: 'Geometry',
        value: current.geometry!.trim(),
      );
    }

    if (!keyed.containsKey('isShared')) {
      keyed['isShared'] = DynamicAttribute.boolean(
        key: 'isShared',
        label: 'Shared usage',
        value: current.isShared,
      );
    }

    if (!keyed.containsKey('isCommunal')) {
      keyed['isCommunal'] = DynamicAttribute.boolean(
        key: 'isCommunal',
        label: 'Communal usage',
        value: current.isCommunal,
      );
    }

    return keyed.entries
        .map((entry) => _AdaptivePropertyItem(entry.key, entry.value))
        .toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  String _formatPropertyValue(BuildContext context, DynamicAttribute item) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final isSpanish = languageCode.toLowerCase().startsWith('es');

    switch (item.type) {
      case DynamicAttributeType.boolean:
        return (item.boolValue ?? false)
            ? (isSpanish ? 'Sí' : 'Yes')
            : (isSpanish ? 'No' : 'No');
      case DynamicAttributeType.integer:
        final value = item.numberValue;
        if (value == null) return '—';
        final base = value.toInt().toString();
        if (item.unit == null || item.unit!.trim().isEmpty) return base;
        return '$base ${item.unit}';
      case DynamicAttributeType.number:
        final value = item.numberValue;
        if (value == null) return '—';
        final base = value.toString();
        if (item.unit == null || item.unit!.trim().isEmpty) return base;
        return '$base ${item.unit}';
      case DynamicAttributeType.text:
        final text = item.textValue?.trim() ?? '';
        if (text.isEmpty) return '—';
        return text;
    }
  }
}

class _AdaptivePropertyItem {
  const _AdaptivePropertyItem(this.key, this.attribute);

  final String key;
  final DynamicAttribute attribute;
}

class _PropertyPill extends StatelessWidget {
  const _PropertyPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── InfrastructureSection ────────────────────────────────────────────────────

class InfrastructureSection extends StatelessWidget {
  const InfrastructureSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastWater = location.waters.isNotEmpty ? location.waters.last : null;
    final lastShade = location.shades.isNotEmpty ? location.shades.last : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Infraestructura',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.foundation_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ConditionRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Bebederos',
                  value: lastWater == null
                      ? 'Sin registrar'
                      : 'Fuente ${_capitalize(lastWater.type.name)}',
                ),
                _ConditionRow(
                  icon: Icons.park_outlined,
                  label: 'Sombras',
                  value: lastShade == null
                      ? 'Pendiente'
                      : '${lastShade.shadePercent.toStringAsFixed(0)}% • ${lastShade.condition}',
                ),
                const _ConditionRow(
                  icon: Icons.fence_outlined,
                  label: 'Cercos',
                  value: 'Estado pendiente de inspección',
                ),
                const _ConditionRow(
                  icon: Icons.agriculture_outlined,
                  label: 'Comederos / saladeros',
                  value: 'Registrar inspección y limpieza',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

