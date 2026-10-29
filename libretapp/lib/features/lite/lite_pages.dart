import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/utils/color_contrast.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/models/animal_registration_seed.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'lite_pet_service.dart';
import 'lite_visibility.dart';
import 'lite_task_form_page.dart';
import 'lite_notification_service.dart';
import 'widgets/lite_artwork.dart';
import 'package:libretapp/features/inicio/widgets/weather_home_card.dart';

String _date(DateTime value) => DateFormat('d MMM, HH:mm', 'es').format(value);
String _petAge(AnimalEntity pet) {
  if (!pet.hasKnownAge) return 'Edad sin dato';
  final years = pet.ageMonths ~/ 12;
  final months = pet.ageMonths % 12;
  if (years == 0) {
    return '${pet.ageMonths} ${pet.ageMonths == 1 ? 'mes' : 'meses'}';
  }
  if (months == 0) {
    return '$years ${years == 1 ? 'año' : 'años'}';
  }
  return '$years ${years == 1 ? 'año' : 'años'} $months ${months == 1 ? 'mes' : 'meses'}';
}

class LiteSnapshot {
  const LiteSnapshot(this.animals, this.plants, this.entries);
  final List<AnimalEntity> animals;
  final List<CultivationEntity> plants;
  final List<AgendaEntry> entries;

  static Future<LiteSnapshot> load() async => LiteSnapshot(
    await locator<AnimalRepository>().getAllIncludingInactive(),
    await locator<CultivationRepository>().getAll(),
    await locator<AgendaRepository>().fetchEntries(),
  );

  List<AnimalEntity> get pets => animals.where(LitePetService.isPet).toList();
  List<CultivationEntity> get domesticPlants =>
      plants.where(LiteVisibility.domesticPlant).toList();
  List<AgendaEntry> visibleEntries({required bool showPlants}) {
    final petIds = pets.map((a) => a.uuid).toSet();
    final plantIds = domesticPlants.map((c) => c.uuid).toSet();
    return entries
        .where(
          (e) => LiteVisibility.agendaEntry(
            e,
            petIds,
            plantIds,
            showPlants: showPlants,
          ),
        )
        .toList();
  }
}

enum LiteSection { home, pets, plants, agenda }

enum LiteAgendaFilter { all, pets, general, plants }

extension LiteAgendaFilterLabel on LiteAgendaFilter {
  String get label => switch (this) {
    LiteAgendaFilter.all => 'Todas',
    LiteAgendaFilter.pets => 'Mascotas',
    LiteAgendaFilter.general => 'Generales',
    LiteAgendaFilter.plants => 'Plantas',
  };
}

bool liteAgendaEntryMatchesFilter(AgendaEntry entry, LiteAgendaFilter filter) =>
    switch (filter) {
      LiteAgendaFilter.all => true,
      LiteAgendaFilter.pets => entry.animalIds.isNotEmpty,
      LiteAgendaFilter.general =>
        entry.animalIds.isEmpty && entry.cropUuid == null,
      LiteAgendaFilter.plants => entry.cropUuid != null,
    };

class LiteSectionPage extends StatefulWidget {
  const LiteSectionPage({super.key, required this.section});
  final LiteSection section;
  @override
  State<LiteSectionPage> createState() => _LiteSectionPageState();
}

class _LiteSectionPageState extends State<LiteSectionPage> {
  late Future<LiteSnapshot> _future = LiteSnapshot.load();
  DateTime _selectedDate = DateTime.now();
  int _weekOffset = 0;
  LiteAgendaFilter _agendaFilter = LiteAgendaFilter.all;
  void _reload() => setState(() => _future = LiteSnapshot.load());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppExperienceScope.of(context).showPlants &&
        _agendaFilter == LiteAgendaFilter.plants) {
      _agendaFilter = LiteAgendaFilter.all;
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final experience = AppExperienceScope.of(context);
    final title = switch (widget.section) {
      LiteSection.home => 'LibretApp',
      LiteSection.pets => 'Mis mascotas',
      LiteSection.plants => 'Mis plantas',
      LiteSection.agenda => 'Agenda',
    };
    return FutureBuilder<LiteSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final Widget body;
        if (data == null) {
          final status = snapshot.hasError
              ? Center(
                  child: Text(
                    'No se pudieron cargar los registros: ${snapshot.error}',
                  ),
                )
              : const Center(child: CircularProgressIndicator());
          body = widget.section == LiteSection.home
              ? Column(
                  children: [
                    const WeatherHomeCard(),
                    Expanded(child: status),
                  ],
                )
              : status;
        } else {
          final children = switch (widget.section) {
            LiteSection.home => _home(data, experience.showPlants),
            LiteSection.pets => _pets(data),
            LiteSection.plants => _plants(data, experience.showPlants),
            LiteSection.agenda => _agenda(data, experience.showPlants),
          };
          body = RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
              children: children,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          body: body,
          floatingActionButton: data == null
              ? null
              : _floatingAction(data, experience.showPlants),
        );
      },
    );
  }

  Widget? _floatingAction(LiteSnapshot data, bool showPlants) {
    final colors = Theme.of(context).colorScheme;
    final (visible, label, icon, page) = switch (widget.section) {
      LiteSection.home || LiteSection.pets => (
        data.pets.isNotEmpty,
        'Añadir mascota',
        Icons.pets,
        const LitePetFormPage() as Widget,
      ),
      LiteSection.agenda => (
        data.visibleEntries(showPlants: showPlants).isNotEmpty,
        'Añadir fecha',
        Icons.add,
        const LiteTaskFormPage() as Widget,
      ),
      LiteSection.plants => (
        showPlants && data.domesticPlants.isNotEmpty,
        'Añadir planta',
        Icons.add,
        const LitePlantFormPage() as Widget,
      ),
    };
    if (!visible) return null;
    return FloatingActionButton.extended(
      onPressed: () => _open(page),
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _emptyPrompt({
    required IconData icon,
    String? artworkAsset,
    required String title,
    required String description,
    required String action,
    required VoidCallback onPressed,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: artworkAsset == null
                      ? Icon(icon, size: 19)
                      : LiteArtwork(
                          assetPath: artworkAsset,
                          size: 30,
                          fallbackIcon: icon,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              icon: const Icon(Icons.add),
              label: Text(action),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _home(LiteSnapshot data, bool showPlants) {
    final upcoming =
        data
            .visibleEntries(showPlants: showPlants)
            .where((e) => LiteVisibility.isOpenEntry(e))
            .toList()
          ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final hidden = LiteVisibility.hiddenCount(
      data.animals,
      data.plants,
      data.entries,
    );
    final now = DateTime.now();
    bool today(AgendaEntry entry) =>
        entry.fecha.year == now.year &&
        entry.fecha.month == now.month &&
        entry.fecha.day == now.day;
    final todayEntries = upcoming.where(today).toList();
    final laterEntries = upcoming.where((e) => !today(e)).toList();
    final firstRun =
        data.pets.isEmpty &&
        upcoming.isEmpty &&
        (!showPlants || data.domesticPlants.isEmpty);
    return [
      Text(
        'Tu día',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      Text(
        'Todo lo importante, en un lugar',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
      const WeatherHomeCard(),
      const SizedBox(height: 8),
      if (firstRun)
        Card(
          key: const ValueKey('lite-getting-started'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'Empieza aquí',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _startAction(
                Icons.pets_outlined,
                'Añadir mascota',
                () => _open(const LitePetFormPage()),
              ),
              _startAction(
                Icons.event_outlined,
                'Programar fecha',
                () => _open(const LiteTaskFormPage()),
              ),
              if (showPlants)
                _startAction(
                  Icons.eco_outlined,
                  'Añadir planta',
                  () => _open(const LitePlantFormPage()),
                ),
            ],
          ),
        )
      else ...[
        if (data.pets.isEmpty)
          _compactAction(
            Icons.pets_outlined,
            'Añadir tu primera mascota',
            () => _open(const LitePetFormPage()),
          ),
        ...data.pets.take(4).map(_petTile),
        if (data.pets.length > 4)
          TextButton(
            onPressed: () => context.go(AppRoutes.directorio),
            child: const Text('Ver todas las mascotas'),
          ),
        if (todayEntries.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Hoy', style: Theme.of(context).textTheme.titleMedium),
          ...todayEntries.take(3).map(_taskTile),
        ],
        if (laterEntries.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Próximamente', style: Theme.of(context).textTheme.titleMedium),
          ...laterEntries.take(4).map(_taskTile),
          if (laterEntries.length > 4)
            TextButton(
              onPressed: () => context.go(AppRoutes.agenda),
              child: const Text('Ver agenda completa'),
            ),
        ],
        if (upcoming.isEmpty)
          _compactAction(
            Icons.event_outlined,
            'Programar una fecha',
            () => _open(const LiteTaskFormPage()),
          ),
        if (showPlants) ...[
          const SizedBox(height: 14),
          Text(
            'Plantas y huerto',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (data.domesticPlants.isEmpty)
            _compactAction(
              Icons.eco_outlined,
              'Añadir planta o huerto',
              () => _open(const LitePlantFormPage()),
            ),
          ...data.domesticPlants.take(3).map(_plantTile),
          if (data.domesticPlants.length > 3)
            TextButton(
              onPressed: () => context.go(AppRoutes.reportes),
              child: const Text('Ver todas las plantas'),
            ),
        ],
      ],
      if (!showPlants && data.domesticPlants.isNotEmpty)
        const Card(
          child: ListTile(
            leading: Icon(Icons.eco_outlined),
            title: Text('Plantas ocultas'),
            subtitle: Text(
              'Puedes volver a mostrarlas desde Perfil → Ajustes.',
            ),
          ),
        ),
      if (hidden > 0)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(
                '$hidden ${hidden == 1 ? 'registro adicional' : 'registros adicionales'} en Completa',
              ),
              subtitle: const Text(
                'Se conservan en este espacio y volverán a verse al cambiar de experiencia.',
              ),
            ),
          ),
        ),
    ];
  }

  Widget _startAction(IconData icon, String title, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );

  Widget _compactAction(IconData icon, String title, VoidCallback onTap) =>
      Card(child: _startAction(icon, title, onTap));

  List<Widget> _pets(LiteSnapshot data) => [
    if (data.pets.isEmpty)
      _emptyPrompt(
        icon: Icons.pets_outlined,
        artworkAsset: 'assets/images/canino.webp',
        title: 'Todavía no hay mascotas',
        description: 'Crea una ficha para guardar sus cuidados y fechas.',
        action: 'Añadir mascota',
        onPressed: () => _open(const LitePetFormPage()),
      ),
    ...data.pets.map(_petTile),
  ];

  Widget _petTile(AnimalEntity pet) => Card(
    child: ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: AnimalPhotoImage(
            path: pet.profilePhoto,
            fit: BoxFit.cover,
            fallback: pet.species == Species.feline
                ? const LiteArtwork(
                    assetPath: 'assets/images/felino.png',
                    size: 42,
                    fallbackIcon: Icons.cruelty_free,
                  )
                : const LiteArtwork(
                    assetPath: 'assets/images/canino.webp',
                    size: 42,
                    fallbackIcon: Icons.pets,
                  ),
          ),
        ),
      ),
      title: Text(
        (pet.customName ?? pet.visualId ?? '').trim().isEmpty
            ? 'Sin nombre'
            : (pet.customName ?? pet.visualId)!,
      ),
      subtitle: Text(
        '${pet.species == Species.feline ? 'Gato' : 'Perro'} · ${_petAge(pet)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          context.push(AppRoutes.animalDetallePath(pet.uuid)).then((_) {
            if (mounted) _reload();
          }),
    ),
  );

  List<Widget> _plants(LiteSnapshot data, bool showPlants) => showPlants
      ? [
          if (data.domesticPlants.isEmpty)
            _emptyPrompt(
              icon: Icons.eco_outlined,
              artworkAsset: 'assets/images/crop_germinating.webp',
              title: 'Todavía no hay plantas',
              description: 'Registra una planta o un huerto y sus riegos.',
              action: 'Añadir planta',
              onPressed: () => _open(const LitePlantFormPage()),
            ),
          ...data.domesticPlants.map(_plantTile),
        ]
      : [
          const Card(
            child: ListTile(
              title: Text('Plantas ocultas'),
              subtitle: Text('Puedes mostrarlas desde Perfil → Ajustes.'),
            ),
          ),
        ];

  Widget _plantTile(CultivationEntity plant) => Card(
    child: ListTile(
      leading: const LiteArtwork(
        assetPath: 'assets/images/crop_vegetative.webp',
        size: 46,
        fallbackIcon: Icons.eco_outlined,
      ),
      title: Text(plant.name),
      subtitle: Text('Próximo riego: ${_date(plant.nextWateringDate)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _open(LitePlantDetailPage(uuid: plant.uuid)),
    ),
  );

  List<Widget> _agenda(LiteSnapshot data, bool showPlants) {
    final entries = data.visibleEntries(showPlants: showPlants)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final anchor = DateTime.now().add(Duration(days: 7 * _weekOffset));
    final monday = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(Duration(days: anchor.weekday - DateTime.monday));
    final filtered = entries.where((entry) {
      if (entry.fecha.year != _selectedDate.year ||
          entry.fecha.month != _selectedDate.month ||
          entry.fecha.day != _selectedDate.day) {
        return false;
      }
      return liteAgendaEntryMatchesFilter(entry, _agendaFilter);
    }).toList();
    return [
      Text(
        'Tus próximos cuidados',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Row(
        children: [
          IconButton(
            onPressed: () => setState(() {
              _weekOffset--;
              _selectedDate = monday.subtract(const Duration(days: 7));
            }),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('MMMM yyyy', 'es').format(monday),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _weekOffset++;
              _selectedDate = monday.add(const Duration(days: 7));
            }),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(14) >= 19;
          final width = largeText && constraints.maxWidth < 490
              ? 490.0
              : constraints.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Row(
                children: List.generate(7, (index) {
                  final day = monday.add(Duration(days: index));
                  final selected =
                      day.year == _selectedDate.year &&
                      day.month == _selectedDate.month &&
                      day.day == _selectedDate.day;
                  final colors = Theme.of(context).colorScheme;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: DateFormat('EEEE d MMMM', 'es').format(day),
                        child: ExcludeSemantics(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(() => _selectedDate = day),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: selected
                                      ? colors.primary
                                      : colors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('E', 'es').format(day),
                                      style: TextStyle(
                                        color: selected
                                            ? colors.onPrimary
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selected
                                            ? colors.onPrimary
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final filter in [
              LiteAgendaFilter.all,
              LiteAgendaFilter.pets,
              LiteAgendaFilter.general,
              if (showPlants) LiteAgendaFilter.plants,
            ])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('lite-agenda-filter-${filter.name}'),
                  label: Text(filter.label),
                  selected: _agendaFilter == filter,
                  onSelected: (_) => setState(() => _agendaFilter = filter),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        DateFormat('EEEE d MMMM', 'es').format(_selectedDate),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (filtered.isEmpty)
        _emptyPrompt(
          icon: Icons.event_available_outlined,
          artworkAsset: 'assets/images/record_reminder.webp',
          title: 'No hay fechas para este día',
          description: 'Añade una cita, una toma o una tarea de cuidado.',
          action: 'Añadir fecha',
          onPressed: () => _open(const LiteTaskFormPage()),
        ),
      ...filtered.map(_taskTile),
    ];
  }

  Widget _taskTile(AgendaEntry entry) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = entry.tipo == 'Medicamento'
        ? colors.tertiary
        : entry.cropUuid != null
        ? colors.primary
        : colors.secondary;
    final background = Color.alphaBlend(
      accent.withValues(alpha: theme.brightness == Brightness.dark ? .18 : .10),
      colors.surface,
    );
    final foreground = readableTextColor(colors.onSurface, background);
    final secondary = readableTextColor(colors.onSurfaceVariant, background);
    final status = LiteVisibility.isOpenEntry(entry)
        ? 'Pendiente'
        : entry.estado == AgendaEstado.cancelado
        ? 'Cancelada'
        : 'Completada';
    return Card(
      key: ValueKey('lite-task-${entry.id}'),
      color: background,
      child: ListTile(
        textColor: foreground,
        iconColor: foreground,
        leading: SizedBox(
          width: 44,
          height: 44,
          child: LiteArtwork(
            assetPath: entry.tipo == 'Medicamento'
                ? 'assets/images/task_vitamins.webp'
                : entry.cropUuid != null
                ? 'assets/images/record_irrigation.webp'
                : 'assets/images/record_reminder.webp',
            size: 42,
            fallbackIcon: entry.tipo == 'Medicamento'
                ? Icons.medication_outlined
                : entry.cropUuid != null
                ? Icons.water_drop_outlined
                : Icons.event_outlined,
          ),
        ),
        title: Text(
          entry.titulo,
          semanticsLabel:
              '${entry.titulo}. ${entry.tipo}. ${_date(entry.fecha)}. $status.',
        ),
        subtitle: ExcludeSemantics(
          child: Text(
            '${_date(entry.fecha)} · ${entry.tipo}',
            style: TextStyle(color: secondary),
          ),
        ),
        trailing: !LiteVisibility.isOpenEntry(entry)
            ? Icon(
                entry.estado == AgendaEstado.cancelado
                    ? Icons.cancel_outlined
                    : Icons.check_circle,
                color: entry.estado == AgendaEstado.cancelado
                    ? Colors.grey
                    : Colors.green,
              )
            : IconButton(
                tooltip: 'Confirmar',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () async {
                  try {
                    if (entry.tipo == 'Medicamento') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Confirmar toma'),
                          content: Text(
                            '¿Marcar «${entry.titulo}» como administrada?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('Confirmar'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                    }
                    if (!mounted) return;
                    await locator<AgendaRepository>().updateEntry(
                      entry.copyWith(
                        estado: AgendaEstado.completado,
                        fechaCompletado: DateTime.now(),
                      ),
                    );
                    await LiteNotificationService.syncFromRepository();
                    if (mounted) _reload();
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$error')));
                    }
                  }
                },
              ),
      ),
    );
  }
}

class LitePetFormPage extends StatefulWidget {
  const LitePetFormPage({super.key, this.uuid, this.initialSpecies});
  final String? uuid;
  final Species? initialSpecies;
  @override
  State<LitePetFormPage> createState() => _LitePetFormPageState();
}

class _LitePetFormPageState extends State<LitePetFormPage> {
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _identity = TextEditingController();
  final _age = TextEditingController();
  final _notes = TextEditingController();
  Species _species = Species.canine;
  Sex _sex = Sex.unknown;
  String? _photo;
  LitePetInput? _before;
  AnimalEntity? _editingPet;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _species = widget.initialSpecies ?? _species;
    if (widget.uuid != null) _load();
  }

  Future<void> _load() async {
    final pet = await locator<AnimalRepository>().getByUuid(widget.uuid!);
    if (pet == null || !mounted) return;
    setState(() {
      _editingPet = pet;
      _name.text = pet.customName ?? '';
      _breed.text = pet.breed == 'Desconocido' ? '' : pet.breed;
      _identity.text = pet.earTagNumber;
      _age.text = pet.hasKnownAge ? pet.ageMonths.toString() : '';
      _species = pet.species;
      _sex = pet.sex;
      _photo = pet.profilePhoto;
      _notes.text = pet.notes ?? '';
      _before = _input();
    });
  }

  LitePetInput _input() => LitePetInput(
    name: _name.text,
    species: _species,
    breed: _breed.text,
    identification: _identity.text,
    sex: _sex,
    ageMonths: int.tryParse(_age.text),
    photo: _photo,
    notes: _notes.text,
  );

  Future<void> _save() async {
    if (_busy ||
        _name.text.trim().isEmpty ||
        (widget.uuid != null && _before == null)) {
      return;
    }
    if (_age.text.trim().isNotEmpty && int.tryParse(_age.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe la edad en meses o déjala vacía.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final service = LitePetService(
        locator<AnimalRepository>(),
        editService: locator<AnimalEditService>(),
      );
      if (widget.uuid == null) {
        await service.create(_input());
      } else {
        await service.patch(widget.uuid!, _before!, _input());
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openFullForm() async {
    final age = int.tryParse(_age.text.trim());
    final existing = _editingPet;
    final preserveBirthDate =
        existing != null && existing.hasKnownAge && existing.ageMonths == age;
    final seed = AnimalRegistrationSeed(
      species: _species,
      sex: _sex,
      ageMonths: age ?? -1,
      identification: _identity.text,
      name: _name.text,
      breed: _breed.text,
      productionPurpose: ProductionPurpose.companion,
      birthDate: preserveBirthDate ? existing.knownBirthDate : null,
      birthDatePrecision: preserveBirthDate
          ? existing.birthDatePrecision
          : null,
      profilePhoto: _photo,
      notes: _notes.text,
    );
    final result = widget.uuid == null
        ? await context.pushNamed<bool>(AppRoutes.nameAnimalNuevo, extra: seed)
        : await context.pushNamed<bool>(
            AppRoutes.nameAnimalCompletar,
            pathParameters: {'uuid': widget.uuid!},
            extra: seed,
          );
    if (result == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _identity.dispose();
    _age.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.uuid == null ? 'Nueva mascota' : 'Editar mascota'),
      actions: [
        IconButton(
          onPressed: _busy ? null : _openFullForm,
          icon: const Icon(Icons.description_outlined),
          tooltip: 'Ficha completa',
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nombre *'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Species>(
          key: ValueKey(_species),
          initialValue: _species,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Especie'),
          items: Species.values
              .map(
                (species) => DropdownMenuItem(
                  value: species,
                  child: Text(species.displayName),
                ),
              )
              .toList(),
          onChanged: widget.uuid == null
              ? (value) {
                  if (value != null) setState(() => _species = value);
                }
              : null,
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: const Text('Foto (opcional)'),
          tilePadding: EdgeInsets.zero,
          children: [
            AnimalPhotoField(
              photoPath: _photo,
              species: _species,
              onChanged: (value) => setState(() => _photo = value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Más detalles'),
          initiallyExpanded: widget.uuid != null,
          tilePadding: EdgeInsets.zero,
          children: [
            TextField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'Raza (opcional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _identity,
              decoration: const InputDecoration(
                labelText: 'Microchip o placa (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Sex>(
              key: ValueKey(_sex),
              initialValue: _sex,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Sexo (opcional)'),
              items: Sex.values
                  .map(
                    (v) =>
                        DropdownMenuItem(value: v, child: Text(v.displayName)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _sex = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad aproximada en meses',
                helperText: 'Déjala vacía si no la sabes.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Guardando…' : 'Guardar'),
        ),
      ],
    ),
  );
}

class LitePetDetailPage extends StatefulWidget {
  const LitePetDetailPage({super.key, required this.uuid});
  final String uuid;
  @override
  State<LitePetDetailPage> createState() => _LitePetDetailPageState();
}

class _LitePetDetailPageState extends State<LitePetDetailPage> {
  late Future<AnimalEntity?> _pet = locator<AnimalRepository>().getByUuid(
    widget.uuid,
  );
  void _reload() =>
      setState(() => _pet = locator<AnimalRepository>().getByUuid(widget.uuid));
  @override
  Widget build(BuildContext context) => FutureBuilder<AnimalEntity?>(
    future: _pet,
    builder: (context, snapshot) {
      final pet = snapshot.data;
      if (pet == null) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text(
              snapshot.hasError ? '${snapshot.error}' : 'Cargando ficha…',
            ),
          ),
        );
      }
      if (!LitePetService.isPet(pet)) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text('Esta ficha está disponible en Completa.'),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(pet.customName ?? 'Mascota'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LitePetFormPage(uuid: widget.uuid),
                  ),
                );
                if (mounted) _reload();
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: AnimalPhotoImage(
                              path: pet.profilePhoto,
                              fallback: pet.species == Species.feline
                                  ? const LiteArtwork(
                                      assetPath: 'assets/images/felino.png',
                                      size: 80,
                                      fallbackIcon: Icons.cruelty_free,
                                    )
                                  : const LiteArtwork(
                                      assetPath: 'assets/images/canino.webp',
                                      size: 80,
                                      fallbackIcon: Icons.pets,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.customName ?? 'Sin nombre',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              Text(
                                '${pet.species == Species.feline ? 'Gato' : 'Perro'} · ${_petAge(pet)}',
                              ),
                              if (pet.sex != Sex.unknown)
                                Text(pet.sex.displayName),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (pet.breed.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Raza: ${pet.breed}'),
                    ],
                    if (pet.earTagNumber.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Microchip o placa: ${pet.earTagNumber}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Próximas fechas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            FutureBuilder<List<AgendaEntry>>(
              future: locator<AgendaRepository>().fetchEntries(),
              builder: (context, state) {
                final entries =
                    (state.data ?? [])
                        .where(
                          (e) =>
                              e.animalIds.contains(pet.uuid) &&
                              LiteVisibility.isOpenEntry(e),
                        )
                        .toList()
                      ..sort((a, b) => a.fecha.compareTo(b.fecha));
                return Card(
                  child: Column(
                    children: entries.isEmpty
                        ? [
                            const ListTile(
                              leading: SizedBox(
                                width: 40,
                                height: 40,
                                child: LiteArtwork(
                                  assetPath:
                                      'assets/images/record_reminder.webp',
                                  size: 36,
                                  fallbackIcon: Icons.event_available_outlined,
                                ),
                              ),
                              title: Text('No hay fechas pendientes'),
                            ),
                          ]
                        : entries
                              .take(5)
                              .map(
                                (e) => ListTile(
                                  leading: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: LiteArtwork(
                                      assetPath: e.tipo == 'Medicamento'
                                          ? 'assets/images/task_vitamins.webp'
                                          : 'assets/images/record_reminder.webp',
                                      size: 34,
                                      fallbackIcon: Icons.event,
                                    ),
                                  ),
                                  title: Text(e.titulo),
                                  subtitle: Text(_date(e.fecha)),
                                ),
                              )
                              .toList(),
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LiteTaskFormPage(initialPetUuid: pet.uuid),
                  ),
                );
                if (mounted) _reload();
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir cita o medicamento'),
            ),
            const SizedBox(height: 12),
            Text(
              'Historial de salud y peso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.push(
                      AppRoutes.animalRegistroSaludPath(pet.uuid),
                    );
                    if (mounted) _reload();
                  },
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('Registrar salud'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.push(
                      AppRoutes.animalRegistroPesoPath(pet.uuid),
                    );
                    if (mounted) _reload();
                  },
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: const Text('Registrar peso'),
                ),
              ],
            ),
            FutureBuilder(
              future: Future.wait([
                locator<HealthRecordRepository>().getHealthRecords(pet.uuid),
                locator<WeightRecordRepository>().getWeightRecords(pet.uuid),
              ]),
              builder: (context, state) {
                if (!state.hasData) return const LinearProgressIndicator();
                final health = state.data![0] as List<dynamic>;
                final weights = state.data![1] as List<dynamic>;
                return Column(
                  children: [
                    ...health.map(
                      (r) => ListTile(
                        leading: const SizedBox(
                          width: 36,
                          height: 36,
                          child: LiteArtwork(
                            assetPath: 'assets/images/health_treatment.webp',
                            size: 34,
                            fallbackIcon: Icons.medical_services_outlined,
                          ),
                        ),
                        title: Text(r.type.displayName as String),
                        subtitle: Text(_date(r.date as DateTime)),
                      ),
                    ),
                    ...weights.map(
                      (r) => ListTile(
                        leading: const SizedBox(
                          width: 36,
                          height: 36,
                          child: LiteArtwork(
                            assetPath: 'assets/images/health_weight.webp',
                            size: 34,
                            fallbackIcon: Icons.monitor_weight_outlined,
                          ),
                        ),
                        title: Text('${r.weight} kg'),
                        subtitle: Text(_date(r.date as DateTime)),
                      ),
                    ),
                    if (health.isEmpty && weights.isEmpty)
                      const ListTile(title: Text('Sin registros todavía')),
                  ],
                );
              },
            ),
            FutureBuilder<List<AgendaEntry>>(
              future: locator<AgendaRepository>().fetchEntries(),
              builder: (context, state) {
                final done =
                    (state.data ?? [])
                        .where(
                          (e) =>
                              e.animalIds.contains(pet.uuid) &&
                              e.estado == AgendaEstado.completado,
                        )
                        .toList()
                      ..sort((a, b) => b.fecha.compareTo(a.fecha));
                return Column(
                  children: done
                      .map(
                        (e) => ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(e.titulo),
                          subtitle: Text(
                            'Confirmado: ${_date(e.fechaCompletado ?? e.fecha)}',
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class LitePlantFormPage extends StatefulWidget {
  const LitePlantFormPage({super.key});
  @override
  State<LitePlantFormPage> createState() => _LitePlantFormPageState();
}

class _LitePlantFormPageState extends State<LitePlantFormPage> {
  final _name = TextEditingController();
  bool _group = false;
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nueva planta o huerto')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nombre *'),
        ),
        SwitchListTile(
          title: const Text('Agrupar como huerto'),
          subtitle: const Text('Un registro para varias plantas.'),
          value: _group,
          onChanged: (v) => setState(() => _group = v),
        ),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  if (_name.text.trim().isEmpty) return;
                  setState(() => _busy = true);
                  try {
                    await locator<CultivationRepository>().upsert(
                      CultivationEntity(
                        name: _name.text.trim(),
                        scale: _group
                            ? CultivationScale.group
                            : CultivationScale.individual,
                        plantingDate: DateTime.now(),
                      ),
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$error')));
                    }
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

class LitePlantDetailPage extends StatefulWidget {
  const LitePlantDetailPage({super.key, required this.uuid});
  final String uuid;
  @override
  State<LitePlantDetailPage> createState() => _LitePlantDetailPageState();
}

class _LitePlantDetailPageState extends State<LitePlantDetailPage> {
  late Future<CultivationEntity?> _plant = locator<CultivationRepository>()
      .getByUuid(widget.uuid);
  void _reload() => setState(
    () => _plant = locator<CultivationRepository>().getByUuid(widget.uuid),
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<CultivationEntity?>(
    future: _plant,
    builder: (context, state) {
      final plant = state.data;
      if (plant == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Cargando planta…')),
        );
      }
      if (!LiteVisibility.domesticPlant(plant)) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text('Esta siembra está disponible en Completa.'),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: Text(plant.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: LiteArtwork(
                assetPath: 'assets/images/crop_vegetative.webp',
                size: 88,
                fallbackIcon: Icons.eco,
              ),
            ),
            ListTile(
              title: const Text('Próximo riego'),
              subtitle: Text(_date(plant.nextWateringDate)),
            ),
            FilledButton.icon(
              onPressed: () async {
                await locator<CultivationRepository>().addWatering(
                  plant.uuid,
                  CropWateringRecord(date: DateTime.now()),
                );
                if (mounted) _reload();
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Registrar riego'),
            ),
            Text(
              'Historial de riego',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...plant.waterings.map((w) => ListTile(title: Text(_date(w.date)))),
          ],
        ),
      );
    },
  );
}
