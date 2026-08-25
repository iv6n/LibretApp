library;

import 'package:libretapp/features/agenda/domain/agenda_registration.dart';

abstract class AgendaRegistrationRepository {
  Future<List<AgendaRegistration>> fetchAll();
  Future<List<AgendaRegistration>> fetchForEntries(Set<String> entryIds);
  Future<AgendaRegistration?> getById(String id);
  Future<AgendaRegistration?> getForRow(String entryId, String? animalId);
  Future<void> save(AgendaRegistration registration);
  Future<void> deleteForEntry(String entryId);
  Future<void> clearAll();
}
