part of '../location_detail_widgets.dart';

// ─── WarehouseSection ─────────────────────────────────────────────────────────

class WarehouseSection extends StatelessWidget {
  const WarehouseSection({required this.location});

  final LocationEntity location;

  Future<void> _showAddSheet(BuildContext context) async {
    final item = await showModalBottomSheet<InventoryItem>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const InventoryItemFormSheet(),
    );
    if (item != null && context.mounted) {
      context.read<LocationDetailCubit>().addInventoryItem(item);
    }
  }

  Future<void> _showEditSheet(BuildContext context, InventoryItem item) async {
    final updated = await showModalBottomSheet<InventoryItem>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => InventoryItemFormSheet(initial: item),
    );
    if (updated != null && context.mounted) {
      context.read<LocationDetailCubit>().updateInventoryItem(updated);
    }
  }

  void _confirmDelete(BuildContext context, InventoryItem item) {
    showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: Text('¿Eliminar "${item.name}" del inventario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<LocationDetailCubit>().removeInventoryItem(item.uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = location.inventory;

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
                    'Inventario',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.warehouse_outlined),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin artículos registrados.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...items.map(
                (item) => _InventoryItemTile(
                  item: item,
                  onEdit: () => _showEditSheet(context, item),
                  onDelete: () => _confirmDelete(context, item),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar artículo'),
                onPressed: () => _showAddSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── InventoryItemTile ────────────────────────────────────────────────────────

class _InventoryItemTile extends StatelessWidget {
  const _InventoryItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.category.icon,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (item.isLowStock) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: 'Stock bajo',
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                      ),
                    ],
                    if (item.isExpired) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: 'Vencido',
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                      ),
                    ] else if (item.isExpiringSoon) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: 'Por vencer',
                        color: theme.colorScheme.tertiaryContainer,
                        textColor: theme.colorScheme.onTertiaryContainer,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: theme.colorScheme.error,
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

