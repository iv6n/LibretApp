import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/application/bloc/animal_event.dart'
    show AnimalEvent, AddHealthRecord, AddProductionRecord, AddWeightRecord;
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/widgets/health_form_sheet.dart';
import 'package:libretapp/features/directorio/animales/widgets/production_form_sheet.dart';
import 'package:libretapp/features/directorio/animales/widgets/weight_form_sheet.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalFormPage extends StatefulWidget {
  const AnimalFormPage({this.animalUuid, super.key});

  final String? animalUuid;

  bool get isEdit => animalUuid != null;

  @override
  State<AnimalFormPage> createState() => _AnimalFormPageState();
}

class _AnimalFormPageState extends State<AnimalFormPage> {
  static const _cattleOnlyCategories = <Category>{
    Category.calf,
    Category.heifer,
    Category.steer,
    Category.cow,
    Category.bull,
    Category.oxen,
    Category.weaned,
  };

  late final AnimalRepository _animalRepository;
  late final LotesRepository _lotesRepository;
  late final LocationRepository _locationRepository;

  final _earTagCtrl = TextEditingController();
  final _customNameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _purchaseCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Species _species = Species.cattle;
  Category _category = Category.values.first;
  Sex _sex = Sex.values.first;
  AnimalStatus _status = AnimalStatus.values.first;
  DateTime _birthDate = DateTime.now();
  String? _selectedLocationId;
  String? _selectedBatchUuid;
  String? _selectedDamUuid;
  String? _selectedSireUuid;

  bool _vaccinated = false;
  bool _dewormed = false;
  bool _hasVitamins = false;
  bool _hasChronicIssues = false;
  bool _registerAsCalf = false;

  bool _idSectionOpen = true;
  bool _originSectionOpen = true;
  bool _locationSectionOpen = true;
  bool _healthSectionOpen = false;
  bool _notesSectionOpen = false;

  bool _loading = true;
  bool _saving = false;
  AnimalEntity? _editingAnimal;
  List<LocationEntity> _locations = const [];
  List<LoteEntity> _activeLotes = const [];
  List<AnimalEntity> _allAnimals = const [];

  List<LocationEntity> _dedupeLocations(List<LocationEntity> source) {
    final seen = <String>{};
    return source.where((item) => seen.add(item.uuid)).toList(growable: false);
  }

  List<LoteEntity> _dedupeLotes(List<LoteEntity> source) {
    final seen = <String>{};
    return source.where((item) => seen.add(item.uuid)).toList(growable: false);
  }

  List<AnimalEntity> _dedupeAnimals(List<AnimalEntity> source) {
    final seen = <String>{};
    return source.where((item) => seen.add(item.uuid)).toList(growable: false);
  }

  void _sanitizeSelections() {
    if (_selectedLocationId != null &&
        !_locations.any((item) => item.uuid == _selectedLocationId)) {
      _selectedLocationId = null;
    }
    if (_selectedBatchUuid != null &&
        !_activeLotes.any((item) => item.uuid == _selectedBatchUuid)) {
      _selectedBatchUuid = null;
    }
    if (_selectedDamUuid != null &&
        !_allAnimals.any((item) => item.uuid == _selectedDamUuid)) {
      _selectedDamUuid = null;
    }
    if (_selectedSireUuid != null &&
        !_allAnimals.any((item) => item.uuid == _selectedSireUuid)) {
      _selectedSireUuid = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _animalRepository = locator<AnimalRepository>();
    _lotesRepository = locator<LotesRepository>();
    _locationRepository = locator<LocationRepository>();
    _loadInitialData();
  }

  @override
  void dispose() {
    _earTagCtrl.dispose();
    _customNameCtrl.dispose();
    _breedCtrl.dispose();
    _ownerCtrl.dispose();
    _purchaseCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait<dynamic>([
        _locationRepository.getAll(),
        _lotesRepository.getActiveLotes(),
        _animalRepository.getAll(),
        if (widget.isEdit) _animalRepository.getByUuid(widget.animalUuid!),
      ]);

      _locations = _dedupeLocations(results[0] as List<LocationEntity>);
      _activeLotes = _dedupeLotes(results[1] as List<LoteEntity>);
      _allAnimals = _dedupeAnimals(results[2] as List<AnimalEntity>);
      if (widget.isEdit) {
        _editingAnimal = results[3] as AnimalEntity?;
        final animal = _editingAnimal;
        if (animal != null) {
          _earTagCtrl.text = animal.earTagNumber;
          _customNameCtrl.text = animal.customName ?? '';
          _breedCtrl.text = animal.breed;
          _ownerCtrl.text = animal.owner ?? '';
          _purchaseCtrl.text = animal.purchasePrice?.toString() ?? '';
          _weightCtrl.text = animal.weight?.toString() ?? '';
          _notesCtrl.text = animal.chronicNotes ?? '';
          _species = animal.species;
          _category = animal.category;
          _sex = animal.sex;
          _status = animal.status;
          _birthDate = animal.birthDate;
          _selectedLocationId =
              animal.currentPaddockId ?? animal.initialLocationId;
          _selectedBatchUuid = animal.batchUuid;
          _selectedDamUuid = animal.damUuid;
          _selectedSireUuid = animal.sireUuid;
          _vaccinated = animal.vaccinated;
          _dewormed = animal.dewormed;
          _hasVitamins = animal.hasVitamins;
          _hasChronicIssues = animal.hasChronicIssues;
          _registerAsCalf = animal.category == Category.calf;
        }
      }
      _sanitizeSelections();
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).animalFormLoadError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _isCattleCategory(Category value) {
    return _cattleOnlyCategories.contains(value);
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  String? _normalizedText(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  double? _parseOptionalDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<bool> _isEarTagDuplicated({
    required String earTag,
    String? excludeUuid,
  }) async {
    final normalized = earTag.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    final animals = await _animalRepository.getAll();
    for (final animal in animals) {
      if (excludeUuid != null && animal.uuid == excludeUuid) {
        continue;
      }
      final candidate = animal.earTagNumber.trim().toLowerCase();
      if (candidate.isNotEmpty && candidate == normalized) {
        return true;
      }
    }
    return false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSpeciesChanged(Species value) {
    var adjustedCategory = false;
    setState(() {
      _species = value;
      if (_species != Species.cattle && _isCattleCategory(_category)) {
        _category = Category.other;
        adjustedCategory = true;
      }
    });
    if (adjustedCategory) {
      _showMessage(AppLocalizations.of(context).animalFormCategoryAdjusted);
    }
  }

  void _onCategoryChanged(Category value) {
    var adjustedSpecies = false;
    setState(() {
      _category = value;
      if (_isCattleCategory(_category) && _species != Species.cattle) {
        _species = Species.cattle;
        adjustedSpecies = true;
      }
    });
    if (adjustedSpecies) {
      _showMessage(AppLocalizations.of(context).animalFormSpeciesAdjusted);
    }
  }

  String _animalLabel(AnimalEntity animal) {
    final name = animal.customName?.trim();
    if (name != null && name.isNotEmpty) {
      return '$name (${animal.earTagNumber})';
    }
    if (animal.earTagNumber.trim().isNotEmpty) {
      return animal.earTagNumber;
    }
    return animal.uuid;
  }

  List<AnimalEntity> _parentsBySex(Sex sex) {
    final editingUuid = _editingAnimal?.uuid;
    return _allAnimals
        .where((animal) => animal.sex == sex && animal.uuid != editingUuid)
        .toList();
  }

  AnimalEntity? _findAutoDamCandidate() {
    final mothers = _parentsBySex(Sex.female).where((animal) {
      final isAdultMother =
          animal.category == Category.cow || animal.category == Category.heifer;
      if (!isAdultMother) return false;
      if (_selectedLocationId == null) return true;
      final animalLocation =
          animal.currentPaddockId ?? animal.initialLocationId;
      return animalLocation == _selectedLocationId;
    }).toList();

    if (mothers.isEmpty) return null;
    mothers.sort((a, b) => b.lastUpdateDate.compareTo(a.lastUpdateDate));
    return mothers.first;
  }

  AnimalEntity? _findAnimal(String? uuid) {
    if (uuid == null) return null;
    for (final animal in _allAnimals) {
      if (animal.uuid == uuid) {
        return animal;
      }
    }
    return null;
  }

  Future<String?> _pickParent({
    required String title,
    required List<AnimalEntity> source,
  }) async {
    final searchCtrl = TextEditingController();
    var query = '';
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = source.where((animal) {
              if (query.trim().isEmpty) return true;
              final text = query.toLowerCase();
              return _animalLabel(animal).toLowerCase().contains(text) ||
                  animal.breed.toLowerCase().contains(text);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).animalsSearchHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        query = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.block_outlined),
                    title: Text(
                      AppLocalizations.of(context).animalFormNoSelection,
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(null),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                AppLocalizations.of(context).animalsNoResults,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final animal = filtered[index];
                              return ListTile(
                                title: Text(_animalLabel(animal)),
                                subtitle: Text(
                                  '${animal.species.displayName} • ${animal.category.displayName}',
                                ),
                                onTap: () =>
                                    Navigator.of(sheetContext).pop(animal.uuid),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    searchCtrl.dispose();
    return selected;
  }

  Future<bool> _askEarTagWarning() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).animalFormNoTagTitle),
          content: Text(AppLocalizations.of(context).animalFormNoTagMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).animalsSelectionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).actionSave),
            ),
          ],
        );
      },
    );
    return accepted ?? false;
  }

  Future<bool> _dispatchAndAwait(AnimalesEvent event) async {
    // Save directly via the repository instead of dispatching through the bloc.
    // The Isar watchAll() stream will fire after the write and deliver a single
    // AnimalesStreamUpdated → AnimalesLoaded emission to the AnimalesBloc.
    // Routing the save through the bloc caused a double-emit (one from
    // _refreshLoadedState, one from the stream) that raced with the page-pop
    // transition and triggered an _InactiveElements assertion in the framework.
    try {
      if (event is AddAnimal) {
        await _animalRepository.save(event.animal);
        return true;
      }
      if (event is UpdateAnimal) {
        await _animalRepository.update(event.animal);
        return true;
      }
      if (!mounted) return false;
      _showMessage(AppLocalizations.of(context).animalFormUnsupportedAction);
      return false;
    } catch (e) {
      if (!mounted) return false;
      _showMessage(
        AppLocalizations.of(context).animalFormRecordSaveError('$e'),
      );
      return false;
    }
  }

  Future<bool> _dispatchRecordAndAwait(AnimalEvent event) async {
    try {
      if (event is AddWeightRecord) {
        await _animalRepository.addWeightRecord(event.animalUuid, event.record);
        return true;
      }
      if (event is AddHealthRecord) {
        await _animalRepository.addHealthRecord(event.animalUuid, event.record);
        return true;
      }
      if (event is AddProductionRecord) {
        await _animalRepository.addProductionRecord(
          event.animalUuid,
          event.record,
        );
        return true;
      }
      _showMessage(AppLocalizations.of(context).animalFormUnsupportedAction);
      return false;
    } catch (e) {
      _showMessage(
        AppLocalizations.of(context).animalFormRecordSaveError('$e'),
      );
      return false;
    }
  }

  String? get _currentAnimalUuid {
    return _editingAnimal?.uuid;
  }

  void _showSaveFirstMessage() {
    _showMessage(AppLocalizations.of(context).animalFormSaveFirstForRecords);
  }

  Future<void> _openWeightShortcut() async {
    final animalUuid = _currentAnimalUuid;
    if (animalUuid == null) {
      _showSaveFirstMessage();
      return;
    }
    await showWeightForm(
      context,
      animalUuid: animalUuid,
      dispatchAndAwait: _dispatchRecordAndAwait,
      onReload: () {},
    );
  }

  Future<void> _openHealthShortcut() async {
    final animalUuid = _currentAnimalUuid;
    if (animalUuid == null) {
      _showSaveFirstMessage();
      return;
    }
    await showHealthForm(
      context,
      animalUuid: animalUuid,
      dispatchAndAwait: _dispatchRecordAndAwait,
      onReload: () {},
    );
  }

  Future<void> _openProductionShortcut() async {
    final animalUuid = _currentAnimalUuid;
    if (animalUuid == null) {
      _showSaveFirstMessage();
      return;
    }
    await showProductionForm(
      context,
      animalUuid: animalUuid,
      dispatchAndAwait: _dispatchRecordAndAwait,
      onReload: () {},
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool open,
    required ValueChanged<bool> onToggle,
    required Widget child,
  }) {
    return Card(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onToggle(!open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(open ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: open
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  Widget _buildParentPicker({
    required String label,
    required String? selectedUuid,
    required VoidCallback onTap,
  }) {
    final selectedAnimal = _findAnimal(selectedUuid);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.chevron_right),
        ),
        child: Text(
          selectedAnimal == null
              ? AppLocalizations.of(context).actionSelect
              : _animalLabel(selectedAnimal),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_saving) return;

    final l10n = AppLocalizations.of(context);
    final earTag = _earTagCtrl.text.trim();
    final breed =
        _normalizedText(_breedCtrl.text) ?? l10n.animalFormUnknownBreed;
    final resolvedSpecies = _registerAsCalf ? Species.cattle : _species;
    final resolvedCategory = _registerAsCalf ? Category.calf : _category;

    if (earTag.isEmpty && resolvedSpecies == Species.cattle) {
      final accepted = await _askEarTagWarning();
      if (!accepted) {
        return;
      }
    }

    if (earTag.isNotEmpty) {
      final duplicated = await _isEarTagDuplicated(
        earTag: earTag,
        excludeUuid: _editingAnimal?.uuid,
      );
      if (duplicated) {
        _showMessage(l10n.animalFormDuplicateEarTag);
        return;
      }
    }

    final parsedWeight = _parseOptionalDouble(_weightCtrl.text);
    if (_weightCtrl.text.trim().isNotEmpty && parsedWeight == null) {
      _showMessage(l10n.detailFormWeightErrorInvalid);
      return;
    }

    final parsedPurchase = _parseOptionalDouble(_purchaseCtrl.text);
    if (_purchaseCtrl.text.trim().isNotEmpty && parsedPurchase == null) {
      _showMessage(l10n.animalFormInvalidPurchasePrice);
      return;
    }

    setState(() {
      _saving = true;
    });

    final resolvedDamUuid = _registerAsCalf
        ? (_selectedDamUuid ?? _findAutoDamCandidate()?.uuid)
        : _selectedDamUuid;

    if (_registerAsCalf &&
        _selectedDamUuid == null &&
        resolvedDamUuid == null) {
      _showMessage(l10n.animalFormNoAutoMotherFound);
    }

    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: _birthDate,
      species: resolvedSpecies,
      sex: _sex,
    );

    final now = DateTime.now();
    var saved = false;

    try {
      if (widget.isEdit && _editingAnimal == null) {
        _showMessage(l10n.detailNotFound);
        return;
      }

      if (widget.isEdit && _editingAnimal != null) {
        final updated = _editingAnimal!.copyWith(
          earTagNumber: earTag,
          customName: _normalizedText(_customNameCtrl.text),
          visualId: _normalizedText(_customNameCtrl.text),
          species: resolvedSpecies,
          category: resolvedCategory,
          lifeStage: lifecycle.lifeStage,
          sex: _sex,
          breed: breed,
          birthDate: _birthDate,
          ageMonths: lifecycle.ageMonths,
          weight: parsedWeight,
          sireUuid: _selectedSireUuid,
          damUuid: resolvedDamUuid,
          vaccinated: _vaccinated,
          dewormed: _dewormed,
          hasVitamins: _hasVitamins,
          hasChronicIssues: _hasChronicIssues,
          chronicNotes: _normalizedText(_notesCtrl.text),
          owner: _normalizedText(_ownerCtrl.text),
          purchasePrice: parsedPurchase,
          status: _status,
          currentPaddockId: _selectedLocationId,
          initialLocationId:
              _editingAnimal!.initialLocationId ?? _selectedLocationId,
          lastMovementDate: now,
          batchUuid: _selectedBatchUuid,
          synced: false,
          lastUpdateDate: now,
        );
        saved = await _dispatchAndAwait(UpdateAnimal(updated));
      } else {
        final animal = AnimalEntity(
          id: null,
          uuid: 'ani-${now.microsecondsSinceEpoch}',
          earTagNumber: earTag,
          customName: _normalizedText(_customNameCtrl.text),
          visualId: _normalizedText(_customNameCtrl.text),
          brand: null,
          rfidTag: null,
          species: resolvedSpecies,
          category: resolvedCategory,
          lifeStage: lifecycle.lifeStage,
          sex: _sex,
          breed: breed,
          birthDate: _birthDate,
          ageMonths: lifecycle.ageMonths,
          weight: parsedWeight,
          sireUuid: _selectedSireUuid,
          damUuid: resolvedDamUuid,
          generation: 1,
          healthStatus: HealthStatus.good,
          bodyConditionScore: null,
          vaccinated: _vaccinated,
          dewormed: _dewormed,
          hasVitamins: _hasVitamins,
          hasChronicIssues: _hasChronicIssues,
          chronicNotes: _normalizedText(_notesCtrl.text),
          reproductiveStatus: ReproductiveStatus.unknown,
          firstServiceDate: null,
          lastServiceDate: null,
          expectedCalvingDate: null,
          productionPurpose: ProductionPurpose.undefined,
          productionStage: ProductionStage.unknown,
          productionSystem: ProductionSystem.unknown,
          feedType: null,
          dailyGainEstimate: null,
          currentPaddockId: _selectedLocationId,
          initialLocationId: _selectedLocationId,
          lastMovementDate: now,
          underObservation: false,
          requiresAttention: false,
          riskLevel: RiskLevel.low,
          profilePhoto: null,
          gallery: const [],
          owner: _normalizedText(_ownerCtrl.text),
          purchasePrice: parsedPurchase,
          status: _status,
          synced: false,
          remoteId: null,
          syncDate: null,
          contentHash: null,
          creationDate: now,
          lastUpdateDate: now,
          batchUuid: _selectedBatchUuid,
        );
        saved = await _dispatchAndAwait(AddAnimal(animal));
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }

    if (!mounted || !saved) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.isEdit
        ? l10n.animalFormEditTitle
        : l10n.animalFormCreateTitle;
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: l10n.sectionIdentification,
                        icon: Icons.badge_outlined,
                        open: _idSectionOpen,
                        onToggle: (value) {
                          setState(() {
                            _idSectionOpen = value;
                          });
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _earTagCtrl,
                                    decoration: InputDecoration(
                                      labelText: l10n.labelEarTag,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _customNameCtrl,
                                    decoration: InputDecoration(
                                      labelText: l10n.animalFormNameOrVisualId,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _breedCtrl,
                                    decoration: InputDecoration(
                                      labelText: l10n.animalFormBreedOptional,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<Species>(
                                    key: ValueKey(_species),
                                    initialValue: _species,
                                    decoration: InputDecoration(
                                      labelText: l10n.labelSpecies,
                                      border: const OutlineInputBorder(),
                                    ),
                                    items: Species.values
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value.displayName),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _onSpeciesChanged(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<Sex>(
                                    initialValue: _sex,
                                    decoration: InputDecoration(
                                      labelText: l10n.labelSex,
                                      border: const OutlineInputBorder(),
                                    ),
                                    items: Sex.values
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value.displayName),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _sex = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<Category>(
                                    key: ValueKey(_category),
                                    initialValue: _category,
                                    decoration: InputDecoration(
                                      labelText: l10n.labelCategory,
                                      border: const OutlineInputBorder(),
                                    ),
                                    items: Category.values
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value.displayName),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _onCategoryChanged(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.today),
                                    label: Text(_formatDate(_birthDate)),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _birthDate,
                                        firstDate: DateTime(1990),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked == null) return;
                                      setState(() {
                                        _birthDate = picked;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<AnimalStatus>(
                                    initialValue: _status,
                                    decoration: InputDecoration(
                                      labelText: l10n.animalFormStatus,
                                      border: const OutlineInputBorder(),
                                    ),
                                    items: AnimalStatus.values
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value.displayName),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _status = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildSectionCard(
                                    title: l10n.animalFormSectionOrigin,
                                    icon: Icons.account_tree_outlined,
                                    open: _originSectionOpen,
                                    onToggle: (value) {
                                      setState(() {
                                        _originSectionOpen = value;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        _buildParentPicker(
                                          label: l10n.animalFormMotherOptional,
                                          selectedUuid: _selectedDamUuid,
                                          onTap: () async {
                                            final selected = await _pickParent(
                                              title:
                                                  l10n.animalFormSelectMother,
                                              source: _parentsBySex(Sex.female),
                                            );
                                            if (!mounted) return;
                                            setState(() {
                                              _selectedDamUuid = selected;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        _buildParentPicker(
                                          label: l10n.animalFormFatherOptional,
                                          selectedUuid: _selectedSireUuid,
                                          onTap: () async {
                                            final selected = await _pickParent(
                                              title:
                                                  l10n.animalFormSelectFather,
                                              source: _parentsBySex(Sex.male),
                                            );
                                            if (!mounted) return;
                                            setState(() {
                                              _selectedSireUuid = selected;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSectionCard(
                                    title: l10n.sectionLocation,
                                    icon: Icons.place_outlined,
                                    open: _locationSectionOpen,
                                    onToggle: (value) {
                                      setState(() {
                                        _locationSectionOpen = value;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        DropdownButtonFormField<String?>(
                                          initialValue: _selectedLocationId,
                                          decoration: InputDecoration(
                                            labelText: l10n.navLocations,
                                            border: const OutlineInputBorder(),
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: null,
                                              child: Text(
                                                l10n.animalFormNoLocation,
                                              ),
                                            ),
                                            ..._locations.map(
                                              (loc) => DropdownMenuItem(
                                                value: loc.uuid,
                                                child: Text(loc.name),
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedLocationId = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        DropdownButtonFormField<String?>(
                                          initialValue: _selectedBatchUuid,
                                          decoration: InputDecoration(
                                            labelText: l10n.labelBatch,
                                            border: const OutlineInputBorder(),
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: null,
                                              child: Text(
                                                l10n.animalFormNoBatch,
                                              ),
                                            ),
                                            ..._activeLotes.map(
                                              (lote) => DropdownMenuItem(
                                                value: lote.uuid,
                                                child: Text(lote.nombre),
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedBatchUuid = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildSectionCard(
                                  title: l10n.animalFormSectionOrigin,
                                  icon: Icons.account_tree_outlined,
                                  open: _originSectionOpen,
                                  onToggle: (value) {
                                    setState(() {
                                      _originSectionOpen = value;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      _buildParentPicker(
                                        label: l10n.animalFormMotherOptional,
                                        selectedUuid: _selectedDamUuid,
                                        onTap: () async {
                                          final selected = await _pickParent(
                                            title: l10n.animalFormSelectMother,
                                            source: _parentsBySex(Sex.female),
                                          );
                                          if (!mounted) return;
                                          setState(() {
                                            _selectedDamUuid = selected;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildParentPicker(
                                        label: l10n.animalFormFatherOptional,
                                        selectedUuid: _selectedSireUuid,
                                        onTap: () async {
                                          final selected = await _pickParent(
                                            title: l10n.animalFormSelectFather,
                                            source: _parentsBySex(Sex.male),
                                          );
                                          if (!mounted) return;
                                          setState(() {
                                            _selectedSireUuid = selected;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildSectionCard(
                                  title: l10n.sectionLocation,
                                  icon: Icons.place_outlined,
                                  open: _locationSectionOpen,
                                  onToggle: (value) {
                                    setState(() {
                                      _locationSectionOpen = value;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<String?>(
                                        initialValue: _selectedLocationId,
                                        decoration: InputDecoration(
                                          labelText: l10n.navLocations,
                                          border: const OutlineInputBorder(),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text(
                                              l10n.animalFormNoLocation,
                                            ),
                                          ),
                                          ..._locations.map(
                                            (loc) => DropdownMenuItem(
                                              value: loc.uuid,
                                              child: Text(loc.name),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedLocationId = value;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      DropdownButtonFormField<String?>(
                                        initialValue: _selectedBatchUuid,
                                        decoration: InputDecoration(
                                          labelText: l10n.labelBatch,
                                          border: const OutlineInputBorder(),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text(l10n.animalFormNoBatch),
                                          ),
                                          ..._activeLotes.map(
                                            (lote) => DropdownMenuItem(
                                              value: lote.uuid,
                                              child: Text(lote.nombre),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedBatchUuid = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 10),
                      _buildSectionCard(
                        title: l10n.animalFormSectionWeightHealth,
                        icon: Icons.monitor_weight_outlined,
                        open: _healthSectionOpen,
                        onToggle: (value) {
                          setState(() {
                            _healthSectionOpen = value;
                          });
                        },
                        child: Column(
                          children: [
                            TextField(
                              controller: _weightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.animalFormWeightOptional,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.labelVaccinated),
                              value: _vaccinated,
                              onChanged: (value) {
                                setState(() {
                                  _vaccinated = value;
                                });
                              },
                            ),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.labelDewormed),
                              value: _dewormed,
                              onChanged: (value) {
                                setState(() {
                                  _dewormed = value;
                                });
                              },
                            ),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.labelVitamins),
                              value: _hasVitamins,
                              onChanged: (value) {
                                setState(() {
                                  _hasVitamins = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _openWeightShortcut,
                                  icon: const Icon(Icons.add_chart_outlined),
                                  label: Text(l10n.detailFormWeightTitle),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _openHealthShortcut,
                                  icon: const Icon(Icons.medical_services),
                                  label: Text(l10n.detailFormHealthTitle),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSectionCard(
                        title: l10n.animalFormSectionNotesPhoto,
                        icon: Icons.photo_camera_outlined,
                        open: _notesSectionOpen,
                        onToggle: (value) {
                          setState(() {
                            _notesSectionOpen = value;
                          });
                        },
                        child: Column(
                          children: [
                            TextField(
                              controller: _ownerCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.animalFormOwnerOptional,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _purchaseCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.animalFormPurchasePriceOptional,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.labelChronicCondition),
                              value: _hasChronicIssues,
                              onChanged: (value) {
                                setState(() {
                                  _hasChronicIssues = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: l10n.fieldNotes,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: _openProductionShortcut,
                                icon: const Icon(Icons.analytics_outlined),
                                label: Text(l10n.detailFormProductionTitle),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_currentAnimalUuid == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            l10n.animalFormRecordsAvailableAfterSave,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      CheckboxListTile.adaptive(
                        value: _registerAsCalf,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.animalFormRegisterAsCalf),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _registerAsCalf = value;
                            if (_registerAsCalf) {
                              _species = Species.cattle;
                              _category = Category.calf;
                            }
                          });
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _submit,
                          icon: Icon(widget.isEdit ? Icons.save : Icons.add),
                          label: Text(
                            _saving
                                ? l10n.animalFormSaving
                                : l10n.animalFormSaveAnimal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
