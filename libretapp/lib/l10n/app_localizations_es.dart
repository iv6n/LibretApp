// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LibretApp - Control Ganadero';

  @override
  String get navHome => 'Inicio';

  @override
  String get navAnimals => 'Animales';

  @override
  String get navEvents => 'Eventos';

  @override
  String get navLocations => 'Ubicaciones';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navAdd => 'Registrar:';

  @override
  String get animalsTitle => 'Animales';

  @override
  String get animalsEmptyTitle => 'No se encontraron animales';

  @override
  String get animalsEmptySubtitle => 'Ajusta los filtros o la búsqueda';

  @override
  String get animalsSearchHint => 'Arete, nombre, raza, lote...';

  @override
  String get animalsStageFilterLabel => 'Filtros por etapa';

  @override
  String get animalsOnlyAttention => 'Solo atención';

  @override
  String animalsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animales',
      one: '$count animal',
    );
    return '$_temp0';
  }

  @override
  String get stageFilterCalf => 'Becerro/Becerra';

  @override
  String get stageFilterHeifer => 'Vaquilla/Torete';

  @override
  String get stageFilterSteer => 'Novillo';

  @override
  String get stageFilterCow => 'Vaca';

  @override
  String get stageFilterBull => 'Toro';

  @override
  String get stageFilterColt => 'Potro/Potranca';

  @override
  String get stageFilterHorse => 'Caballo/Yegua';

  @override
  String get stageFilterDonkey => 'Burro/Burra';

  @override
  String get stageFilterMule => 'Mula';

  @override
  String get animalRequiresAttention => 'Requiere atención';

  @override
  String get animalUnderObservation => 'En observación';

  @override
  String get animalVaccinated => 'Vacunado';

  @override
  String animalRisk(Object level) {
    return 'Riesgo $level';
  }

  @override
  String get animalHealth => 'Salud';

  @override
  String get animalAge => 'Edad';

  @override
  String get animalBreed => 'Raza';

  @override
  String get animalDetailTitle => 'Detalle del animal';

  @override
  String get tabInformation => 'Información';

  @override
  String get tabHistory => 'Historial';

  @override
  String get sectionIdentification => 'Identificación';

  @override
  String get sectionProductiveProfile => 'Perfil productivo';

  @override
  String get sectionHealth => 'Sanidad';

  @override
  String get sectionLocation => 'Ubicación y movimiento';

  @override
  String get sectionReproduction => 'Reproducción';

  @override
  String get detailNotFound => 'No se encontró información del animal.';

  @override
  String get detailReload => 'Recargar';

  @override
  String get detailRetry => 'Reintentar';

  @override
  String get detailCreated => 'Creado';

  @override
  String get detailUpdated => 'Última actualización';

  @override
  String get detailLastMovement => 'Último movimiento';

  @override
  String get detailHealth => 'Estado de salud';

  @override
  String get detailRisk => 'Riesgo';

  @override
  String get detailVaccinated => 'Vacunado';

  @override
  String get detailSynced => 'Sincronización';

  @override
  String detailSyncedValue(String isSynced) {
    String _temp0 = intl.Intl.selectLogic(isSynced, {
      'true': 'Sincronizado',
      'other': 'Pendiente',
    });
    return '$_temp0';
  }

  @override
  String get booleanYes => 'Sí';

  @override
  String get booleanNo => 'No';

  @override
  String get locationChangePlaceholder => 'Cambiar ubicación - FASE 3';

  @override
  String get labelEarTag => 'Arete';

  @override
  String get labelVisualId => 'ID visual';

  @override
  String get labelBrand => 'Marca';

  @override
  String get labelRfid => 'RFID';

  @override
  String get labelBatch => 'Lote';

  @override
  String get labelSpecies => 'Especie';

  @override
  String get labelCategory => 'Categoría';

  @override
  String get labelLifeStage => 'Etapa';

  @override
  String get labelSex => 'Sexo';

  @override
  String get labelAge => 'Edad';

  @override
  String get labelBreed => 'Raza';

  @override
  String get labelPurpose => 'Propósito';

  @override
  String get labelFeedType => 'Alimentación';

  @override
  String get labelDailyGain => 'Ganancia diaria estimada';

  @override
  String get labelHealthStatus => 'Estado de salud';

  @override
  String get labelBodyCondition => 'Condición corporal';

  @override
  String get labelRisk => 'Riesgo';

  @override
  String get labelVaccinated => 'Vacunado';

  @override
  String get labelDewormed => 'Desparasitado';

  @override
  String get labelVitamins => 'Vitaminas';

  @override
  String get labelChronicCondition => 'Condición crónica';

  @override
  String get labelChronicNotes => 'Notas crónicas';

  @override
  String get labelPaddock => 'Padrón / Potrero';

  @override
  String get labelLastMovement => 'Último movimiento';

  @override
  String get labelObservation => 'Observación';

  @override
  String get labelReproductiveStatus => 'Estado reproductivo';

  @override
  String get labelFirstService => '1er servicio';

  @override
  String get labelLastService => 'Último servicio';

  @override
  String get labelExpectedCalving => 'Fecha probable de parto';

  @override
  String get labelSynced => 'Sincronización';

  @override
  String get valueYes => 'Sí';

  @override
  String get valueNo => 'No';

  @override
  String get valueNotAssigned => 'Sin asignar';

  @override
  String get valueNoData => 'Sin dato';

  @override
  String get tabRecords => 'Registros';

  @override
  String get actionSave => 'Guardar';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldNotesOptional => 'Notas (opcional)';

  @override
  String get detailActionWeight => 'Peso';

  @override
  String get detailActionReproduction => 'Reproducción';

  @override
  String get detailActionProduction => 'Productivo';

  @override
  String get detailActionHealth => 'Sanitario';

  @override
  String get detailActionCommercial => 'Comercial';

  @override
  String get detailActionMovement => 'Movimiento';

  @override
  String get detailActionCost => 'Costo';

  @override
  String get detailRecordsWeights => 'Pesaje';

  @override
  String get detailRecordsProduction => 'Productivos';

  @override
  String get detailRecordsHealth => 'Sanitarios';

  @override
  String get detailRecordsReproduction => 'Reproducción';

  @override
  String get detailRecordsCommercial => 'Comerciales';

  @override
  String get detailRecordsMovements => 'Movimientos';

  @override
  String get detailRecordsCosts => 'Costos';

  @override
  String get detailRecordsValue => 'Valor';

  @override
  String get detailRecordsScore => 'Puntaje';

  @override
  String get detailRecordsDose => 'Dosis';

  @override
  String get detailRecordsCause => 'Causa';

  @override
  String get detailRecordsAmount => 'Monto';

  @override
  String get detailRecordsFrom => 'De';

  @override
  String get detailRecordsTo => 'A';

  @override
  String get detailFormWeightTitle => 'Registrar peso';

  @override
  String get detailFormWeightValue => 'Peso (kg)';

  @override
  String get detailFormWeightMethod => 'Método';

  @override
  String get detailFormWeightMethodScale => 'Báscula';

  @override
  String get detailFormWeightMethodEstimated => 'Estimado';

  @override
  String get detailFormWeightErrorInvalid => 'Ingresa un peso válido';

  @override
  String get detailFormWeightSaved => 'Peso registrado';

  @override
  String get detailFormProductionTitle => 'Registro productivo';

  @override
  String get detailFormProductionType => 'Tipo';

  @override
  String get detailFormProductionValue => 'Valor (opcional)';

  @override
  String get detailFormProductionUnit => 'Unidad';

  @override
  String get detailFormProductionScore => 'Puntaje/BCS';

  @override
  String get detailFormProductionSaved => 'Registro productivo guardado';

  @override
  String get detailFormHealthTitle => 'Registro sanitario';

  @override
  String get detailFormHealthType => 'Tipo';

  @override
  String get detailFormHealthProduct => 'Producto/procedimiento';

  @override
  String get detailFormHealthDose => 'Dosis';

  @override
  String get detailFormHealthAppliedBy => 'Aplicado por';

  @override
  String get detailFormHealthNext => 'Próximo (opcional)';

  @override
  String get detailFormHealthCause => 'Causa (enfermedad/muerte)';

  @override
  String get detailFormHealthProductRequired => 'Producto requerido';

  @override
  String get detailFormHealthSaved => 'Registro sanitario guardado';

  @override
  String get detailFormCommercialTitle => 'Registro comercial';

  @override
  String get detailFormCommercialType => 'Tipo';

  @override
  String get detailFormCommercialAmount => 'Monto';

  @override
  String get detailFormCommercialCurrency => 'Moneda';

  @override
  String get detailFormCommercialCounterparty => 'Contraparte';

  @override
  String get detailFormCommercialSaved => 'Registro comercial guardado';

  @override
  String get detailFormMovementTitle => 'Movimiento';

  @override
  String get detailFormMovementReason => 'Motivo';

  @override
  String get detailFormMovementFrom => 'Desde (opcional)';

  @override
  String get detailFormMovementTo => 'Hacia';

  @override
  String get detailFormMovementMovedBy => 'Movido por';

  @override
  String get detailFormMovementToRequired => 'Destino requerido';

  @override
  String get detailFormMovementSaved => 'Movimiento guardado';

  @override
  String get detailFormCostTitle => 'Costo';

  @override
  String get detailFormCostType => 'Tipo';

  @override
  String get detailFormCostAmount => 'Monto';

  @override
  String get detailFormCostCurrency => 'Moneda';

  @override
  String get detailFormCostAmountRequired => 'Monto requerido';

  @override
  String get detailFormCostSaved => 'Costo guardado';

  @override
  String get detailFormReproductionTitle => 'Registrar evento reproductivo';

  @override
  String get detailFormReproductionServiceType => 'Tipo de servicio';

  @override
  String get detailFormReproductionServiceNatural => 'Monta natural';

  @override
  String get detailFormReproductionServiceAi => 'Inseminación AI';

  @override
  String get detailFormReproductionServiceIvf => 'FIV';

  @override
  String get detailFormReproductionExpectedCalving => 'F. probable parto';

  @override
  String get detailFormReproductionSire => 'Toro / padre (opcional)';

  @override
  String get detailFormReproductionNotes => 'Notas (opcional)';

  @override
  String get detailFormReproductionSaved => 'Evento reproductivo guardado';
}
