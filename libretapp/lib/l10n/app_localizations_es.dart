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
  String get navDirectory => 'Directorio';

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
  String get animalsSearchHint => 'Buscar por arete, nombre o raza';

  @override
  String get animalsAdvancedSearch => 'Búsqueda avanzada';

  @override
  String get animalsRecentSearches => 'Búsquedas recientes';

  @override
  String get animalsRecentActivity => 'Actividad reciente';

  @override
  String get animalsClearHistory => 'Limpiar historial';

  @override
  String get animalsFilters => 'Filtros';

  @override
  String get animalsNoResults => 'Sin resultados';

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
  String get animalsSelectionHint => 'Mantener presionado para seleccionar';

  @override
  String animalsSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '$count seleccionado',
    );
    return '$_temp0';
  }

  @override
  String animalsSelectVisible(Object selected, Object total) {
    return 'Seleccionar visibles ($selected/$total)';
  }

  @override
  String get animalsSelectVisibleSimple => 'Seleccionar visibles';

  @override
  String get animalsDeselectVisible => 'Quitar visibles';

  @override
  String get animalsSelectionCancel => 'Cancelar';

  @override
  String animalsSelectionHiddenCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados están ocultos por filtros',
      one: '$count seleccionado está oculto por filtros',
    );
    return '$_temp0';
  }

  @override
  String get animalsSelectionAllHiddenWarning =>
      'Todos los seleccionados están ocultos por filtros activos.';

  @override
  String animalsBulkMaintenanceAction(Object count) {
    return 'Agregar mantenimiento ($count)';
  }

  @override
  String animalsBulkMaintenanceError(Object error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get animalsBulkMaintenanceConfirmTitle => 'Confirmar mantenimiento';

  @override
  String animalsBulkMaintenanceConfirmBody(Object count) {
    return 'Se aplicará el mismo mantenimiento a $count animales.';
  }

  @override
  String get animalsBulkMaintenanceConfirmAction => 'Continuar';

  @override
  String get stageFilterCalf => 'Becerros';

  @override
  String get stageFilterHeifer => 'Vaquilla';

  @override
  String get stageFilterYoungBull => 'Torete';

  @override
  String get stageFilterSteer => 'Novillo';

  @override
  String get stageFilterCow => 'Vaca';

  @override
  String get stageFilterBull => 'Toro';

  @override
  String get stageFilterColt => 'Potro/Potranca';

  @override
  String get stageFilterHorse => 'Caballo';

  @override
  String get stageFilterMare => 'Yegua';

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
  String get actionSelect => 'Seleccionar';

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
  String get detailFormAnimalRequired => 'Selecciona un animal primero';

  @override
  String get detailFormNumberInvalid => 'Ingresa un número válido';

  @override
  String get detailFormAmountPositive => 'El valor debe ser mayor que cero';

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
  String get detailFormProductionValueRequired =>
      'Ingresa un valor para este tipo de registro';

  @override
  String get detailFormProductionScoreRequired =>
      'Ingresa un puntaje para condición corporal';

  @override
  String get detailFormProductionScoreInvalid => 'Ingresa un puntaje válido';

  @override
  String get detailFormProductionScoreRange =>
      'El puntaje debe estar entre 0 y 9';

  @override
  String get detailFormProductionDataRequired =>
      'Agrega al menos un dato para guardar el registro';

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
  String get detailFormHealthNextAfterDate =>
      'La próxima fecha no puede ser anterior a la fecha del registro';

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
  String get detailFormCommercialAmountRequired =>
      'Monto requerido para este tipo de registro';

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
  String get detailFormMovementDifferentLocations =>
      'La ubicación de origen y destino no pueden ser iguales';

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
  String get detailFormReproductionExpectedAfterDate =>
      'La fecha probable de parto no puede ser anterior a la fecha de servicio';

  @override
  String get detailFormReproductionSaved => 'Evento reproductivo guardado';

  @override
  String get animalFormLoadError => 'No se pudo cargar el formulario de animal';

  @override
  String get animalFormCategoryAdjusted =>
      'Categoría ajustada a Otro para coincidir con la especie';

  @override
  String get animalFormSpeciesAdjusted =>
      'Especie ajustada a Bovino para esa categoría';

  @override
  String get animalFormNoSelection => 'Sin selección';

  @override
  String get animalFormNoTagTitle => 'Animal sin arete';

  @override
  String get animalFormNoTagMessage =>
      'Este animal no tiene arete. Se recomienda etiquetarlo para su seguimiento. ¿Deseas guardar de todos modos?';

  @override
  String get animalFormDuplicateEarTag => 'Ya existe un animal con ese arete';

  @override
  String get animalFormUnsupportedAction =>
      'Acción no soportada desde este formulario';

  @override
  String animalFormRecordSaveError(Object error) {
    return 'No se pudo guardar el registro: $error';
  }

  @override
  String get animalFormSaveFirstForRecords =>
      'Guarda el animal primero para agregar registros';

  @override
  String get animalFormInvalidPurchasePrice =>
      'El precio de compra debe ser un número válido';

  @override
  String get animalFormNoAutoMotherFound =>
      'No se encontró madre automática; puedes guardar o seleccionar una madre manualmente.';

  @override
  String get animalFormEditTitle => 'Editar animal';

  @override
  String get animalFormCreateTitle => 'Agregar animal';

  @override
  String get animalFormNameOrVisualId => 'Nombre o ID visual';

  @override
  String get animalFormBreedOptional => 'Raza (opcional)';

  @override
  String get animalFormUnknownBreed => 'Desconocido';

  @override
  String get animalFormStatus => 'Estado';

  @override
  String get animalFormSectionOrigin => 'Origen';

  @override
  String get animalFormMotherOptional => 'Madre (opcional)';

  @override
  String get animalFormFatherOptional => 'Padre (opcional)';

  @override
  String get animalFormSelectMother => 'Seleccionar madre';

  @override
  String get animalFormSelectFather => 'Seleccionar padre';

  @override
  String get animalFormNoLocation => 'Sin ubicación';

  @override
  String get animalFormNoBatch => 'Sin lote';

  @override
  String get animalFormSectionWeightHealth => 'Peso y salud';

  @override
  String get animalFormWeightOptional => 'Peso (kg) opcional';

  @override
  String get animalFormSectionNotesPhoto => 'Notas y foto';

  @override
  String get animalFormOwnerOptional => 'Propietario (opcional)';

  @override
  String get animalFormPurchasePriceOptional => 'Precio de compra (opcional)';

  @override
  String get animalFormRecordsAvailableAfterSave =>
      'Los accesos de registros estarán disponibles al guardar el animal.';

  @override
  String get animalFormRegisterAsCalf =>
      'Registrar como cría (agregar madre automáticamente)';

  @override
  String get animalFormSaving => 'Guardando...';

  @override
  String get animalFormSaveAnimal => 'Guardar animal';

  @override
  String get detailQuickActionsTitle => 'Agregar registro';

  @override
  String get detailNoRecordsYet => 'Sin registros aún';

  @override
  String get detailNoRecordsHint =>
      'Usa el botón + para agregar el primer registro de este animal.';
}
