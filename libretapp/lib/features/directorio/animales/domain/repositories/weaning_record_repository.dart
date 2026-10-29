library;

import '../entities/weaning_record.dart';
import 'animal_record_bulk_reader.dart';
import 'editable_record_repository.dart';

abstract class WeaningRecordRepository
    implements AnimalRecordBulkReader<WeaningRecord>, EditableRecordRepository<WeaningRecord> {
  Future<List<WeaningRecord>> getWeaningRecords(String animalUuid);
  Future<Map<String, List<WeaningRecord>>> getWeaningRecordsForAnimals(Set<String> animalUuids);
  Future<WeaningRecord> save(WeaningRecord record);
  Future<void> deleteWeaningRecord(String recordId);
}
