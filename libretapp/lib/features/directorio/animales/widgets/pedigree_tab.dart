/// features › directorio › animales › widgets › pedigree_tab — parents, offspring and pedigree tree.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';

/// Shows where an animal came from and what it has produced.
///
/// For a breeding female the offspring list *is* her production record, which
/// is why it sits beside the pedigree rather than in the generic records tab.
class PedigreeTab extends StatelessWidget {
  const PedigreeTab({super.key, required this.data});

  final DetailData data;

  @override
  Widget build(BuildContext context) {
    const pedigree = PedigreeService();
    const kpiService = ReproductiveKpiService();

    final animal = data.animal;
    final tree = pedigree.ancestorsOf(animal, herd: data.ancestors);
    final kpis = kpiService.forAnimal(
      records: data.reproductions,
      birthDate: animal.birthDate,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (animal.sex == Sex.male && data.sireRecords.isNotEmpty)
          _SireSummary(
            kpis: kpiService.forSire(records: data.sireRecords),
            offspringCount: data.offspring.length,
          )
        else
          _LineageSummary(kpis: kpis, offspringCount: data.offspring.length),
        const SizedBox(height: 20),
        const _SectionTitle(
          icon: Icons.account_tree_outlined,
          label: 'Ascendencia',
        ),
        const SizedBox(height: 8),
        _ParentsRow(tree: tree),
        const SizedBox(height: 20),
        _SectionTitle(
          icon: Icons.child_care_outlined,
          label: 'Crías (${data.offspring.length})',
        ),
        const SizedBox(height: 8),
        if (data.offspring.isEmpty)
          const _EmptyHint(
            message: 'Sin crías registradas. Al registrar un parto puedes '
                'dar de alta la cría y queda enlazada aquí.',
          )
        else
          ...data.offspring.map((child) => _OffspringTile(animal: child)),
      ],
    );
  }
}

/// What a sire has produced. Evaluating a bull is one of the expensive calls a
/// breeder makes, and these figures are derived from the females' records, so
/// they move on their own as those pregnancies are confirmed and calve.
class _SireSummary extends StatelessWidget {
  const _SireSummary({required this.kpis, required this.offspringCount});

  final SireReproductiveKpis kpis;
  final int offspringCount;

  @override
  Widget build(BuildContext context) {
    final rate = kpis.conceptionRate;
    return _SummaryChips(
      chips: [
        (label: 'Servicios', value: '${kpis.serviceCount}'),
        (label: 'Hembras', value: '${kpis.femalesServed}'),
        if (rate != null)
          (label: 'Concepción', value: '${(rate * 100).round()}%')
        else
          (label: 'Concepción', value: 'sin diagnósticos'),
        (label: 'Crías', value: '$offspringCount'),
      ],
    );
  }
}

class _LineageSummary extends StatelessWidget {
  const _LineageSummary({required this.kpis, required this.offspringCount});

  final AnimalReproductiveKpis kpis;
  final int offspringCount;

  @override
  Widget build(BuildContext context) {
    return _SummaryChips(
      chips: [
        (label: 'Crías', value: '$offspringCount'),
        if (kpis.calvingCount > 0)
          (label: 'Partos', value: '${kpis.calvingCount}'),
        if (kpis.ageAtFirstCalvingMonths != null)
          (
            label: 'Edad 1er parto',
            value: '${kpis.ageAtFirstCalvingMonths} meses',
          ),
        if (kpis.averageCalvingIntervalDays != null)
          (label: 'IEP', value: '${kpis.averageCalvingIntervalDays!.round()} d'),
      ],
    );
  }
}

class _SummaryChips extends StatelessWidget {
  const _SummaryChips({required this.chips});

  final List<({String label, String value})> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final chip in chips)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chip.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chip.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Parents side by side, each expanding into its own two grandparents.
class _ParentsRow extends StatelessWidget {
  const _ParentsRow({required this.tree});

  final PedigreeNode tree;

  @override
  Widget build(BuildContext context) {
    if (tree.sire == null && tree.dam == null) {
      return const _EmptyHint(
        message: 'Sin padres registrados. Puedes asignarlos al editar el '
            'animal para empezar a construir su pedigrí.',
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _AncestorBranch(
            node: tree.sire,
            role: 'Padre',
            icon: Icons.male,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AncestorBranch(
            node: tree.dam,
            role: 'Madre',
            icon: Icons.female,
          ),
        ),
      ],
    );
  }
}

class _AncestorBranch extends StatelessWidget {
  const _AncestorBranch({
    required this.node,
    required this.role,
    required this.icon,
  });

  final PedigreeNode? node;
  final String role;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final current = node;
    if (current == null) {
      return _AncestorCard(role: role, icon: icon, node: null);
    }

    final grandparents = [current.sire, current.dam]
        .whereType<PedigreeNode>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AncestorCard(role: role, icon: icon, node: current),
        if (grandparents.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final grandparent in grandparents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _AncestorCard(
                      role: grandparent == current.sire ? 'Abuelo' : 'Abuela',
                      icon: grandparent == current.sire
                          ? Icons.male
                          : Icons.female,
                      node: grandparent,
                      dense: true,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AncestorCard extends StatelessWidget {
  const _AncestorCard({
    required this.role,
    required this.icon,
    required this.node,
    this.dense = false,
  });

  final String role;
  final IconData icon;
  final PedigreeNode? node;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animal = node?.animal;
    final known = animal != null;

    final label = known
        ? primaryAnimalLabel(animal)
        : node == null
        ? 'No registrado'
        : 'Fuera del hato';

    final subtitle = known
        ? breedSummary(animal, abbreviated: true)
        : node == null
        ? null
        : 'Referencia sin ficha';

    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: dense ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: known
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: known
              ? AnimalPalette.speciesColor(animal.species).withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: dense ? 14 : 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.4,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: dense ? 12 : 14,
                    color: known ? null : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty && !dense)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!known) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
      child: card,
    );
  }
}

class _OffspringTile extends StatelessWidget {
  const _OffspringTile({required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGone = animal.status != AnimalStatus.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AnimalPalette.speciesColor(
            animal.species,
          ).withValues(alpha: 0.18),
          child: Icon(
            animal.sex == Sex.male ? Icons.male : Icons.female,
            size: 18,
            color: AnimalPalette.speciesColor(animal.species),
          ),
        ),
        title: Text(
          primaryAnimalLabel(animal),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            // Sold or dead offspring stay listed — they are part of the dam's
            // history — but read as past tense.
            decoration: isGone ? TextDecoration.lineThrough : null,
            color: isGone ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Text(
          [
            animal.lifeStage.displayName,
            if (isGone) animal.status.displayName,
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
