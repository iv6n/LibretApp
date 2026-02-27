import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<String?> showAnimalSearchOverlay({
  required BuildContext context,
  required List<AnimalEntity> animals,
  required List<String> recentSearches,
  required VoidCallback onClearHistory,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _AnimalSearchSheet(
        animals: animals,
        recentSearches: recentSearches,
        onClearHistory: onClearHistory,
      );
    },
  );
}

class _AnimalSearchSheet extends StatefulWidget {
  const _AnimalSearchSheet({
    required this.animals,
    required this.recentSearches,
    required this.onClearHistory,
  });

  final List<AnimalEntity> animals;
  final List<String> recentSearches;
  final VoidCallback onClearHistory;

  @override
  State<_AnimalSearchSheet> createState() => _AnimalSearchSheetState();
}

class _AnimalSearchSheetState extends State<_AnimalSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';
  late List<String> _recentSearches;

  @override
  void initState() {
    super.initState();
    _recentSearches = List<String>.from(widget.recentSearches);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filter(_query);
    final recentActivity = _recentActivity();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      builder: (ctx, scrollController) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: (value) => _submit(value),
                  decoration: InputDecoration(
                    hintText: l10n.animalsSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _query = '';
                                _controller.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  children: [
                    if (_recentSearches.isNotEmpty)
                      _Section(
                        title: l10n.animalsRecentSearches,
                        trailing: TextButton(
                          onPressed: () {
                            setState(() => _recentSearches = []);
                            widget.onClearHistory();
                          },
                          child: Text(l10n.animalsClearHistory),
                        ),
                        child: Column(
                          children: _recentSearches
                              .map(
                                (q) => ListTile(
                                  leading: const Icon(Icons.history, size: 20),
                                  title: Text(q),
                                  onTap: () => _submit(q),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    _Section(
                      title: l10n.animalsRecentActivity,
                      child: Column(
                        children: recentActivity
                            .map(
                              (animal) => ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    animal.earTagNumber.substring(0, 1),
                                  ),
                                ),
                                title: Text(animal.earTagNumber),
                                subtitle: Text(
                                  animal.customName ?? animal.breed,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _submit(animal.earTagNumber),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    _Section(
                      title: l10n.animalsAdvancedSearch,
                      child: filtered.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l10n.animalsNoResults,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                            )
                          : Column(
                              children: filtered
                                  .map(
                                    (animal) => ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          animal.earTagNumber.substring(0, 1),
                                        ),
                                      ),
                                      title: Text(animal.earTagNumber),
                                      subtitle: Text(
                                        [
                                          if (animal.customName != null)
                                            animal.customName,
                                          animal.breed,
                                          animal.batchId,
                                        ].whereType<String>().join(' · '),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () => _submit(animal.earTagNumber),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(String value) {
    Navigator.of(context).pop(value.trim());
  }

  List<AnimalEntity> _filter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return widget.animals.take(20).toList();
    }

    return widget.animals
        .where((animal) {
          return [
            animal.earTagNumber,
            animal.customName ?? '',
            animal.visualId ?? '',
            animal.breed,
            animal.batchId ?? '',
            animal.lifeStage.displayName,
            animal.sex.displayName,
          ].any((field) => field.toLowerCase().contains(normalized));
        })
        .take(40)
        .toList();
  }

  List<AnimalEntity> _recentActivity() {
    final sorted = List<AnimalEntity>.from(widget.animals)
      ..sort((a, b) {
        final left = a.lastMovementDate ?? a.lastUpdateDate;
        final right = b.lastMovementDate ?? b.lastUpdateDate;
        return right.compareTo(left);
      });
    return sorted.take(8).toList();
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
        Card(margin: const EdgeInsets.symmetric(horizontal: 4), child: child),
      ],
    );
  }
}
