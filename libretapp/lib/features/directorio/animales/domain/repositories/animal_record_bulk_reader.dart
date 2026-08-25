/// Bulk export capability implemented by all Isar animal-record repositories.
library;

class AnimalRecordExportItem<T> {
  const AnimalRecordExportItem({
    required this.animalUuid,
    required this.recordUuid,
    required this.record,
  });

  final String animalUuid;
  final String recordUuid;
  final T record;
}

abstract interface class AnimalRecordBulkReader<T> {
  Future<List<AnimalRecordExportItem<T>>> getAllAnimalRecords();
}
