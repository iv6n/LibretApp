import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'LibretApp - Control Ganadero'**
  String get appTitle;

  /// No description provided for @navDirectory.
  ///
  /// In es, this message translates to:
  /// **'Directorio'**
  String get navDirectory;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navAnimals.
  ///
  /// In es, this message translates to:
  /// **'Animales'**
  String get navAnimals;

  /// No description provided for @navAgenda.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get navAgenda;

  /// No description provided for @navLocations.
  ///
  /// In es, this message translates to:
  /// **'Ubicaciones'**
  String get navLocations;

  /// No description provided for @navReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get navReports;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navAdd.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get navAdd;

  /// No description provided for @animalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Animales'**
  String get animalsTitle;

  /// No description provided for @animalsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron animales'**
  String get animalsEmptyTitle;

  /// No description provided for @animalsEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ajusta los filtros o la búsqueda'**
  String get animalsEmptySubtitle;

  /// No description provided for @animalsFirstTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay animales'**
  String get animalsFirstTitle;

  /// No description provided for @animalsFirstSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra el primero para empezar a llevar su seguimiento.'**
  String get animalsFirstSubtitle;

  /// No description provided for @animalsFirstAction.
  ///
  /// In es, this message translates to:
  /// **'Registrar animal'**
  String get animalsFirstAction;

  /// No description provided for @animalsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por arete, nombre o raza'**
  String get animalsSearchHint;

  /// No description provided for @animalsAdvancedSearch.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda avanzada'**
  String get animalsAdvancedSearch;

  /// No description provided for @animalsRecentSearches.
  ///
  /// In es, this message translates to:
  /// **'Búsquedas recientes'**
  String get animalsRecentSearches;

  /// No description provided for @animalsRecentActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad reciente'**
  String get animalsRecentActivity;

  /// No description provided for @animalsClearHistory.
  ///
  /// In es, this message translates to:
  /// **'Limpiar historial'**
  String get animalsClearHistory;

  /// No description provided for @animalsFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get animalsFilters;

  /// No description provided for @animalsNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get animalsNoResults;

  /// No description provided for @animalsStageFilterLabel.
  ///
  /// In es, this message translates to:
  /// **'Filtros por etapa'**
  String get animalsStageFilterLabel;

  /// No description provided for @animalsOnlyAttention.
  ///
  /// In es, this message translates to:
  /// **'Solo atención'**
  String get animalsOnlyAttention;

  /// No description provided for @animalsOnlyPendingTag.
  ///
  /// In es, this message translates to:
  /// **'Arete pendiente'**
  String get animalsOnlyPendingTag;

  /// No description provided for @animalsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {{count} animal} other {{count} animales}}'**
  String animalsCount(num count);

  /// No description provided for @animalsSelectionHint.
  ///
  /// In es, this message translates to:
  /// **'Mantener presionado para seleccionar'**
  String get animalsSelectionHint;

  /// No description provided for @animalsSelectedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {{count} seleccionado} other {{count} seleccionados}}'**
  String animalsSelectedCount(num count);

  /// No description provided for @animalsSelectVisible.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar visibles ({selected}/{total})'**
  String animalsSelectVisible(Object selected, Object total);

  /// No description provided for @animalsSelectVisibleSimple.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar visibles'**
  String get animalsSelectVisibleSimple;

  /// No description provided for @animalsDeselectVisible.
  ///
  /// In es, this message translates to:
  /// **'Quitar visibles'**
  String get animalsDeselectVisible;

  /// No description provided for @animalsSelectionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get animalsSelectionCancel;

  /// No description provided for @animalsSelectionHiddenCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {{count} seleccionado está oculto por filtros} other {{count} seleccionados están ocultos por filtros}}'**
  String animalsSelectionHiddenCount(num count);

  /// No description provided for @animalsSelectionAllHiddenWarning.
  ///
  /// In es, this message translates to:
  /// **'Todos los seleccionados están ocultos por filtros activos.'**
  String get animalsSelectionAllHiddenWarning;

  /// No description provided for @animalsBulkMaintenanceAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar mantenimiento ({count})'**
  String animalsBulkMaintenanceAction(Object count);

  /// No description provided for @animalsBulkMaintenanceError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar: {error}'**
  String animalsBulkMaintenanceError(Object error);

  /// No description provided for @animalsBulkMaintenanceConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar mantenimiento'**
  String get animalsBulkMaintenanceConfirmTitle;

  /// No description provided for @animalsBulkMaintenanceConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Se aplicará el mismo mantenimiento a {count} animales.'**
  String animalsBulkMaintenanceConfirmBody(Object count);

  /// No description provided for @animalsBulkMaintenanceConfirmAction.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get animalsBulkMaintenanceConfirmAction;

  /// No description provided for @stageFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get stageFilterAll;

  /// No description provided for @stageFilterCalf.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Becerro} other {Becerros}}'**
  String stageFilterCalf(num count);

  /// No description provided for @stageFilterHeifer.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Vaquilla} other {Vaquillas}}'**
  String stageFilterHeifer(num count);

  /// No description provided for @stageFilterYoungBull.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Torete} other {Toretes}}'**
  String stageFilterYoungBull(num count);

  /// No description provided for @stageFilterSteer.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Novillo} other {Novillos}}'**
  String stageFilterSteer(num count);

  /// No description provided for @stageFilterCow.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Vaca} other {Vacas}}'**
  String stageFilterCow(num count);

  /// No description provided for @stageFilterBull.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Toro} other {Toros}}'**
  String stageFilterBull(num count);

  /// No description provided for @stageFilterColt.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Potro/Potranca} other {Potros/Potrancas}}'**
  String stageFilterColt(num count);

  /// No description provided for @stageFilterHorse.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Caballo} other {Caballos}}'**
  String stageFilterHorse(num count);

  /// No description provided for @stageFilterMare.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Yegua} other {Yeguas}}'**
  String stageFilterMare(num count);

  /// No description provided for @stageFilterDonkey.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Burro/Burra} other {Burros/Burras}}'**
  String stageFilterDonkey(num count);

  /// No description provided for @stageFilterMule.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one {Mula} other {Mulas}}'**
  String stageFilterMule(num count);

  /// No description provided for @animalRequiresAttention.
  ///
  /// In es, this message translates to:
  /// **'Requiere atención'**
  String get animalRequiresAttention;

  /// No description provided for @animalUnderObservation.
  ///
  /// In es, this message translates to:
  /// **'En observación'**
  String get animalUnderObservation;

  /// No description provided for @animalPendingTag.
  ///
  /// In es, this message translates to:
  /// **'Arete pendiente'**
  String get animalPendingTag;

  /// No description provided for @animalAddTag.
  ///
  /// In es, this message translates to:
  /// **'Agregar arete'**
  String get animalAddTag;

  /// No description provided for @animalPendingTagHelp.
  ///
  /// In es, this message translates to:
  /// **'Agrega el número para completar la identificación.'**
  String get animalPendingTagHelp;

  /// No description provided for @animalVaccinated.
  ///
  /// In es, this message translates to:
  /// **'Vacunado'**
  String get animalVaccinated;

  /// No description provided for @animalRisk.
  ///
  /// In es, this message translates to:
  /// **'Riesgo {level}'**
  String animalRisk(Object level);

  /// No description provided for @animalHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get animalHealth;

  /// No description provided for @animalAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get animalAge;

  /// No description provided for @animalBreed.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get animalBreed;

  /// No description provided for @animalDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del animal'**
  String get animalDetailTitle;

  /// No description provided for @tabInformation.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get tabInformation;

  /// No description provided for @tabHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get tabHistory;

  /// No description provided for @sectionIdentification.
  ///
  /// In es, this message translates to:
  /// **'Identificación'**
  String get sectionIdentification;

  /// No description provided for @sectionProductiveProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil productivo'**
  String get sectionProductiveProfile;

  /// No description provided for @sectionHealth.
  ///
  /// In es, this message translates to:
  /// **'Sanidad'**
  String get sectionHealth;

  /// No description provided for @sectionLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación y movimiento'**
  String get sectionLocation;

  /// No description provided for @sectionReproduction.
  ///
  /// In es, this message translates to:
  /// **'Reproducción'**
  String get sectionReproduction;

  /// No description provided for @detailNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró información del animal.'**
  String get detailNotFound;

  /// No description provided for @detailReload.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get detailReload;

  /// No description provided for @detailRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get detailRetry;

  /// No description provided for @detailCreated.
  ///
  /// In es, this message translates to:
  /// **'Creado'**
  String get detailCreated;

  /// No description provided for @detailUpdated.
  ///
  /// In es, this message translates to:
  /// **'Última actualización'**
  String get detailUpdated;

  /// No description provided for @detailLastMovement.
  ///
  /// In es, this message translates to:
  /// **'Último movimiento'**
  String get detailLastMovement;

  /// No description provided for @detailHealth.
  ///
  /// In es, this message translates to:
  /// **'Estado de salud'**
  String get detailHealth;

  /// No description provided for @detailRisk.
  ///
  /// In es, this message translates to:
  /// **'Riesgo'**
  String get detailRisk;

  /// No description provided for @detailVaccinated.
  ///
  /// In es, this message translates to:
  /// **'Vacunado'**
  String get detailVaccinated;

  /// No description provided for @detailSynced.
  ///
  /// In es, this message translates to:
  /// **'Sincronización'**
  String get detailSynced;

  /// No description provided for @detailSyncedValue.
  ///
  /// In es, this message translates to:
  /// **'{isSynced, select, true {Sincronizado} other {Pendiente}}'**
  String detailSyncedValue(String isSynced);

  /// No description provided for @booleanYes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get booleanYes;

  /// No description provided for @booleanNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get booleanNo;

  /// No description provided for @locationChangePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Cambiar ubicación - FASE 3'**
  String get locationChangePlaceholder;

  /// No description provided for @labelEarTag.
  ///
  /// In es, this message translates to:
  /// **'Arete'**
  String get labelEarTag;

  /// No description provided for @labelVisualId.
  ///
  /// In es, this message translates to:
  /// **'ID visual'**
  String get labelVisualId;

  /// No description provided for @labelBrand.
  ///
  /// In es, this message translates to:
  /// **'Marca'**
  String get labelBrand;

  /// No description provided for @labelRfid.
  ///
  /// In es, this message translates to:
  /// **'RFID'**
  String get labelRfid;

  /// No description provided for @labelBatch.
  ///
  /// In es, this message translates to:
  /// **'Lote'**
  String get labelBatch;

  /// No description provided for @labelSpecies.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get labelSpecies;

  /// No description provided for @labelCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get labelCategory;

  /// No description provided for @labelLifeStage.
  ///
  /// In es, this message translates to:
  /// **'Etapa'**
  String get labelLifeStage;

  /// No description provided for @labelSex.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get labelSex;

  /// No description provided for @labelAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get labelAge;

  /// No description provided for @labelBreed.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get labelBreed;

  /// No description provided for @labelPurpose.
  ///
  /// In es, this message translates to:
  /// **'Propósito'**
  String get labelPurpose;

  /// No description provided for @labelFeedType.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get labelFeedType;

  /// No description provided for @labelDailyGain.
  ///
  /// In es, this message translates to:
  /// **'Ganancia diaria estimada'**
  String get labelDailyGain;

  /// No description provided for @labelHealthStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de salud'**
  String get labelHealthStatus;

  /// No description provided for @labelBodyCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición corporal'**
  String get labelBodyCondition;

  /// No description provided for @labelRisk.
  ///
  /// In es, this message translates to:
  /// **'Riesgo'**
  String get labelRisk;

  /// No description provided for @labelVaccinated.
  ///
  /// In es, this message translates to:
  /// **'Vacunado'**
  String get labelVaccinated;

  /// No description provided for @labelDewormed.
  ///
  /// In es, this message translates to:
  /// **'Desparasitado'**
  String get labelDewormed;

  /// No description provided for @labelVitamins.
  ///
  /// In es, this message translates to:
  /// **'Vitaminas'**
  String get labelVitamins;

  /// No description provided for @labelChronicCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición crónica'**
  String get labelChronicCondition;

  /// No description provided for @labelChronicNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas crónicas'**
  String get labelChronicNotes;

  /// No description provided for @labelPaddock.
  ///
  /// In es, this message translates to:
  /// **'Padrón / Potrero'**
  String get labelPaddock;

  /// No description provided for @labelLastMovement.
  ///
  /// In es, this message translates to:
  /// **'Último movimiento'**
  String get labelLastMovement;

  /// No description provided for @labelObservation.
  ///
  /// In es, this message translates to:
  /// **'Observación'**
  String get labelObservation;

  /// No description provided for @labelReproductiveStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado reproductivo'**
  String get labelReproductiveStatus;

  /// No description provided for @labelFirstService.
  ///
  /// In es, this message translates to:
  /// **'1er servicio'**
  String get labelFirstService;

  /// No description provided for @labelLastService.
  ///
  /// In es, this message translates to:
  /// **'Último servicio'**
  String get labelLastService;

  /// No description provided for @labelExpectedCalving.
  ///
  /// In es, this message translates to:
  /// **'Fecha probable de parto'**
  String get labelExpectedCalving;

  /// No description provided for @labelSynced.
  ///
  /// In es, this message translates to:
  /// **'Sincronización'**
  String get labelSynced;

  /// No description provided for @valueYes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get valueYes;

  /// No description provided for @valueNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get valueNo;

  /// No description provided for @valueNotAssigned.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get valueNotAssigned;

  /// No description provided for @valueNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin dato'**
  String get valueNoData;

  /// No description provided for @tabRecords.
  ///
  /// In es, this message translates to:
  /// **'Registros'**
  String get tabRecords;

  /// No description provided for @actionSelect.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get actionSelect;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get actionConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @actionRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get actionRemove;

  /// No description provided for @actionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get actionDelete;

  /// No description provided for @uiSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get uiSearch;

  /// No description provided for @uiFilter.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get uiFilter;

  /// No description provided for @uiClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get uiClear;

  /// No description provided for @uiClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get uiClose;

  /// No description provided for @uiLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get uiLoading;

  /// No description provided for @fieldDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fieldDate;

  /// No description provided for @actionClearDate.
  ///
  /// In es, this message translates to:
  /// **'Borrar fecha'**
  String get actionClearDate;

  /// No description provided for @financeRegisterIncome.
  ///
  /// In es, this message translates to:
  /// **'Registrar ingreso'**
  String get financeRegisterIncome;

  /// No description provided for @financeRegisterExpense.
  ///
  /// In es, this message translates to:
  /// **'Registrar gasto general'**
  String get financeRegisterExpense;

  /// No description provided for @financeIncomeType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de ingreso'**
  String get financeIncomeType;

  /// No description provided for @financeExpenseType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de gasto'**
  String get financeExpenseType;

  /// No description provided for @financeAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get financeAmount;

  /// No description provided for @financeCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get financeCurrency;

  /// No description provided for @financeOptionalAnimal.
  ///
  /// In es, this message translates to:
  /// **'Animal (opcional)'**
  String get financeOptionalAnimal;

  /// No description provided for @financeDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción adicional...'**
  String get financeDescriptionHint;

  /// No description provided for @financeAmountInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido.'**
  String get financeAmountInvalid;

  /// No description provided for @financeAmountPositive.
  ///
  /// In es, this message translates to:
  /// **'El monto debe ser mayor a cero.'**
  String get financeAmountPositive;

  /// No description provided for @financeIncomeSaved.
  ///
  /// In es, this message translates to:
  /// **'Ingreso guardado.'**
  String get financeIncomeSaved;

  /// No description provided for @financeExpenseSaved.
  ///
  /// In es, this message translates to:
  /// **'Gasto guardado.'**
  String get financeExpenseSaved;

  /// No description provided for @uiQuickActions.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get uiQuickActions;

  /// No description provided for @uiCustomize.
  ///
  /// In es, this message translates to:
  /// **'Personalizar accesos rápidos'**
  String get uiCustomize;

  /// No description provided for @errorGenericSave.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al guardar'**
  String get errorGenericSave;

  /// No description provided for @fieldNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get fieldNotes;

  /// No description provided for @fieldNotesOptional.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get fieldNotesOptional;

  /// No description provided for @detailActionWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get detailActionWeight;

  /// No description provided for @detailActionReproduction.
  ///
  /// In es, this message translates to:
  /// **'Reproducción'**
  String get detailActionReproduction;

  /// No description provided for @detailActionProduction.
  ///
  /// In es, this message translates to:
  /// **'Productivo'**
  String get detailActionProduction;

  /// No description provided for @detailActionHealth.
  ///
  /// In es, this message translates to:
  /// **'Sanitario'**
  String get detailActionHealth;

  /// No description provided for @detailActionCommercial.
  ///
  /// In es, this message translates to:
  /// **'Comercial'**
  String get detailActionCommercial;

  /// No description provided for @detailActionMovement.
  ///
  /// In es, this message translates to:
  /// **'Movimiento'**
  String get detailActionMovement;

  /// No description provided for @detailActionCost.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get detailActionCost;

  /// No description provided for @detailRecordsWeights.
  ///
  /// In es, this message translates to:
  /// **'Pesaje'**
  String get detailRecordsWeights;

  /// No description provided for @detailRecordsProduction.
  ///
  /// In es, this message translates to:
  /// **'Productivos'**
  String get detailRecordsProduction;

  /// No description provided for @detailRecordsHealth.
  ///
  /// In es, this message translates to:
  /// **'Sanitarios'**
  String get detailRecordsHealth;

  /// No description provided for @detailRecordsReproduction.
  ///
  /// In es, this message translates to:
  /// **'Reproducción'**
  String get detailRecordsReproduction;

  /// No description provided for @detailRecordsCommercial.
  ///
  /// In es, this message translates to:
  /// **'Comerciales'**
  String get detailRecordsCommercial;

  /// No description provided for @detailRecordsMovements.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get detailRecordsMovements;

  /// No description provided for @detailRecordsCosts.
  ///
  /// In es, this message translates to:
  /// **'Costos'**
  String get detailRecordsCosts;

  /// No description provided for @detailRecordsValue.
  ///
  /// In es, this message translates to:
  /// **'Valor'**
  String get detailRecordsValue;

  /// No description provided for @detailRecordsScore.
  ///
  /// In es, this message translates to:
  /// **'Puntaje'**
  String get detailRecordsScore;

  /// No description provided for @detailRecordsDose.
  ///
  /// In es, this message translates to:
  /// **'Dosis'**
  String get detailRecordsDose;

  /// No description provided for @detailRecordsCause.
  ///
  /// In es, this message translates to:
  /// **'Causa'**
  String get detailRecordsCause;

  /// No description provided for @detailRecordsAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get detailRecordsAmount;

  /// No description provided for @detailRecordsFrom.
  ///
  /// In es, this message translates to:
  /// **'De'**
  String get detailRecordsFrom;

  /// No description provided for @detailRecordsTo.
  ///
  /// In es, this message translates to:
  /// **'A'**
  String get detailRecordsTo;

  /// No description provided for @detailFormWeightTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar peso'**
  String get detailFormWeightTitle;

  /// No description provided for @detailFormWeightValue.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get detailFormWeightValue;

  /// No description provided for @detailFormWeightMethod.
  ///
  /// In es, this message translates to:
  /// **'Método'**
  String get detailFormWeightMethod;

  /// No description provided for @detailFormWeightMethodScale.
  ///
  /// In es, this message translates to:
  /// **'Báscula'**
  String get detailFormWeightMethodScale;

  /// No description provided for @detailFormWeightMethodEstimated.
  ///
  /// In es, this message translates to:
  /// **'Estimado'**
  String get detailFormWeightMethodEstimated;

  /// No description provided for @detailFormAnimalRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un animal primero'**
  String get detailFormAnimalRequired;

  /// No description provided for @detailFormNumberInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número válido'**
  String get detailFormNumberInvalid;

  /// No description provided for @detailFormAmountPositive.
  ///
  /// In es, this message translates to:
  /// **'El valor debe ser mayor que cero'**
  String get detailFormAmountPositive;

  /// No description provided for @detailFormWeightErrorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un peso válido'**
  String get detailFormWeightErrorInvalid;

  /// No description provided for @detailFormWeightSaved.
  ///
  /// In es, this message translates to:
  /// **'Peso registrado'**
  String get detailFormWeightSaved;

  /// No description provided for @detailFormProductionTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro productivo'**
  String get detailFormProductionTitle;

  /// No description provided for @detailFormProductionType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get detailFormProductionType;

  /// No description provided for @detailFormProductionValue.
  ///
  /// In es, this message translates to:
  /// **'Valor (opcional)'**
  String get detailFormProductionValue;

  /// No description provided for @detailFormProductionUnit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get detailFormProductionUnit;

  /// No description provided for @detailFormProductionScore.
  ///
  /// In es, this message translates to:
  /// **'Puntaje/BCS'**
  String get detailFormProductionScore;

  /// No description provided for @detailFormProductionValueRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un valor para este tipo de registro'**
  String get detailFormProductionValueRequired;

  /// No description provided for @detailFormProductionScoreRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un puntaje para condición corporal'**
  String get detailFormProductionScoreRequired;

  /// No description provided for @detailFormProductionScoreInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un puntaje válido'**
  String get detailFormProductionScoreInvalid;

  /// No description provided for @detailFormProductionScoreRange.
  ///
  /// In es, this message translates to:
  /// **'El puntaje debe estar entre 0 y 9'**
  String get detailFormProductionScoreRange;

  /// No description provided for @detailFormProductionDataRequired.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un dato para guardar el registro'**
  String get detailFormProductionDataRequired;

  /// No description provided for @detailFormProductionSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro productivo guardado'**
  String get detailFormProductionSaved;

  /// No description provided for @detailFormHealthTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro sanitario'**
  String get detailFormHealthTitle;

  /// No description provided for @detailFormHealthType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get detailFormHealthType;

  /// No description provided for @detailFormHealthProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto/procedimiento'**
  String get detailFormHealthProduct;

  /// No description provided for @detailFormHealthDose.
  ///
  /// In es, this message translates to:
  /// **'Dosis'**
  String get detailFormHealthDose;

  /// No description provided for @detailFormHealthAppliedBy.
  ///
  /// In es, this message translates to:
  /// **'Aplicado por'**
  String get detailFormHealthAppliedBy;

  /// No description provided for @detailFormHealthNext.
  ///
  /// In es, this message translates to:
  /// **'Próximo (opcional)'**
  String get detailFormHealthNext;

  /// No description provided for @detailFormHealthCause.
  ///
  /// In es, this message translates to:
  /// **'Causa (enfermedad/muerte)'**
  String get detailFormHealthCause;

  /// No description provided for @detailFormHealthProductRequired.
  ///
  /// In es, this message translates to:
  /// **'Producto requerido'**
  String get detailFormHealthProductRequired;

  /// No description provided for @detailFormHealthNextAfterDate.
  ///
  /// In es, this message translates to:
  /// **'La próxima fecha no puede ser anterior a la fecha del registro'**
  String get detailFormHealthNextAfterDate;

  /// No description provided for @detailFormHealthSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro sanitario guardado'**
  String get detailFormHealthSaved;

  /// No description provided for @detailFormHealthMedicineBatch.
  ///
  /// In es, this message translates to:
  /// **'Lote del medicamento'**
  String get detailFormHealthMedicineBatch;

  /// No description provided for @detailFormHealthWithdrawalDays.
  ///
  /// In es, this message translates to:
  /// **'Retiro (días)'**
  String get detailFormHealthWithdrawalDays;

  /// No description provided for @detailFormHealthWithdrawalHelper.
  ///
  /// In es, this message translates to:
  /// **'Carne/leche'**
  String get detailFormHealthWithdrawalHelper;

  /// No description provided for @detailFormCommercialTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro comercial'**
  String get detailFormCommercialTitle;

  /// No description provided for @detailFormCommercialType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get detailFormCommercialType;

  /// No description provided for @detailFormCommercialAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get detailFormCommercialAmount;

  /// No description provided for @detailFormCommercialCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get detailFormCommercialCurrency;

  /// No description provided for @detailFormCommercialCounterparty.
  ///
  /// In es, this message translates to:
  /// **'Contraparte'**
  String get detailFormCommercialCounterparty;

  /// No description provided for @detailFormCommercialAmountRequired.
  ///
  /// In es, this message translates to:
  /// **'Monto requerido para este tipo de registro'**
  String get detailFormCommercialAmountRequired;

  /// No description provided for @detailFormCommercialSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro comercial guardado'**
  String get detailFormCommercialSaved;

  /// No description provided for @detailFormMovementTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimiento'**
  String get detailFormMovementTitle;

  /// No description provided for @detailFormMovementReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get detailFormMovementReason;

  /// No description provided for @detailFormMovementFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde (opcional)'**
  String get detailFormMovementFrom;

  /// No description provided for @detailFormMovementTo.
  ///
  /// In es, this message translates to:
  /// **'Hacia'**
  String get detailFormMovementTo;

  /// No description provided for @detailFormMovementMovedBy.
  ///
  /// In es, this message translates to:
  /// **'Movido por'**
  String get detailFormMovementMovedBy;

  /// No description provided for @detailFormMovementToRequired.
  ///
  /// In es, this message translates to:
  /// **'Destino requerido'**
  String get detailFormMovementToRequired;

  /// No description provided for @detailFormMovementDifferentLocations.
  ///
  /// In es, this message translates to:
  /// **'La ubicación de origen y destino no pueden ser iguales'**
  String get detailFormMovementDifferentLocations;

  /// No description provided for @detailFormMovementSaved.
  ///
  /// In es, this message translates to:
  /// **'Movimiento guardado'**
  String get detailFormMovementSaved;

  /// No description provided for @detailFormCostTitle.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get detailFormCostTitle;

  /// No description provided for @detailFormCostType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get detailFormCostType;

  /// No description provided for @detailFormCostAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get detailFormCostAmount;

  /// No description provided for @detailFormCostCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get detailFormCostCurrency;

  /// No description provided for @detailFormCostAmountRequired.
  ///
  /// In es, this message translates to:
  /// **'Monto requerido'**
  String get detailFormCostAmountRequired;

  /// No description provided for @detailFormCostSaved.
  ///
  /// In es, this message translates to:
  /// **'Costo guardado'**
  String get detailFormCostSaved;

  /// No description provided for @detailFormReproductionTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar evento reproductivo'**
  String get detailFormReproductionTitle;

  /// No description provided for @detailFormReproductionParicionTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de parición'**
  String get detailFormReproductionParicionTitle;

  /// No description provided for @detailFormReproductionServiceType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de servicio'**
  String get detailFormReproductionServiceType;

  /// No description provided for @detailFormReproductionServiceNatural.
  ///
  /// In es, this message translates to:
  /// **'Monta natural'**
  String get detailFormReproductionServiceNatural;

  /// No description provided for @detailFormReproductionServiceAi.
  ///
  /// In es, this message translates to:
  /// **'Inseminación AI'**
  String get detailFormReproductionServiceAi;

  /// No description provided for @detailFormReproductionServiceIvf.
  ///
  /// In es, this message translates to:
  /// **'FIV'**
  String get detailFormReproductionServiceIvf;

  /// No description provided for @detailFormReproductionExpectedCalving.
  ///
  /// In es, this message translates to:
  /// **'F. probable parto'**
  String get detailFormReproductionExpectedCalving;

  /// No description provided for @detailFormReproductionSire.
  ///
  /// In es, this message translates to:
  /// **'Toro / padre (opcional)'**
  String get detailFormReproductionSire;

  /// No description provided for @detailFormReproductionNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get detailFormReproductionNotes;

  /// No description provided for @detailFormReproductionExpectedAfterDate.
  ///
  /// In es, this message translates to:
  /// **'La fecha probable de parto no puede ser anterior a la fecha de servicio'**
  String get detailFormReproductionExpectedAfterDate;

  /// No description provided for @detailFormReproductionSaved.
  ///
  /// In es, this message translates to:
  /// **'Evento reproductivo guardado'**
  String get detailFormReproductionSaved;

  /// No description provided for @detailFormMilkingTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de ordeña'**
  String get detailFormMilkingTitle;

  /// No description provided for @detailFormMilkingIndividualMode.
  ///
  /// In es, this message translates to:
  /// **'Una por una'**
  String get detailFormMilkingIndividualMode;

  /// No description provided for @detailFormMilkingGroupMode.
  ///
  /// In es, this message translates to:
  /// **'Por lote'**
  String get detailFormMilkingGroupMode;

  /// No description provided for @detailFormMilkingShift.
  ///
  /// In es, this message translates to:
  /// **'Turno'**
  String get detailFormMilkingShift;

  /// No description provided for @detailFormMilkingRegisterCow.
  ///
  /// In es, this message translates to:
  /// **'Registrar vaca'**
  String get detailFormMilkingRegisterCow;

  /// No description provided for @detailFormMilkingSelectAnimal.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar vaca'**
  String get detailFormMilkingSelectAnimal;

  /// No description provided for @detailFormMilkingLitersLabel.
  ///
  /// In es, this message translates to:
  /// **'Litros de leche'**
  String get detailFormMilkingLitersLabel;

  /// No description provided for @detailFormMilkingLitersShort.
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get detailFormMilkingLitersShort;

  /// No description provided for @detailFormMilkingAddContinue.
  ///
  /// In es, this message translates to:
  /// **'Agregar y continuar'**
  String get detailFormMilkingAddContinue;

  /// No description provided for @detailFormMilkingGroupLabel.
  ///
  /// In es, this message translates to:
  /// **'Grupo o lote de vacas'**
  String get detailFormMilkingGroupLabel;

  /// No description provided for @detailFormMilkingExcludedAnimals.
  ///
  /// In es, this message translates to:
  /// **'{count} animales del lote no se muestran porque no son vacas activas.'**
  String detailFormMilkingExcludedAnimals(int count);

  /// No description provided for @detailFormMilkingSelectLotePrompt.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un lote para cargar sus vacas.'**
  String get detailFormMilkingSelectLotePrompt;

  /// No description provided for @detailFormMilkingEmptyLote.
  ///
  /// In es, this message translates to:
  /// **'Este lote no contiene vacas activas.'**
  String get detailFormMilkingEmptyLote;

  /// No description provided for @detailFormMilkingAddOutsideLote.
  ///
  /// In es, this message translates to:
  /// **'Agregar una vaca fuera del lote'**
  String get detailFormMilkingAddOutsideLote;

  /// No description provided for @detailFormMilkingRegisteredCows.
  ///
  /// In es, this message translates to:
  /// **'Vacas registradas'**
  String get detailFormMilkingRegisteredCows;

  /// No description provided for @detailFormMilkingRemoveEntryTitle.
  ///
  /// In es, this message translates to:
  /// **'Quitar registro'**
  String get detailFormMilkingRemoveEntryTitle;

  /// No description provided for @detailFormMilkingRemoveEntryMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar esta vaca de la ordeña?'**
  String get detailFormMilkingRemoveEntryMessage;

  /// No description provided for @detailFormMilkingSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get detailFormMilkingSaving;

  /// No description provided for @detailFormMilkingFinalize.
  ///
  /// In es, this message translates to:
  /// **'Finalizar ordeña'**
  String get detailFormMilkingFinalize;

  /// No description provided for @detailFormMilkingSaved.
  ///
  /// In es, this message translates to:
  /// **'Ordeña registrada correctamente'**
  String get detailFormMilkingSaved;

  /// No description provided for @detailFormMilkingReviewAgain.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get detailFormMilkingReviewAgain;

  /// No description provided for @detailFormMilkingUnusualAmountTitle.
  ///
  /// In es, this message translates to:
  /// **'Cantidad inusual'**
  String get detailFormMilkingUnusualAmountTitle;

  /// No description provided for @detailFormMilkingUnusualAmountMessage.
  ///
  /// In es, this message translates to:
  /// **'Se registrarán {liters} L para una vaca. ¿La cantidad es correcta?'**
  String detailFormMilkingUnusualAmountMessage(Object liters);

  /// No description provided for @detailFormMilkingInvalidVolume.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una cantidad válida de litros'**
  String get detailFormMilkingInvalidVolume;

  /// No description provided for @detailFormMilkingSelectAnimalFirst.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una vaca primero'**
  String get detailFormMilkingSelectAnimalFirst;

  /// No description provided for @detailFormMilkingCheckAnimalVolume.
  ///
  /// In es, this message translates to:
  /// **'Revisa los litros de {animal}'**
  String detailFormMilkingCheckAnimalVolume(Object animal);

  /// No description provided for @detailFormMilkingReviewBeforeContinue.
  ///
  /// In es, this message translates to:
  /// **'Revisa la cantidad antes de continuar'**
  String get detailFormMilkingReviewBeforeContinue;

  /// No description provided for @detailFormMilkingFutureDateTime.
  ///
  /// In es, this message translates to:
  /// **'La fecha y hora no pueden ser futuras'**
  String get detailFormMilkingFutureDateTime;

  /// No description provided for @detailFormMilkingSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por arete, nombre o ID'**
  String get detailFormMilkingSearchHint;

  /// No description provided for @detailFormMilkingNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron vacas'**
  String get detailFormMilkingNoResults;

  /// No description provided for @detailFormMilkingCowCount.
  ///
  /// In es, this message translates to:
  /// **'{count} vacas registradas'**
  String detailFormMilkingCowCount(int count);

  /// No description provided for @registroReproSubtitleFemale.
  ///
  /// In es, this message translates to:
  /// **'Hembra: formulario reproductivo completo.'**
  String get registroReproSubtitleFemale;

  /// No description provided for @registroReproSubtitleMale.
  ///
  /// In es, this message translates to:
  /// **'Macho: ajustes reproductivos básicos.'**
  String get registroReproSubtitleMale;

  /// No description provided for @registroReproAgeWarning.
  ///
  /// In es, this message translates to:
  /// **'Aviso: este animal tiene {ageMonths} meses. Se recomienda esperar al menos {minMonths} meses para servicio, pero este formulario no bloquea el registro.'**
  String registroReproAgeWarning(int ageMonths, int minMonths);

  /// No description provided for @registroReproSireMale.
  ///
  /// In es, this message translates to:
  /// **'Identificación del macho (opcional)'**
  String get registroReproSireMale;

  /// No description provided for @registroReproPartialError.
  ///
  /// In es, this message translates to:
  /// **'Registro sanitario guardado, pero falló el evento reproductivo: {error}'**
  String registroReproPartialError(Object error);

  /// No description provided for @animalFormLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el formulario de animal'**
  String get animalFormLoadError;

  /// No description provided for @animalFormCategoryAdjusted.
  ///
  /// In es, this message translates to:
  /// **'Categoría ajustada a Otro para coincidir con la especie'**
  String get animalFormCategoryAdjusted;

  /// No description provided for @animalFormSpeciesAdjusted.
  ///
  /// In es, this message translates to:
  /// **'Especie ajustada a Bovino para esa categoría'**
  String get animalFormSpeciesAdjusted;

  /// No description provided for @animalFormNoSelection.
  ///
  /// In es, this message translates to:
  /// **'Sin selección'**
  String get animalFormNoSelection;

  /// No description provided for @animalFormNoTagTitle.
  ///
  /// In es, this message translates to:
  /// **'Animal sin arete'**
  String get animalFormNoTagTitle;

  /// No description provided for @animalFormNoTagMessage.
  ///
  /// In es, this message translates to:
  /// **'Este animal no tiene arete. Se recomienda etiquetarlo para su seguimiento. ¿Deseas guardar de todos modos?'**
  String get animalFormNoTagMessage;

  /// No description provided for @animalFormDuplicateEarTag.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un animal con ese arete'**
  String get animalFormDuplicateEarTag;

  /// No description provided for @animalFormUnsupportedAction.
  ///
  /// In es, this message translates to:
  /// **'Acción no soportada desde este formulario'**
  String get animalFormUnsupportedAction;

  /// No description provided for @animalFormRecordSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el registro: {error}'**
  String animalFormRecordSaveError(Object error);

  /// No description provided for @animalFormSaveFirstForRecords.
  ///
  /// In es, this message translates to:
  /// **'Guarda el animal primero para agregar registros'**
  String get animalFormSaveFirstForRecords;

  /// No description provided for @animalFormInvalidPurchasePrice.
  ///
  /// In es, this message translates to:
  /// **'El precio de compra debe ser un número válido'**
  String get animalFormInvalidPurchasePrice;

  /// No description provided for @animalFormNoAutoMotherFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró madre automática; puedes guardar o seleccionar una madre manualmente.'**
  String get animalFormNoAutoMotherFound;

  /// No description provided for @animalFormEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar animal'**
  String get animalFormEditTitle;

  /// No description provided for @animalFormCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar animal'**
  String get animalFormCreateTitle;

  /// No description provided for @animalFormNameOrVisualId.
  ///
  /// In es, this message translates to:
  /// **'Nombre o ID visual'**
  String get animalFormNameOrVisualId;

  /// No description provided for @animalFormBreedOptional.
  ///
  /// In es, this message translates to:
  /// **'Raza (opcional)'**
  String get animalFormBreedOptional;

  /// No description provided for @animalFormCrossBreedOptional.
  ///
  /// In es, this message translates to:
  /// **'Raza 2 / Cruce (opcional)'**
  String get animalFormCrossBreedOptional;

  /// No description provided for @animalFormAgeMonthsOptional.
  ///
  /// In es, this message translates to:
  /// **'Edad aprox. (meses)'**
  String get animalFormAgeMonthsOptional;

  /// No description provided for @animalFormUnknownBreed.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get animalFormUnknownBreed;

  /// No description provided for @animalFormStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get animalFormStatus;

  /// No description provided for @animalFormSectionOrigin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get animalFormSectionOrigin;

  /// No description provided for @animalFormMotherOptional.
  ///
  /// In es, this message translates to:
  /// **'Madre (opcional)'**
  String get animalFormMotherOptional;

  /// No description provided for @animalFormFatherOptional.
  ///
  /// In es, this message translates to:
  /// **'Padre (opcional)'**
  String get animalFormFatherOptional;

  /// No description provided for @animalFormSelectMother.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar madre'**
  String get animalFormSelectMother;

  /// No description provided for @animalFormSelectFather.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar padre'**
  String get animalFormSelectFather;

  /// No description provided for @animalFormNoLocation.
  ///
  /// In es, this message translates to:
  /// **'Sin ubicación'**
  String get animalFormNoLocation;

  /// No description provided for @animalFormNoBatch.
  ///
  /// In es, this message translates to:
  /// **'Sin lote'**
  String get animalFormNoBatch;

  /// No description provided for @animalFormSectionWeightHealth.
  ///
  /// In es, this message translates to:
  /// **'Peso y salud'**
  String get animalFormSectionWeightHealth;

  /// No description provided for @animalFormWeightOptional.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg) opcional'**
  String get animalFormWeightOptional;

  /// No description provided for @animalFormSectionNotesPhoto.
  ///
  /// In es, this message translates to:
  /// **'Notas y foto'**
  String get animalFormSectionNotesPhoto;

  /// No description provided for @animalFormOwnerOptional.
  ///
  /// In es, this message translates to:
  /// **'Propietario (opcional)'**
  String get animalFormOwnerOptional;

  /// No description provided for @animalFormPurchasePriceOptional.
  ///
  /// In es, this message translates to:
  /// **'Precio de compra (opcional)'**
  String get animalFormPurchasePriceOptional;

  /// No description provided for @animalFormRecordsAvailableAfterSave.
  ///
  /// In es, this message translates to:
  /// **'Los accesos de registros estarán disponibles al guardar el animal.'**
  String get animalFormRecordsAvailableAfterSave;

  /// No description provided for @animalFormRegisterAsCalf.
  ///
  /// In es, this message translates to:
  /// **'Registrar como cría (agregar madre automáticamente)'**
  String get animalFormRegisterAsCalf;

  /// No description provided for @animalFormSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get animalFormSaving;

  /// No description provided for @animalFormSaveAnimal.
  ///
  /// In es, this message translates to:
  /// **'Guardar animal'**
  String get animalFormSaveAnimal;

  /// No description provided for @detailQuickActionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar registro'**
  String get detailQuickActionsTitle;

  /// No description provided for @detailNoRecordsYet.
  ///
  /// In es, this message translates to:
  /// **'Sin registros aún'**
  String get detailNoRecordsYet;

  /// No description provided for @detailNoRecordsHint.
  ///
  /// In es, this message translates to:
  /// **'Usa el botón + para agregar el primer registro de este animal.'**
  String get detailNoRecordsHint;

  /// No description provided for @recordEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Corregir registro'**
  String get recordEditTitle;

  /// No description provided for @recordEditSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro corregido'**
  String get recordEditSaved;

  /// No description provided for @recordEditNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el registro que querías corregir.'**
  String get recordEditNotFound;

  /// No description provided for @recordDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar registro'**
  String get recordDeleteTitle;

  /// No description provided for @recordDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este registro? Podrás deshacerlo enseguida.'**
  String get recordDeleteConfirm;

  /// No description provided for @recordDeleted.
  ///
  /// In es, this message translates to:
  /// **'Registro eliminado'**
  String get recordDeleted;

  /// No description provided for @recordDeletedSyncWarning.
  ///
  /// In es, this message translates to:
  /// **'Registro eliminado; no se pudo sincronizar Agenda'**
  String get recordDeletedSyncWarning;

  /// No description provided for @recordDeleteUndone.
  ///
  /// In es, this message translates to:
  /// **'Registro restaurado'**
  String get recordDeleteUndone;

  /// No description provided for @recordRestoredSyncWarning.
  ///
  /// In es, this message translates to:
  /// **'Registro restaurado; no se pudo sincronizar Agenda'**
  String get recordRestoredSyncWarning;

  /// No description provided for @actionUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get actionUndo;

  /// No description provided for @actionEdit.
  ///
  /// In es, this message translates to:
  /// **'Corregir'**
  String get actionEdit;

  /// No description provided for @mediaTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get mediaTakePhoto;

  /// No description provided for @mediaChooseGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get mediaChooseGallery;

  /// No description provided for @mediaSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la imagen'**
  String get mediaSaveError;

  /// No description provided for @animalPhotoTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotografía del animal'**
  String get animalPhotoTitle;

  /// No description provided for @animalPhotoAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get animalPhotoAdd;

  /// No description provided for @animalPhotoReplace.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar foto'**
  String get animalPhotoReplace;

  /// No description provided for @animalPhotoRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get animalPhotoRemove;

  /// No description provided for @loteWeightTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar pesaje'**
  String get loteWeightTitle;

  /// No description provided for @loteWeightCaptured.
  ///
  /// In es, this message translates to:
  /// **'{captured} de {total} capturados'**
  String loteWeightCaptured(int captured, int total);

  /// No description provided for @loteWeightDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha del pesaje'**
  String get loteWeightDate;

  /// No description provided for @loteWeightKg.
  ///
  /// In es, this message translates to:
  /// **'Peso kg'**
  String get loteWeightKg;

  /// No description provided for @loteWeightPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get loteWeightPrevious;

  /// No description provided for @loteWeightGain.
  ///
  /// In es, this message translates to:
  /// **'Diferencia'**
  String get loteWeightGain;

  /// No description provided for @loteWeightAdg.
  ///
  /// In es, this message translates to:
  /// **'ADG'**
  String get loteWeightAdg;

  /// No description provided for @loteWeightSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar pesaje del lote'**
  String get loteWeightSave;

  /// No description provided for @loteWeightSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get loteWeightSaving;

  /// No description provided for @loteWeightNoActiveAnimals.
  ///
  /// In es, this message translates to:
  /// **'Este lote no tiene animales activos.'**
  String get loteWeightNoActiveAnimals;

  /// No description provided for @loteWeightLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el lote.'**
  String get loteWeightLoadError;

  /// No description provided for @loteWeightAtLeastOne.
  ///
  /// In es, this message translates to:
  /// **'Captura al menos un peso.'**
  String get loteWeightAtLeastOne;

  /// No description provided for @loteWeightInvalid.
  ///
  /// In es, this message translates to:
  /// **'Peso inválido'**
  String get loteWeightInvalid;

  /// No description provided for @lotePerformanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento'**
  String get lotePerformanceTitle;

  /// No description provided for @lotePerformanceEmpty.
  ///
  /// In es, this message translates to:
  /// **'Registra un pesaje para ver el rendimiento del lote.'**
  String get lotePerformanceEmpty;

  /// No description provided for @lotePerformanceLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el rendimiento.'**
  String get lotePerformanceLoadError;

  /// No description provided for @lotePerformanceTotal.
  ///
  /// In es, this message translates to:
  /// **'Peso total'**
  String get lotePerformanceTotal;

  /// No description provided for @lotePerformanceAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get lotePerformanceAverage;

  /// No description provided for @lotePerformanceAdgAverage.
  ///
  /// In es, this message translates to:
  /// **'ADG promedio'**
  String get lotePerformanceAdgAverage;

  /// No description provided for @lotePerformanceGain.
  ///
  /// In es, this message translates to:
  /// **'Ganancia lote'**
  String get lotePerformanceGain;

  /// No description provided for @lotePerformancePrevious.
  ///
  /// In es, this message translates to:
  /// **'Vs. pesaje anterior'**
  String get lotePerformancePrevious;

  /// No description provided for @lotePerformanceGood.
  ///
  /// In es, this message translates to:
  /// **'Buen rendimiento'**
  String get lotePerformanceGood;

  /// No description provided for @lotePerformanceBelow.
  ///
  /// In es, this message translates to:
  /// **'Debajo promedio'**
  String get lotePerformanceBelow;

  /// No description provided for @lotePerformanceNoGain.
  ///
  /// In es, this message translates to:
  /// **'Sin ganancia'**
  String get lotePerformanceNoGain;

  /// No description provided for @lotePerformanceNoReference.
  ///
  /// In es, this message translates to:
  /// **'Sin referencia'**
  String get lotePerformanceNoReference;

  /// No description provided for @lotePerformanceUnmeasured.
  ///
  /// In es, this message translates to:
  /// **'{count} animal(es) aún sin pesaje en esta sesión.'**
  String lotePerformanceUnmeasured(int count);

  /// No description provided for @lotePerformanceSessions.
  ///
  /// In es, this message translates to:
  /// **'Historial de pesajes'**
  String get lotePerformanceSessions;

  /// No description provided for @lotePerformanceEconomics.
  ///
  /// In es, this message translates to:
  /// **'Economía estimada'**
  String get lotePerformanceEconomics;

  /// No description provided for @lotePerformanceFeedPerDay.
  ///
  /// In es, this message translates to:
  /// **'Alimento/día'**
  String get lotePerformanceFeedPerDay;

  /// No description provided for @lotePerformanceCostPerKg.
  ///
  /// In es, this message translates to:
  /// **'Costo/kg ganado'**
  String get lotePerformanceCostPerKg;

  /// No description provided for @lotePerformanceMargin.
  ///
  /// In es, this message translates to:
  /// **'Margen alimentación'**
  String get lotePerformanceMargin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
