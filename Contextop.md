## PROJECT CONTEXT (synthesized from exhaustive codebase analysis)

### Reality Check Status (2026-05-28)
- **Verification scope**: exhaustively spot-checked against live code (`pubspec.yaml`, `lib/main.dart`, `lib/app/app_router.dart`, `lib/app/app_bloc.dart`, `lib/core/router/app_routes.dart`, `lib/core/di/injection.dart`, `lib/core/utils/`, `lib/features/agenda/`, `lib/features/finanzas/`, `lib/features/exportar/`, `lib/features/inicio/`, `lib/features/perfil/`, `lib/core/services/`, `lib/core/security/` ports+services, `lib/core/mock/`, `lib/features/registro/bloc/`, all route constants, animales record repositories, AnimalBloc, AnimalesBloc, UbicacionesBloc, pagination state, and full test tree).
- **Confidence**: High for project identity, module layout, persistence stack, all features, security layer, and technical debt; updated to reflect 2026-05-28 codebase state.
- **Note**: This is still a synthesis document, not a generated schema.

### Project Identity
- **Name**: Libretapp
- **Description**: "Control Ganadero" — A livestock (cattle, goat, sheep, pig, equine, poultry) farm management mobile/desktop application
- **Tech Stack**: Flutter 3.10.8+, Dart SDK ^3.10.8
- **Architecture**: Clean Architecture + BLoC pattern + Feature-first organization
- **Storage**: Isar v3.1.0 (embedded NoSQL database) + SharedPreferences v2.3.2
- **DI**: GetIt v7.6.7
- **Routing**: GoRouter v14.0.0
- **State**: flutter_bloc ^8.1.0
- **Native**: C++ native library `libret_core` via FFI (dart:ffi ^2.1.3)
- **Localization**: Flutter intl with ARB files, `flutter_localizations` SDK
- **Value objects**: Equatable ^2.0.5
- **Export**: excel ^4.0.6, share_plus ^10.0.0, file_picker ^8.1.2
- **Streams**: stream_transform ^2.1.0
- **UI**: flutter_slidable ^3.1.1
- **Version**: 1.0.0+1

### Architecture Style: Clean Architecture + BLoC
The app follows a feature-first Clean Architecture with 3 layers per feature:
1. **Domain** — Entities, enums, repository interfaces (contracts), domain services. No Flutter dependencies.
2. **Infrastructure** — Repository implementations (Isar), remote data sources, model mappers (entity ↔ Isar model).
3. **BLoC/Presentation** — BLoC classes (state management), application services, views (pages), widgets.

Core shared infrastructure lives in `lib/core/`:
- `database/` — Isar singleton initialization
- `di/` — GetIt service locator
- `services/` — LoggerService, SharedPrefsService, ThemeRepository, BackupService, ExportService
- `router/` — GoRouter route definitions
- `security/` — Auth & crypto ports (auth, crypto, key_provider, secure_store, sensitive_logger, token) + services (auth, native_crypto, crypto_stub, default_key_provider, prefs_secure_store, secure_logger, token_store) + models (security_types, credentials)
- `performance/` — Performance monitoring, navigation tracing, interaction tracing
- `native/ffi/` — Dart FFI bindings to native C++ library
- `advisor/` — Livestock advisory rules engine
- `models/` — Mixins (Syncable, Auditable), TimestampedRecord
- `constants/` — UI design tokens (spacing, radii)
- `extensions/` — Dart extension methods (context_extensions, etc.)
- `widgets/` — Shared widgets (app_card, app_chip, app_empty_state, app_search_bar, responsive_scaler)
- `mock/` — MockDataSeeder (dev/demo data seeder, independent of repositories)
- `l10n/` — Generated localizations

### Directory Map

```
libretapp/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app/
│   │   ├── app.dart                       # MaterialApp widget
│   │   ├── app_bloc.dart                  # App-level BLoC (initialization)
│   │   ├── app_event.dart                 # App events
│   │   ├── app_state.dart                 # App states
│   │   ├── app_router.dart                # GoRouter setup & provider
│   │   ├── app_shell.dart                 # Shell with BottomNavigationBar
│   │   ├── app_index.dart                 # Index redirection router
│   │   ├── theme/                         # ThemeBloc (light/dark/system)
│   │   │   ├── theme_bloc.dart
│   │   │   ├── theme_event.dart
│   │   │   └── theme_state.dart
│   │   └── widgets/
│   │       ├── app_bottom_nav_bar.dart     # Bottom nav bar component
│   │       ├── app_shell_fab.dart          # Shell FAB configuration
│   │       ├── shell_chrome.dart           # Shell chrome (nav, scaffold)
│   │       ├── shell_fab.dart              # FAB widget with config scope
│   │       └── shell_insets.dart           # Safe area insets for shell
│   ├── core/
│   │   ├── core.dart                      # Core barrel export
│   │   ├── di/injection.dart              # GetIt service locator registration
│   │   ├── database/isar_database.dart    # Isar singleton & initialization
│   │   ├── router/app_routes.dart         # All GoRouter route definitions
│   │   ├── services/
│   │   │   ├── logger_service.dart        # Simple structured logger
│   │   │   ├── shared_prefs_service.dart  # Typed SharedPreferences wrapper
│   │   │   ├── prefs_keys.dart            # SharedPreferences key constants
│   │   │   ├── theme_repository.dart      # Persists/loads theme mode
│   │   │   ├── backup_service.dart        # JSON backup/import for animals & lotes
│   │   │   └── export_service.dart        # Excel (.xlsx) export via AnimalRepository, LocationRepository, AgendaRepository
│   │   ├── security/
│   │   │   ├── ports/
│   │   │   │   ├── auth_port.dart             # Abstract auth interface
│   │   │   │   ├── crypto_port.dart           # Abstract crypto interface
│   │   │   │   ├── key_provider_port.dart     # Abstract key management interface
│   │   │   │   ├── secure_store_port.dart     # Abstract secure storage interface
│   │   │   │   ├── sensitive_logger_port.dart # Abstract PII-aware logger interface
│   │   │   │   └── token_port.dart            # Abstract token management interface
│   │   │   ├── services/
│   │   │   │   ├── auth_service.dart              # Auth service
│   │   │   │   ├── native_crypto_service.dart     # Crypto via native FFI
│   │   │   │   ├── crypto_stub_service.dart       # Stub crypto (non-native fallback)
│   │   │   │   ├── default_key_provider_service.dart # Default key derivation
│   │   │   │   ├── prefs_secure_store_service.dart   # SharedPrefs-backed secure store
│   │   │   │   ├── secure_logger_service.dart     # PII-redacting logger
│   │   │   │   └── token_store_service.dart       # Token lifecycle management
│   │   │   └── models/
│   │   │       ├── credentials.dart           # AuthCredentials, AuthResult
│   │   │       └── security_types.dart        # CipherText, TokenBundle, PiiKind, SecurityException
│   │   ├── native/ffi/
│   │   │   └── libret_native_bridge.dart  # FFI bindings to libret_core
│   │   ├── performance/
│   │   │   ├── performance_monitor.dart   # App performance monitoring
│   │   │   ├── navigation_tracer.dart    # Navigation timing tracer
│   │   │   └── interaction_tracer.dart   # User interaction tracer
│   │   ├── advisor/
│   │   │   ├── livestock_advisor.dart    # Advisory rules engine
│   │   │   ├── rules/                    # Rule definitions
│   │   │   └── widgets/                  # Advisor UI components
│   │   ├── models/
│   │   │   ├── syncable.dart             # Syncable mixin (synced, remoteId, syncDate)
│   │   │   ├── auditable.dart            # Auditable mixin (creationDate, lastUpdateDate)
│   │   │   └── timestamped_record.dart   # Base timestamped record
│   │   ├── constants/
│   │   │   ├── ui_constants.dart         # UI spacing/radii tokens
│   │   │   └── constants.dart            # Misc constants
│   │   ├── extensions/                   # Dart extension methods (context_extensions, etc.)
│   │   ├── widgets/
│   │   │   ├── app_card.dart             # Shared card widget
│   │   │   ├── app_chip.dart             # Shared chip widget
│   │   │   ├── app_empty_state.dart      # Shared empty state widget
│   │   │   ├── app_search_bar.dart       # Shared search bar widget
│   │   │   └── responsive_scaler.dart    # Responsive layout scaling
│   │   ├── mock/
│   │   │   └── mock_data_seeder.dart     # Dev/demo data seeder (standalone, generates demo animals)
│   │   ├── utils/
│   │   │   └── id_generator.dart         # UUID generation utilities
│   │   └── l10n/                         # Generated localization files
│   ├── theme/
│   │   ├── app_theme.dart                # Full Material 3 light/dark themes
│   │   └── theme.dart                    # Theme barrel export
│   ├── l10n/                             # ARB localization source files
│   ├── features/
│   │   ├── directorio/                   # Directory feature (animals + lots)
│   │   │   ├── directorio.dart           # Barrel export
│   │   │   ├── animales/                 # Animals sub-feature
│   │   │   │   ├── animals.dart          # Barrel export (canonical)
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/         # AnimalEntity, WeightRecord, HealthRecord, ProductionRecord, ReproductionRecord, MovementRecord, CommercialRecord, CostRecord, CareRecord, CareRule, ScheduledCare
│   │   │   │   │   ├── enums/            # Species, Sex, Category, LifeStage, HealthStatus, ReproductiveStatus, ProductionPurpose, ProductionStage, ProductionSystem, RiskLevel, AnimalStatus, OriginType, CareType
│   │   │   │   │   ├── repositories/     # Abstract repo interfaces: HealthRecordRepository (+addHealthRecordToMultiple), WeightRecordRepository, ProductionRecordRepository, ReproductionRecordRepository, CommercialRecordRepository, MovementRecordRepository, CostRecordRepository
│   │   │   │   │   └── services/         # AnimalLifecycleCalculator, CareScheduler, ReproductionScheduler
│   │   │   │   ├── infrastructure/
│   │   │   │   │   ├── animal_repository.dart           # Abstract repository interface
│   │   │   │   │   ├── animal_repository_isar.dart      # Isar implementation + seed (~27 animals)
│   │   │   │   │   ├── animal_dto.dart                  # DTO for remote/export serialization
│   │   │   │   │   ├── animal_remote_data_source.dart   # Remote sync data source (AnimalApiMock)
│   │   │   │   │   ├── health_record_repository_isar.dart    # HealthRecord Isar impl
│   │   │   │   │   ├── weight_record_repository_isar.dart
│   │   │   │   │   ├── production_record_repository_isar.dart
│   │   │   │   │   ├── reproduction_record_repository_isar.dart
│   │   │   │   │   ├── commercial_record_repository_isar.dart
│   │   │   │   │   ├── movement_record_repository_isar.dart
│   │   │   │   │   ├── cost_record_repository_isar.dart
│   │   │   │   │   ├── services/batch_migration_service.dart  # Migrates legacy batch string names to LoteEntity UUIDs
│   │   │   │   │   └── isar/                            # Isar persistence models: IsarAnimal + IsarWeightRecord, IsarHealthRecord, etc. + mapper extensions
│   │   │   │   ├── bloc/                 # AnimalesBloc, AnimalesEvent, AnimalesState (CRUD, search, sort, filter, selection, pagination: hasMore/isLoadingMore/AnimalesLoadMore)
│   │   │   │   ├── application/          # AnimalBloc/AnimalEvent/AnimalState in bloc/ (single-animal detail BLoC, uses all 7 record repos)
│   │   │   │   ├── view/                 # AnimalesListPage, AnimalesListView, AnimalesListController, AnimalDetailPage, RegisterAnimalPage, QuickRegisterAnimalPage, show_animal_filters_sheet, show_create_animal_sheet, plus individual form pages: animal_health_form_page, animal_weight_form_page, animal_production_form_page, animal_reproduction_form_page, animal_commercial_form_page, animal_movement_form_page, animal_cost_form_page, bulk_health_form_page
│   │   │   │   └── widgets/              # AnimalCard, AnimalPalette, AnimalFilterBar, AnimalSearchOverlay, AnimalAssignmentSheet, AnimalBatchManager, LocationBatchSheet, QuickActionsFab, animal_create_form, animal_filters_sheet, detail_error/header/helpers, history_tab, info_tab, records_tab
│   │   │   ├── lotes/                    # Lots sub-feature
│   │   │   │   ├── lotes.dart            # Barrel export
│   │   │   │   ├── lotes_list_view.dart  # Top-level lots list view
│   │   │   │   ├── lotes_tab.dart        # Tab wrapper
│   │   │   │   ├── domain/entities/      # LoteEntity
│   │   │   │   ├── infrastructure/       # LotesRepository abstract, LotesRepositoryIsar + lote_dto.dart + IsarLote + seed (5 lots)
│   │   │   │   ├── bloc/                 # LotesBloc, LotesEvent, LotesState
│   │   │   │   └── view/                 # LoteDetailPage, LoteFormPage
│   │   │   ├── ubicaciones/             # Locations sub-feature (sub-tab)
│   │   │   └── bloc/                     # DirectorioTabBloc, AnimalesTabBloc, LotesTabBloc, UbicacionesTabBloc
│   │   ├── inicio/                       # Home/Dashboard feature
│   │   │   ├── inicio.dart               # Barrel export
│   │   │   ├── data/                     # InicioDashboardService (aggregates stats from all repositories), InicioDashboardData models (alerts, tasks)
│   │   │   ├── bloc/                     # InicioBloc
│   │   │   ├── view/                     # Dashboard view
│   │   │   └── widgets/                  # Dashboard UI components
│   │   ├── agenda/                       # Agenda feature
│   │   │   ├── agenda.dart               # Barrel export
│   │   │   ├── data/                     # AgendaEntry model, AgendaRepository (abstract), IsarAgendaRepository (Isar-backed), AgendaReminderSyncService
│   │   │   ├── bloc/                     # AgendaBloc
│   │   │   ├── view/                     # AgendaPage, AgendaView, AgendaEntryFormPage, AgendaTaskDetailPage
│   │   │   └── widgets/                  # AgendaCalendar, AgendaList, AgendaFormSheet, AgendaSearchBar, AgendaMonthHeader, AgendaLegend, AgendaAnimalSelectorSheet, AgendaSummaryCard
│   │   ├── perfil/                       # User profile feature
│   │   │   ├── perfil.dart               # Barrel export
│   │   │   ├── data/                     # Perfil model (nombre, finca, email, telefono), PerfilRepository (abstract), PerfilSharedPrefsRepository
│   │   │   ├── bloc/                     # PerfilBloc
│   │   │   ├── view/                     # Profile view
│   │   │   └── widgets/                  # ProfileAvatar, ProfileField
│   │   ├── registro/                     # Record/registration feature
│   │   │   ├── registro.dart             # Barrel export
│   │   │   ├── bloc/                     # RegistroBloc, RegistroEvent, RegistroState (save lifecycle for all 8+ record types; sealed classes)
│   │   │   ├── view/                     # 11 registration pages: animal, sanitario, peso, produccion, reproduccion, comercial, movimiento, costo, ingreso, gasto_general, bulk_health_registro
│   │   │   └── widgets/                  # AnimalSelector widget
│   │   ├── ubicaciones/                  # Locations feature
│   │   │   ├── ubicaciones.dart          # Barrel export
│   │   │   ├── domain/                   # LocationEntity, DynamicAttribute, InventoryItem, location_records (VisitRecord, WaterRecord, SaltRecord, ShadeRecord, PastureRecord, SeedingRecord, IrrigationRecord, RainRecord, CostRecord), crop_records (CropRecord, HarvestRecord, CropWateringRecord, CropHealthRecord, CropTask), enums (LocationType, LocationKind, LocationStatus, WaterType, CropGrowthStage, CropStatus, CropTaskType)
│   │   │   ├── infrastructure/           # LocationRepository abstract, IsarLocationRepository (parent/child tree management), IsarLocation (13+ embedded record types)
│   │   │   ├── bloc/                     # UbicacionesBloc (30+ events including location/crop/inventory record CRUD; SelectParentFilter for rancho filtering)
│   │   │   ├── view/                     # UbicacionesPage, UbicacionesView, LocationDetailPage, LocationFormPage, AssignAnimalsPage, LocationRecordSheets, LocationDetailWidgets
│   │   │   └── widgets/                  # LocationCard, LocationEmptyView, LocationFormSheet, LocationSearchBar, CropSheets, InventoryItemFormSheet
│   │   ├── finanzas/                     # Finance feature
│   │   │   ├── finanzas.dart             # Barrel export
│   │   │   ├── application/              # FinanzasBloc, FinanzasEvent, FinanzasState (sealed classes)
│   │   │   ├── domain/
│   │   │   │   ├── entities/             # FinancialPeriodSummary, AnimalProfitability, IncomeRecord, GeneralExpenseRecord, DateRange
│   │   │   │   ├── enums/                # FinancialPeriodPreset (day/week/month/quarter/year/custom)
│   │   │   │   └── repositories/         # Repository interfaces
│   │   │   ├── infrastructure/           # IsarFinanzasRepository, IsarIncomeRecord + .g.dart, IsarGeneralExpenseRecord + .g.dart
│   │   │   └── view/                     # FinanzasPage (4-tab dashboard: summary, income, expenses, profitability)
│   │   └── exportar/                     # Export feature (NEW)
│   │       ├── exportar.dart             # Barrel export
│   │       ├── cubit/                    # ExportCubit, ExportState (Idle → Loading → Success(File) / Error)
│   │       └── view/                     # ExportarPage (checkbox selection UI, invokes ExportService, shares via share_plus)
├── native/
│   └── libret_core/
│       └── src/libret_secure_api.cc      # C++ native library for secure operations
├── test/
│   ├── widget_test.dart
│   ├── core/security/services/token_store_service_test.dart
│   └── features/
│       ├── agenda/agenda_repository_test.dart
│       ├── directorio/
│       │   ├── animales/ (animal_repository_isar_test, animales_bloc_add_animal_test, records_repository_isar_test)
│       │   ├── lotes/lotes_list_view_test.dart
│       │   ├── directorio_view_search_results_test.dart, directorio_bloc_search_test.dart, directorio_search_navigation_test.dart, animales_list_controller_sort_test.dart
│       │   └── animal_form_page_regression_test.dart
│       ├── finanzas/
│       │   ├── domain/ (animal_profitability_test, date_range_test, financial_period_summary_test, general_expense_record_test, income_record_test)
│       │   ├── infrastructure/isar_finanzas_repository_test.dart
│       │   └── application/finanzas_cubit_test.dart
│       ├── registro/registro_pages_validation_test.dart
│       └── ubicaciones/ (4 tests: page, form, bloc, empty_view)
├── assets/images/
├── docs/ARQUITECTURA.md (Spanish architecture docs)
├── REFACTORING_SUMMARY.md
├── IMPLEMENTATION_SUMMARY.md
├── pubspec.yaml
├── analysis_options.yaml
├── l10n.yaml
└── (Context document is `Contextop.md` at workspace root)
```

### Core Modules & Data Models

**AnimalEntity** — Central domain entity (~90+ fields across 15 categories):
- Identification: uuid, earTagNumber, customName, visualId, brand, rfidTag, batchUuid (deprecated: batchId)
- Biological: Species enum (cattle, equine, goat, sheep, pig, poultry, other), Category enum, LifeStage enum (calf, heifer, youngBull, steer, cow, bull, etc.), Sex enum, breed, crossBreed, generation (int?), sireUuid, damUuid
- Vital: birthDate, ageMonths, weight, AnimalStatus enum
- Health: HealthStatus enum, bodyConditionScore, vaccinated, dewormed, hasVitamins, hasChronicIssues, chronicNotes
- Reproductive: ReproductiveStatus enum, firstServiceDate, lastServiceDate, expectedCalvingDate
- Production: ProductionPurpose enum (dairy, meat, breeding, work, dual, other, undefined), ProductionStage enum, ProductionSystem enum, feedType, dailyGainEstimate
- Registration: coatColor, distinguishingMarks, notes, originType, provenance, crossBreedType, sireBreed, damBreed, bloodPercentage, genealogicalRegistry, originNotes, housingType, shadingAvailability, animalWaterSource, approximateDensity, locationNotes, feedFrequency, feedSupplements, feedNotes, earTagColor
- Location: currentPaddockId, initialLocationId, lastMovementDate
- Monitoring: underObservation, requiresAttention, RiskLevel enum
- Multimedia: profilePhoto, gallery (List<String>)
- Owner: owner, purchasePrice
- Sync: synced bool, remoteId, syncDate, contentHash, creationDate, lastUpdateDate
- Computed: healthSummary, needsImmediateAttention, healthIssueCount, productionSummary, isInProductiveStage, reproductiveSummary, isPregnant, isLactating, primaryIdentifier, identifiers, hasMoved, needsSync, syncStatus, validateSpeciesRequirements(), speciesDisplayName

**LoteEntity** — Logical grouping of animals:
- id, uuid, nombre, descripcion, animalUuids (List<String>), fechaCreacion, fechaCierre, activo, notas, currentLocationId (String? — UUID of parent LocationEntity), lastUpdateDate, synced, remoteId, syncDate

**LocationEntity** — Physical location (paddock, corral, ranch, crop field, etc.):
- id, uuid, name, LocationKind (instance/group), parentUuid, childUuids (tree hierarchy), templateUuid, LocationType enum (rancho, potrero, monte, corral, almacenamiento, aguada, siembra, casa — 8 types with hierarchy; `rancho` is root, leaf types cannot contain children), surfaceArea, capacity, waterSource, terrainType, status (LocationStatus: disponible/en_mantenimiento/clausurada)
- Embedded records: DynamicAttribute[], InventoryItem[], VisitRecord[], WaterRecord[], SaltRecord[], ShadeRecord[], PastureRecord[], SeedingRecord[], IrrigationRecord[], RainRecord[], CostRecord[], CropRecord[]
- CropRecord has: uuid, cropName, variety, plantingDate, expectedHarvestDate, growthStage, wateringFrequencyDays, lastWateredDate, status, surface, notes, harvests[], waterings[], healthRecords[], tasks[]
- InventoryItem has: uuid, name, quantity, unit, notes
- LocationType.canContain() validates parent/child type compatibility; supportsAnimals: potrero/monte/corral; supportsInventory: almacenamiento/casa/corral

**AgendaEntry** — Calendar/managed event:
- id, titulo, descripcion, fecha, tipo, animalId (optional), animalIds (List<String>), ubicacion, estado (pendiente/enProgreso/completado), completedAnimalIds (List<String>), fechaCompletado. Persisted via IsarAgendaRepository (Isar-backed).

**Perfil** — User profile (persisted via SharedPreferences, PerfilSharedPrefsRepository):
- id, nombre, apellido, email, telefono, finca, direccion

**InicioDashboardData** — Aggregated dashboard:
- profileName, farmName, totalAnimals, attentionAnimals, unsyncedAnimals, activeLotes, totalLocations, upcomingEventsCount, upcomingEvents[], alerts[], tasks[], lastUpdated
- categoryBreakdown: List<CategorySummary> (category, total, maleCount, femaleCount)
- upcomingCalvings: List<CalvingItem> (21-day window, sorted by daysRemaining)
- weather: WeatherData? (temperature, maxTemperature, condition, humidity, windSpeed)
- recentActivity: List<RecentActivityItem> (animalUuid, tag, name, lastUpdate, photoPath)
- InicioAlertItem has fields: title, message, severity (critical/warning/info), targetRoute

**FinancialPeriodSummary** — Finance dashboard aggregate (finanzas feature):
- DateRange (start, end: DateTime); totalIncome, totalGeneralExpenses, totalAnimalCosts, totalAnimalSales
- Computed: totalRevenue, totalExpenses, netProfit, profitMargin (%)

**AnimalProfitability** — Per-animal finance breakdown:
- animalUuid, purchaseCost, totalCosts, saleRevenue
- Computed: netResult, isProfitable (bool)

**IncomeRecord** — Income entry:
- uuid, amount, date, description, animalUuid (optional), IncomeType enum (milkSale, woolSale, service, subsidy, other)

**GeneralExpenseRecord** — Farm-level expense (not animal-specific):
- uuid, amount, date, description, GeneralExpenseType enum (fuel, equipment, infrastructure, utilities, labor, taxes, other)

### State Management & UI Flow

- **App-level**: AppBloc handles initialization (events: `AppStarted`, `AppLanguageChanged`; states: `AppInitial`, `AppReady(languageCode)`, `AppLanguageUpdated(languageCode)`). On `AppStarted`: runs `_purgeEventsOnce()` v1 migration flag, syncs automatic reminders via `AgendaReminderSyncService`, and executes `BatchMigrationService`. ThemeBloc (attached at MaterialApp level) manages light/dark/system theme mode, persisted via ThemeRepository (SharedPreferences).
- **Feature-level BLoCs**: Each feature has its own BLoC(s):
  - AnimalesBloc: Manages animal list state, search, sort, filtering by life stage + sex (multi-select), multi-select bulk operations, CRUD, pagination (hasMore/isLoadingMore, pageSize=20). Events include: `LoadAnimales`, `AddAnimal`, `UpdateAnimal`, `DeleteAnimal`, `AnimalesLoadMore`, `AssignAnimalLocationBatch`, `RenameBatch`, `ToggleSearch`, `SearchQueryChanged`, `ClearSearch`, `SetSearchFilters(stages, sexes)`, `ToggleAnimalSelection`, `SelectAllVisibleAnimals`, `ClearAnimalSelection`, `AnimalesStreamUpdated`, `AnimalesStreamFailed`. State `AnimalesLoaded` carries `allAnimals`, `visibleAnimals`, `isSearching`, `searchQuery`, `searchFilterStages`, `searchFilterSexes`, `selectedAnimalUuids`, `hasMore`, `isLoadingMore`, `currentOffset`.
  - AnimalBloc: Manages single-animal detail state and all 7 record-type sub-repositories (weight, health, production, reproduction, commercial, movement, cost)
  - LotesBloc: Manages lots list and form operations
  - InicioBloc: Manages dashboard data aggregation. Events: `LoadInicio`, `RefreshInicio`. Status enum: `initial/loading/loaded/refreshing/error`.
  - AgendaBloc: Manages agenda entries, reminders, and detail views. Events include `MarkAnimalCompleted(entryId, animalId)` which adds animalId to `completedAnimalIds`, auto-transitions estado (pendiente/enProgreso/completado), and sets `fechaCompletado` when fully complete.
  - PerfilBloc: Manages user profile
  - UbicacionesBloc: Manages locations list
  - ThemeBloc: Theme mode (light/dark/system)
  - RegistroBloc: Manages save lifecycle for all record-form types (peso, sanitario, produccion, reproduccion, comercial, movimiento, costo, ingreso, gasto_general). Events and states use **sealed classes**.
  - FinanzasBloc: Manages financial period summary, income/expense aggregation. Events: `LoadPeriod(DateRange)`, `LoadPreset(FinancialPeriodPreset)`, `AddIncome`, `AddExpense`, `DeleteIncome`, `DeleteExpense`. `FinancialPeriodPreset` enum: day/week/month/quarter/year/custom. Events and states use **sealed classes**.
  - ExportCubit: Manages export state (Idle → Loading → Success(File) / Error); triggers ExportService.exportToExcel() and share_plus share dialog. State uses **sealed classes**.
  - DirectorioBloc: Orchestrates AnimalesTabBloc, LotesTabBloc, UbicacionesTabBloc. Events: `LoadDirectorioData`, `ChangeDirectorioTab(tabIndex)`, `StartSearch`, `PerformCombinedSearch(query)`, `ClearSearch`. State `DirectorioLoaded` carries `activeTabIndex` (0: animales, 1: lotes, 2: ubicaciones), `isSearching`, `searchQuery`, `searchResults: List<CombinedSearchResult>`. `CombinedSearchResult` has `type: CombinedSearchType` (animal/lote/ubicacion), `id`, `name`.
- **Navigation**: GoRouter with `StatefulShellRoute.indexedStack`. BottomNavigationBar shell has 5 branches (directorio, agenda, inicio, ubicaciones, perfil), with a central contextual button that switches to inicio or opens `/registro`.
- **UI Architecture**: ShellChromeScope + ShellFabConfigScope provide contextual chrome/FAB configuration. ShellInsets handles safe area.

### Data Layer & Persistence

- **Isar**: Main storage for animals, lots, locations, agenda entries, and finance records. Five Isar collections: IsarAnimal, IsarLote, IsarLocation, IsarAgendaEntry (AgendaRepository migrated from SharedPrefs to Isar), IsarIncomeRecord, IsarGeneralExpenseRecord. Each with generated `.g.dart` files. Embedded records for sub-documents (records, attributes, crops). Reactive streams via `.watch()`.
- **SharedPreferences**: Theme mode, sync hashes/dates, profile data (PerfilSharedPrefsRepository).
- **Remote sync**: `AnimalRemoteDataSource` interface with hash-based change detection. `refreshFromRemote()` compares hash, downloads and upserts animals.
- **Seed data**: IsarAnimal (~27 animals — 19 assigned to lots + 8 unassigned — across 10+ species with realistic data), IsarLote (5 lots), IsarLocation (6 locations with full embedded records) — all seeded on first launch or when empty (fish-in-barrel pattern). `MockDataSeeder` in `core/mock/` provides an independent dev-only seeder.
- **Backup**: `BackupService` serializes animals + lotes to versioned JSON string (export) and supports merge/replaceAll import modes.
- **Export**: `ExportService` generates `.xlsx` files (via `excel` package) with selectable sheets (animals, ubicaciones, agenda). Output saved to temp directory, shared via `share_plus`.
- **Mapping**: All Isar models have mapper extensions (`toEntity()` / `toIsar()` / `fromEntity()`) converting between domain entities and persistence models. Enums stored as strings.

### Security

- **AuthPort** (abstract): Defines login/logout/token management interface.
- **CryptoPort** (abstract): Defines encrypt/decrypt/hash interface.
- **KeyProviderPort** (abstract): Defines key derivation/rotation interface.
- **SecureStorePort** (abstract): Defines secure storage (encrypted prefs) interface.
- **SensitiveLoggerPort** (abstract): Defines PII-aware logging interface.
- **TokenPort** (abstract): Defines token lifecycle (store/retrieve/revoke) interface.
- **NativeCryptoService**: Implements CryptoPort via native FFI to `libret_core` (C++ library).
- **CryptoStubService**: Non-native fallback crypto implementation.
- **DefaultKeyProviderService**: Default key derivation service.
- **PrefsSecureStoreService**: SharedPreferences-backed encrypted store.
- **SecureLoggerService**: PII-redacting logger (wraps LoggerService).
- **AuthService**: Combines AuthPort + CryptoPort for authentication flow.
- **TokenStoreService**: Manages credential/token storage lifecycle. Has dedicated test file.
- **Security types** (`security_types.dart`): `CipherText` (bytes, nonce, tag, keyVersion), `TokenBundle` (accessToken, refreshToken, expiresAtUtc), `PiiKind` enum (email, phone, uuid, generic), `AuthCredentials` (username + secret), `AuthResult` (success, userId, tokenBundle, errorMessage), `SecurityException` (code + message).

### Routes (GoRouter)

- Shell branches:
  - `/directorio` → DirectorioView
  - `/agenda` → AgendaPage
  - `/` → InicioPage
  - `/ubicaciones` → UbicacionesPage
  - `/perfil` → PerfilPage
- Nested under `/directorio`:
  - `/directorio/animales/nuevo` → RegisterAnimalPage
  - `/directorio/animales/nuevo-rapido` → QuickRegisterAnimalPage
  - `/directorio/lotes/nuevo` → LoteFormPage
  - `/directorio/animales/:uuid` → AnimalDetailPage
  - `/directorio/animales/:uuid/editar` → RegisterAnimalPage
  - `/directorio/animales/:uuid/registros/peso` → AnimalWeightFormPage
  - `/directorio/animales/:uuid/registros/salud` → AnimalHealthFormPage
  - `/directorio/animales/:uuid/registros/reproduccion` → AnimalReproductionFormPage
  - `/directorio/animales/:uuid/registros/produccion` → AnimalProductionFormPage
  - `/directorio/animales/:uuid/registros/movimiento` → AnimalMovementFormPage
  - `/directorio/animales/:uuid/registros/comercial` → AnimalCommercialFormPage
  - `/directorio/animales/:uuid/registros/costo` → AnimalCostFormPage
  - `/directorio/lotes/:uuid` → LoteDetailPage
  - `/directorio/lotes/:uuid/editar` → LoteFormPage
- Nested under `/ubicaciones`:
  - `/ubicaciones/nueva` → LocationFormPage
  - `/ubicaciones/:uuid` → LocationDetailPage
  - `/ubicaciones/:uuid/editar` → LocationFormPage
- Nested under `/agenda`:
  - `/agenda/nuevo` → AgendaEntryFormPage
  - `/agenda/task/:id` → AgendaTaskDetailPage
- Standalone:
  - `/registro` → RegistroPage
  - `/registro/sanitario`, `/registro/peso`, `/registro/produccion`, `/registro/reproduccion`, `/registro/comercial`, `/registro/movimiento`, `/registro/costo`
  - `/registro/ingreso` → RegistroIngresoPage
  - `/registro/gasto-general` → RegistroGastoGeneralPage
  - `/registro/tratar-lote` → BulkHealthRegistroPage
- Route-only (not in BottomNavigationBar):
  - `/finanzas` → FinanzasPage
  - `/exportar` → ExportarPage

### Theme System

- **AppTheme** (in `lib/theme/app_theme.dart`): Full Material 3 light & dark themes.
- **Color scheme**: Seed color `#1F6F4A` (dark ranch green). Secondary: muted blue. Accent: warm amber.
- **ShellChromeTheme**: Custom `ThemeExtension` for nav background/shadow and FAB colors.
- **Design tokens**: AppColors (primary, secondary, accent, success, warning, error), LightColors, DarkColors, AppSpacing (4/8/12/16/20/24/32), AppRadii (8/12/16), AppTextStyles (titleLg, titleMd, body, label).

### Build, Test, Deploy

- **SDK**: Dart ^3.10.8, Flutter (latest stable assumed)
- **Code generation**: `flutter pub run build_runner build` for Isar `.g.dart` files
- **Localization**: `flutter gen-l10n` (configured via l10n.yaml)
- **Linting**: flutter_lints ^6.0.0 via analysis_options.yaml
- **Tests**: 24 test files using flutter_test. Test coverage includes: animal repository (Isar CRUD), animales bloc (add animal), records_repository_isar (health/weight/production/reproduction/commercial/movement/cost Isar repos), search/sort/filter functionality, animales_list_controller sort, directorio search navigation, location pages/bloc, registro page validation, security token store, lotes list view, agenda repository (Isar), finanzas domain entities (animal_profitability, date_range, financial_period_summary, general_expense_record, income_record), finanzas Isar repository, finanzas cubit.
- **CI/CD**: No CI/CD config found in repository. Assume manual build or standard Flutter CI.
- **Native build**: Requires C++ compiler for `libret_core` native library. ffigen ^15.0.0 for FFI binding generation.
- **Assets**: `assets/images/` directory configured.

### Design Decisions & Technical Debt

**Decisions:**
1. **Clean Architecture + BLoC**: Chosen for testability, separation of concerns, and reactive state management. BLoC is the recommended Flutter state management from the Flutter team.
2. **Isar over SQLite/Hive**: Isar provides an embedded NoSQL document database with reactive streams, indexing, and no native dependencies for core functionality. Chosen for offline-first design.
3. **Feature-first over Layer-first**: Features contain their own domain/infrastructure/presentation layers. Enables independent feature development and potential future extraction into packages.
4. **UUID-based identification**: All entities use String UUIDs for primary identification. Enables offline creation without ID conflicts. Int auto-increment IDs are internal to Isar only.
5. **Enum-as-string storage**: Enums stored as strings in Isar for readability and backward compatibility. The `_enumByName` helper with safe defaults handles deserialization.
6. **Sync-ready architecture**: All entities have `synced`, `remoteId`, `syncDate`, `lastUpdateDate` fields. Repository interfaces include sync methods (`markAsSynced`, `refreshFromRemote`). Hash-based change detection prevents redundant remote updates.
7. **Seed data as demo/tutorial**: Realistic seed data (~27 animals — 19 assigned + 8 unassigned —, 5 lots, 6 locations) with complete records for demonstration and development. Fish-in-barrel pattern (checks if empty/missing before seeding). `MockDataSeeder` in `core/mock/` provides a standalone dev seeder independent of repositories.
8. **Theme extension for shell chrome**: Custom `ThemeExtension<ShellChromeTheme>` provides nav/FAB colors outside the Material color system, enabling per-theme shell customization.
9. **Native FFI for security**: Cryptographic operations delegated to native C++ library for performance and security-sensitive operations.
10. **Agenda stored in Isar**: Agenda entries are now managed via `IsarAgendaRepository` (previously SharedPreferences). Enables reactive streams, richer querying, and per-entry animal completion tracking.

**Technical Debt & Areas for Refactoring:**
1. **AnimalRepositoryIsar god class partially resolved**: Specialized record repositories have been extracted (HealthRecordRepository, WeightRecordRepository, ProductionRecordRepository, ReproductionRecordRepository, CommercialRecordRepository, MovementRecordRepository, CostRecordRepository) with dedicated Isar implementations. AnimalRepositoryIsar now delegates record CRUD to these repos. Animal detail BLoC (AnimalBloc) also extracted to application/bloc/.
2. **PerfilRepository migrated to SharedPreferences**: Now backed by `PerfilSharedPrefsRepository`. Profile data is persisted across sessions. A full Isar or backend-API implementation could be a future improvement.
3. **AgendaRepository migrated to Isar**: `IsarAgendaRepository` replaces the old JSON/SharedPrefs storage. Supports reactive streams and per-entry animal completion state.
4. **No real backend API implemented**: `AnimalRemoteDataSource` has a concrete `AnimalApiMock`, but no HTTP backend implementation yet.
5. **Duplicate seed data pattern**: `_seedIfEmpty` duplicated across AnimalRepositoryIsar, LotesRepositoryIsar, and IsarLocationRepository. Could be centralized in database initialization.
6. **IsarLocationRepository has tight coupling**: Directly manages parent/child tree relationships in write transactions. Could use a tree management service.
7. **Missing error handling in some BLoCs**: Some event handlers lack try/catch for user-facing error messages (e.g., network failures, database errors).
8. **AnimalEntity has >50 fields**: Large entity with many optional fields. Consider value objects (e.g., `HealthInfo`, `ReproductiveInfo`, `ProductionInfo`) to group related fields.
9. **Pagination implemented**: AnimalesLoaded now has hasMore and isLoadingMore flags; AnimalesLoadMore event triggers incremental page fetches. Scroll-triggered via _handleScroll in AnimalesListView.
10. **Native library incomplete**: Only a single `.cc` file exists. FFI bindings are defined but native build integration is not fully wired in the Flutter project.
11. **ExportService is tightly coupled to 3 repositories**: `ExportService` directly depends on `AnimalRepository`, `LocationRepository`, and `AgendaRepository`. Consider a query facade or export DTO layer to decouple export format from domain model internals.

---