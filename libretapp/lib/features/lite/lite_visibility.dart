import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'lite_pet_service.dart';

class LiteVisibility {
  const LiteVisibility._();

  static bool isOpenEntry(AgendaEntry entry) =>
      entry.estado == AgendaEstado.pendiente ||
      entry.estado == AgendaEstado.enProgreso;

  static bool domesticPlant(CultivationEntity cultivation) =>
      cultivation.scale == CultivationScale.individual ||
      cultivation.scale == CultivationScale.group;

  static bool agendaEntry(
    AgendaEntry entry,
    Set<String> petIds,
    Set<String> plantIds, {
    required bool showPlants,
  }) {
    if (entry.loteIds.isNotEmpty) return false;
    if (entry.animalIds.any((id) => !petIds.contains(id))) return false;
    if (entry.cropUuid != null) {
      return showPlants && plantIds.contains(entry.cropUuid);
    }
    if (entry.animalIds.isNotEmpty) return true;
    return entry.sourceType == 'lite';
  }

  static int hiddenCount(
    List<AnimalEntity> animals,
    List<CultivationEntity> cultivations,
    List<AgendaEntry> entries,
  ) {
    final petIds = animals
        .where(LitePetService.isPet)
        .map((a) => a.uuid)
        .toSet();
    final plantIds = cultivations
        .where(domesticPlant)
        .map((c) => c.uuid)
        .toSet();
    return animals.where((a) => !LitePetService.isPet(a)).length +
        cultivations.where((c) => !domesticPlant(c)).length +
        entries
            .where((e) => !agendaEntry(e, petIds, plantIds, showPlants: true))
            .length;
  }
}
