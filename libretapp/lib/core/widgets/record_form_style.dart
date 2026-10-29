import 'package:flutter/material.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/theme/theme.dart';

/// Visual identity shared by a record's menu entry and its form.
enum RecordFormStyle {
  rfid(
    'RFID',
    'Escanea y asigna aretes electrónicos.',
    Icons.sensors,
    Colors.deepOrange,
    AppAssetPaths.recordRfid,
  ),
  animal(
    'Animal',
    'Identificación y datos del animal.',
    Icons.pets_outlined,
    AppColors.primary,
    AppAssetPaths.recordAnimal,
  ),
  lot(
    'Lote',
    'Agrupa animales y define su manejo.',
    Icons.groups_outlined,
    AppColors.secondary,
    AppAssetPaths.recordLot,
  ),
  birth(
    'Parición',
    'Fecha, resultado y crías del parto.',
    Icons.child_care,
    Colors.pink,
    AppAssetPaths.healthBirth,
  ),
  bulkHealth(
    'Tratar lote',
    'Aplica un tratamiento a varios animales.',
    Icons.vaccines_outlined,
    Colors.teal,
    AppAssetPaths.healthTreatment,
  ),
  weaning(
    'Destete',
    'Fecha y peso del becerro al destete.',
    Icons.child_friendly_outlined,
    Colors.brown,
    null,
  ),
  weight(
    'Peso',
    'Peso y método de medición del animal.',
    Icons.monitor_weight_outlined,
    Colors.green,
    AppAssetPaths.healthWeight,
  ),
  health(
    'Sanitario',
    'Vacunas, tratamientos y seguimiento de salud.',
    Icons.medical_services_outlined,
    Colors.teal,
    AppAssetPaths.healthVaccine,
  ),
  cost(
    'Costo',
    'Gastos de manejo asociados al animal.',
    Icons.payments_outlined,
    Colors.brown,
    AppAssetPaths.recordCost,
  ),
  movement(
    'Cambio de ubicación',
    'Origen y destino del movimiento interno.',
    Icons.swap_horiz,
    Colors.indigo,
    AppAssetPaths.recordMovement,
  ),
  production(
    'Producción',
    'Ganancia de peso y condición del animal.',
    Icons.analytics_outlined,
    Colors.blue,
    AppAssetPaths.recordProduction,
  ),
  milking(
    'Ordeña',
    'Leche por animal o lote en cada sesión.',
    Icons.water_drop_outlined,
    Color(0xFF0288D1),
    AppAssetPaths.healthMilkProduction,
  ),
  reproduction(
    'Reproducción',
    'Servicios y seguimiento del ciclo reproductivo.',
    Icons.favorite_outline,
    Colors.deepOrange,
    AppAssetPaths.recordReproduction,
  ),
  commercial(
    'Comercial',
    'Compra, venta y datos de la operación.',
    Icons.store_outlined,
    Colors.purple,
    AppAssetPaths.recordSale,
  ),
  location(
    'Ubicación',
    'Espacio, capacidad y características del lugar.',
    Icons.place_outlined,
    AppColors.accent,
    AppAssetPaths.recordLocation,
  ),
  crop(
    'Cultivo',
    'Siembra, superficie y manejo del cultivo.',
    Icons.grass,
    Colors.lightGreen,
    AppAssetPaths.cropField,
  ),
  harvest(
    'Cosecha',
    'Rendimiento y calidad de la cosecha.',
    Icons.agriculture,
    Colors.orange,
    AppAssetPaths.cropHarvested,
  ),
  watering(
    'Riego',
    'Fecha, cantidad y método de riego.',
    Icons.water_drop_outlined,
    Colors.blueAccent,
    AppAssetPaths.recordIrrigation,
  ),
  cropHealth(
    'Salud de cultivo',
    'Problemas de salud y tratamiento del cultivo.',
    Icons.health_and_safety_outlined,
    Colors.redAccent,
    AppAssetPaths.recordCropHealth,
  ),
  task(
    'Tarea',
    'Actividad y fecha de trabajo del cultivo.',
    Icons.task_alt,
    Colors.amber,
    AppAssetPaths.recordTask,
  ),
  income(
    'Ingreso',
    'Importe, origen y fecha del ingreso.',
    Icons.trending_up,
    Colors.green,
    AppAssetPaths.inventoryIncome,
  ),
  expense(
    'Gasto general',
    'Importe, categoría y fecha del gasto.',
    Icons.receipt_long_outlined,
    Colors.brown,
    AppAssetPaths.inventoryExpense,
  );

  const RecordFormStyle(
    this.label,
    this.description,
    this.icon,
    this.color,
    this.assetPath,
  );

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String? assetPath;
}
