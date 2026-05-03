// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LibretApp - Control Ganadero';

  @override
  String get navDirectory => 'Directory';

  @override
  String get navHome => 'Home';

  @override
  String get navAnimals => 'Animals';

  @override
  String get navEvents => 'Events';

  @override
  String get navLocations => 'Locations';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAdd => 'Registrer:';

  @override
  String get animalsTitle => 'Animals';

  @override
  String get animalsEmptyTitle => 'No animals found';

  @override
  String get animalsEmptySubtitle => 'Adjust filters or search';

  @override
  String get animalsSearchHint => 'Search by ear tag, name or breed';

  @override
  String get animalsAdvancedSearch => 'Advanced search';

  @override
  String get animalsRecentSearches => 'Recent searches';

  @override
  String get animalsRecentActivity => 'Recent activity';

  @override
  String get animalsClearHistory => 'Clear history';

  @override
  String get animalsFilters => 'Filters';

  @override
  String get animalsNoResults => 'No results';

  @override
  String get animalsStageFilterLabel => 'Stage filters';

  @override
  String get animalsOnlyAttention => 'Only attention';

  @override
  String animalsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animals',
      one: '$count animal',
    );
    return '$_temp0';
  }

  @override
  String get animalsSelectionHint => 'Long press to select';

  @override
  String animalsSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String animalsSelectVisible(Object selected, Object total) {
    return 'Select visible ($selected/$total)';
  }

  @override
  String get animalsSelectVisibleSimple => 'Select visible';

  @override
  String get animalsDeselectVisible => 'Deselect visible';

  @override
  String get animalsSelectionCancel => 'Cancel';

  @override
  String animalsSelectionHiddenCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected items are hidden by filters',
      one: '$count selected item is hidden by filters',
    );
    return '$_temp0';
  }

  @override
  String get animalsSelectionAllHiddenWarning =>
      'All selected items are hidden by active filters.';

  @override
  String animalsBulkMaintenanceAction(Object count) {
    return 'Add maintenance ($count)';
  }

  @override
  String animalsBulkMaintenanceError(Object error) {
    return 'Could not save: $error';
  }

  @override
  String get animalsBulkMaintenanceConfirmTitle => 'Confirm maintenance';

  @override
  String animalsBulkMaintenanceConfirmBody(Object count) {
    return 'The same maintenance will be applied to $count animals.';
  }

  @override
  String get animalsBulkMaintenanceConfirmAction => 'Continue';

  @override
  String stageFilterCalf(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Calves',
      one: 'Calf',
    );
    return '$_temp0';
  }

  @override
  String stageFilterHeifer(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Heifers',
      one: 'Heifer',
    );
    return '$_temp0';
  }

  @override
  String stageFilterYoungBull(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Young bulls',
      one: 'Young bull',
    );
    return '$_temp0';
  }

  @override
  String stageFilterSteer(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Steers',
      one: 'Steer',
    );
    return '$_temp0';
  }

  @override
  String stageFilterCow(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cows',
      one: 'Cow',
    );
    return '$_temp0';
  }

  @override
  String stageFilterBull(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bulls',
      one: 'Bull',
    );
    return '$_temp0';
  }

  @override
  String stageFilterColt(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Colts / Fillies',
      one: 'Colt / Filly',
    );
    return '$_temp0';
  }

  @override
  String stageFilterHorse(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Horses',
      one: 'Horse',
    );
    return '$_temp0';
  }

  @override
  String stageFilterMare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mares',
      one: 'Mare',
    );
    return '$_temp0';
  }

  @override
  String stageFilterDonkey(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Donkeys',
      one: 'Donkey',
    );
    return '$_temp0';
  }

  @override
  String stageFilterMule(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mules',
      one: 'Mule',
    );
    return '$_temp0';
  }

  @override
  String get animalRequiresAttention => 'Requires attention';

  @override
  String get animalUnderObservation => 'Under observation';

  @override
  String get animalVaccinated => 'Vaccinated';

  @override
  String animalRisk(Object level) {
    return 'Risk $level';
  }

  @override
  String get animalHealth => 'Health';

  @override
  String get animalAge => 'Age';

  @override
  String get animalBreed => 'Breed';

  @override
  String get animalDetailTitle => 'Animal detail';

  @override
  String get tabInformation => 'Information';

  @override
  String get tabHistory => 'History';

  @override
  String get sectionIdentification => 'Identification';

  @override
  String get sectionProductiveProfile => 'Productive profile';

  @override
  String get sectionHealth => 'Health';

  @override
  String get sectionLocation => 'Location & movement';

  @override
  String get sectionReproduction => 'Reproduction';

  @override
  String get detailNotFound => 'No animal information found.';

  @override
  String get detailReload => 'Reload';

  @override
  String get detailRetry => 'Retry';

  @override
  String get detailCreated => 'Created';

  @override
  String get detailUpdated => 'Last update';

  @override
  String get detailLastMovement => 'Last movement';

  @override
  String get detailHealth => 'Health status';

  @override
  String get detailRisk => 'Risk';

  @override
  String get detailVaccinated => 'Vaccinated';

  @override
  String get detailSynced => 'Sync status';

  @override
  String detailSyncedValue(String isSynced) {
    String _temp0 = intl.Intl.selectLogic(isSynced, {
      'true': 'Synced',
      'other': 'Pending',
    });
    return '$_temp0';
  }

  @override
  String get booleanYes => 'Yes';

  @override
  String get booleanNo => 'No';

  @override
  String get locationChangePlaceholder => 'Change location - PHASE 3';

  @override
  String get labelEarTag => 'Ear tag';

  @override
  String get labelVisualId => 'Visual ID';

  @override
  String get labelBrand => 'Brand';

  @override
  String get labelRfid => 'RFID';

  @override
  String get labelBatch => 'Lot';

  @override
  String get labelSpecies => 'Species';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelLifeStage => 'Life stage';

  @override
  String get labelSex => 'Sex';

  @override
  String get labelAge => 'Age';

  @override
  String get labelBreed => 'Breed';

  @override
  String get labelPurpose => 'Purpose';

  @override
  String get labelFeedType => 'Feeding';

  @override
  String get labelDailyGain => 'Estimated daily gain';

  @override
  String get labelHealthStatus => 'Health status';

  @override
  String get labelBodyCondition => 'Body condition';

  @override
  String get labelRisk => 'Risk';

  @override
  String get labelVaccinated => 'Vaccinated';

  @override
  String get labelDewormed => 'Dewormed';

  @override
  String get labelVitamins => 'Vitamins';

  @override
  String get labelChronicCondition => 'Chronic condition';

  @override
  String get labelChronicNotes => 'Chronic notes';

  @override
  String get labelPaddock => 'Paddock';

  @override
  String get labelLastMovement => 'Last movement';

  @override
  String get labelObservation => 'Observation';

  @override
  String get labelReproductiveStatus => 'Reproductive status';

  @override
  String get labelFirstService => 'First service';

  @override
  String get labelLastService => 'Last service';

  @override
  String get labelExpectedCalving => 'Expected calving date';

  @override
  String get labelSynced => 'Sync status';

  @override
  String get valueYes => 'Yes';

  @override
  String get valueNo => 'No';

  @override
  String get valueNotAssigned => 'Not assigned';

  @override
  String get valueNoData => 'No data';

  @override
  String get tabRecords => 'Records';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionSave => 'Save';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldNotesOptional => 'Notes (optional)';

  @override
  String get detailActionWeight => 'Weight';

  @override
  String get detailActionReproduction => 'Reproduction';

  @override
  String get detailActionProduction => 'Production';

  @override
  String get detailActionHealth => 'Health';

  @override
  String get detailActionCommercial => 'Commercial';

  @override
  String get detailActionMovement => 'Movement';

  @override
  String get detailActionCost => 'Cost';

  @override
  String get detailRecordsWeights => 'Weight';

  @override
  String get detailRecordsProduction => 'Production';

  @override
  String get detailRecordsHealth => 'Health';

  @override
  String get detailRecordsReproduction => 'Reproduction';

  @override
  String get detailRecordsCommercial => 'Commercial';

  @override
  String get detailRecordsMovements => 'Movements';

  @override
  String get detailRecordsCosts => 'Costs';

  @override
  String get detailRecordsValue => 'Value';

  @override
  String get detailRecordsScore => 'Score';

  @override
  String get detailRecordsDose => 'Dose';

  @override
  String get detailRecordsCause => 'Cause';

  @override
  String get detailRecordsAmount => 'Amount';

  @override
  String get detailRecordsFrom => 'From';

  @override
  String get detailRecordsTo => 'To';

  @override
  String get detailFormWeightTitle => 'Record weight';

  @override
  String get detailFormWeightValue => 'Weight (kg)';

  @override
  String get detailFormWeightMethod => 'Method';

  @override
  String get detailFormWeightMethodScale => 'Scale';

  @override
  String get detailFormWeightMethodEstimated => 'Estimated';

  @override
  String get detailFormAnimalRequired => 'Select an animal first';

  @override
  String get detailFormNumberInvalid => 'Enter a valid number';

  @override
  String get detailFormAmountPositive => 'The value must be greater than zero';

  @override
  String get detailFormWeightErrorInvalid => 'Enter a valid weight';

  @override
  String get detailFormWeightSaved => 'Weight saved';

  @override
  String get detailFormProductionTitle => 'Production record';

  @override
  String get detailFormProductionType => 'Type';

  @override
  String get detailFormProductionValue => 'Value (optional)';

  @override
  String get detailFormProductionUnit => 'Unit';

  @override
  String get detailFormProductionScore => 'Score/BCS';

  @override
  String get detailFormProductionValueRequired =>
      'Enter a value for this record type';

  @override
  String get detailFormProductionScoreRequired =>
      'Enter a score for body condition';

  @override
  String get detailFormProductionScoreInvalid => 'Enter a valid score';

  @override
  String get detailFormProductionScoreRange =>
      'The score must be between 0 and 9';

  @override
  String get detailFormProductionDataRequired =>
      'Add at least one data point to save the record';

  @override
  String get detailFormProductionSaved => 'Production record saved';

  @override
  String get detailFormHealthTitle => 'Health record';

  @override
  String get detailFormHealthType => 'Type';

  @override
  String get detailFormHealthProduct => 'Product/procedure';

  @override
  String get detailFormHealthDose => 'Dose';

  @override
  String get detailFormHealthAppliedBy => 'Applied by';

  @override
  String get detailFormHealthNext => 'Next (optional)';

  @override
  String get detailFormHealthCause => 'Cause (disease/death)';

  @override
  String get detailFormHealthProductRequired => 'Product is required';

  @override
  String get detailFormHealthNextAfterDate =>
      'The next date cannot be before the record date';

  @override
  String get detailFormHealthSaved => 'Health record saved';

  @override
  String get detailFormCommercialTitle => 'Commercial record';

  @override
  String get detailFormCommercialType => 'Type';

  @override
  String get detailFormCommercialAmount => 'Amount';

  @override
  String get detailFormCommercialCurrency => 'Currency';

  @override
  String get detailFormCommercialCounterparty => 'Counterparty';

  @override
  String get detailFormCommercialAmountRequired =>
      'Amount is required for this record type';

  @override
  String get detailFormCommercialSaved => 'Commercial record saved';

  @override
  String get detailFormMovementTitle => 'Movement';

  @override
  String get detailFormMovementReason => 'Reason';

  @override
  String get detailFormMovementFrom => 'From (optional)';

  @override
  String get detailFormMovementTo => 'To';

  @override
  String get detailFormMovementMovedBy => 'Moved by';

  @override
  String get detailFormMovementToRequired => 'Destination is required';

  @override
  String get detailFormMovementDifferentLocations =>
      'From and to locations cannot be the same';

  @override
  String get detailFormMovementSaved => 'Movement saved';

  @override
  String get detailFormCostTitle => 'Cost';

  @override
  String get detailFormCostType => 'Type';

  @override
  String get detailFormCostAmount => 'Amount';

  @override
  String get detailFormCostCurrency => 'Currency';

  @override
  String get detailFormCostAmountRequired => 'Amount is required';

  @override
  String get detailFormCostSaved => 'Cost saved';

  @override
  String get detailFormReproductionTitle => 'Record reproduction event';

  @override
  String get detailFormReproductionServiceType => 'Service type';

  @override
  String get detailFormReproductionServiceNatural => 'Natural service';

  @override
  String get detailFormReproductionServiceAi => 'AI insemination';

  @override
  String get detailFormReproductionServiceIvf => 'IVF';

  @override
  String get detailFormReproductionExpectedCalving => 'Expected calving date';

  @override
  String get detailFormReproductionSire => 'Sire (optional)';

  @override
  String get detailFormReproductionNotes => 'Notes (optional)';

  @override
  String get detailFormReproductionExpectedAfterDate =>
      'Expected calving date cannot be before service date';

  @override
  String get detailFormReproductionSaved => 'Reproduction event saved';

  @override
  String get animalFormLoadError => 'Could not load the animal form';

  @override
  String get animalFormCategoryAdjusted =>
      'Category adjusted to Other to match species';

  @override
  String get animalFormSpeciesAdjusted =>
      'Species adjusted to Cattle for that category';

  @override
  String get animalFormNoSelection => 'No selection';

  @override
  String get animalFormNoTagTitle => 'Animal without ear tag';

  @override
  String get animalFormNoTagMessage =>
      'This animal has no ear tag. Tagging is recommended for tracking. Do you want to save anyway?';

  @override
  String get animalFormDuplicateEarTag =>
      'An animal with this ear tag already exists';

  @override
  String get animalFormUnsupportedAction => 'Unsupported action from this form';

  @override
  String animalFormRecordSaveError(Object error) {
    return 'Could not save the record: $error';
  }

  @override
  String get animalFormSaveFirstForRecords =>
      'Save the animal first to add records';

  @override
  String get animalFormInvalidPurchasePrice =>
      'Purchase price must be a valid number';

  @override
  String get animalFormNoAutoMotherFound =>
      'No automatic mother was found; you can save or select one manually.';

  @override
  String get animalFormEditTitle => 'Edit animal';

  @override
  String get animalFormCreateTitle => 'Add animal';

  @override
  String get animalFormNameOrVisualId => 'Name or visual ID';

  @override
  String get animalFormBreedOptional => 'Breed (optional)';

  @override
  String get animalFormCrossBreedOptional => 'Cross breed (optional)';

  @override
  String get animalFormAgeMonthsOptional => 'Approx. age (months)';

  @override
  String get animalFormUnknownBreed => 'Unknown';

  @override
  String get animalFormStatus => 'Status';

  @override
  String get animalFormSectionOrigin => 'Origin';

  @override
  String get animalFormMotherOptional => 'Mother (optional)';

  @override
  String get animalFormFatherOptional => 'Father (optional)';

  @override
  String get animalFormSelectMother => 'Select mother';

  @override
  String get animalFormSelectFather => 'Select father';

  @override
  String get animalFormNoLocation => 'No location';

  @override
  String get animalFormNoBatch => 'No lot';

  @override
  String get animalFormSectionWeightHealth => 'Weight and health';

  @override
  String get animalFormWeightOptional => 'Weight (kg) optional';

  @override
  String get animalFormSectionNotesPhoto => 'Notes and photo';

  @override
  String get animalFormOwnerOptional => 'Owner (optional)';

  @override
  String get animalFormPurchasePriceOptional => 'Purchase price (optional)';

  @override
  String get animalFormRecordsAvailableAfterSave =>
      'Record shortcuts will be available after saving the animal.';

  @override
  String get animalFormRegisterAsCalf =>
      'Register as calf (auto-assign mother)';

  @override
  String get animalFormSaving => 'Saving...';

  @override
  String get animalFormSaveAnimal => 'Save animal';

  @override
  String get detailQuickActionsTitle => 'Add record';

  @override
  String get detailNoRecordsYet => 'No records yet';

  @override
  String get detailNoRecordsHint =>
      'Use the + button to add the first record for this animal.';
}
