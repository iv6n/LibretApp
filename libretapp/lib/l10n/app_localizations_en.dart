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
  String get animalsSearchHint => 'Ear tag, name, breed, lot...';

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
  String get stageFilterCalf => 'Calf';

  @override
  String get stageFilterHeifer => 'Heifer / Young bull';

  @override
  String get stageFilterSteer => 'Steer';

  @override
  String get stageFilterCow => 'Cow';

  @override
  String get stageFilterBull => 'Bull';

  @override
  String get stageFilterColt => 'Colt / Filly';

  @override
  String get stageFilterHorse => 'Horse / Mare';

  @override
  String get stageFilterDonkey => 'Donkey';

  @override
  String get stageFilterMule => 'Mule';

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
  String get detailFormReproductionSaved => 'Reproduction event saved';
}
