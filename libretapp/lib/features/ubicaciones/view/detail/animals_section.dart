part of '../location_detail_widgets.dart';

// ─── AnimalsSection ───────────────────────────────────────────────────────────

class AnimalsSection extends StatelessWidget {
  const AnimalsSection({super.key, 
    required this.animalsHere,
    required this.location,
    required this.assigning,
    required this.onAssign,
  });

  final List<AnimalEntity> animalsHere;
  final LocationEntity location;
  final bool assigning;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Animales (${animalsHere.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: assigning ? null : onAssign,
                  icon: const Icon(Icons.pets_outlined),
                  label: const Text('Asignar / mover'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (animalsHere.isEmpty)
              const Text('Sin animales en esta ubicación')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: animalsHere.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final animal = animalsHere[index];
                  final subtitle = _animalSubtitle(animal);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_animalTitle(animal)),
                    subtitle: subtitle == null ? null : Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.animalDetallePath(animal.uuid)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _animalTitle(AnimalEntity animal) {
    return animal.earTagNumber.isNotEmpty
        ? animal.earTagNumber
        : (animal.visualId?.isNotEmpty == true ? animal.visualId! : 'Animal');
  }

  String? _animalSubtitle(AnimalEntity animal) {
    final breed = animal.breed;
    final species = animal.species.displayName;
    final stage = animal.lifeStage.displayName;
    final pieces = [breed, species, stage].where((e) => e.isNotEmpty).toList();
    if (pieces.isEmpty) return null;
    return pieces.join(' • ');
  }
}

// ─── ActionsRow ───────────────────────────────────────────────────────────────

class ActionsRow extends StatelessWidget {
  const ActionsRow({super.key, required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar ubicación'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ),
      ],
    );
  }
}

