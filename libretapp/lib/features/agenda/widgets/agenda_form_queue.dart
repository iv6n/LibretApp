/// features › agenda › widgets › agenda_form_queue — sequences a single-animal
/// form (Reproducción, Producción) across a batch of selected animals, one at
/// a time, so an agenda "Realizar" on N animals doesn't require N separate
/// taps from the pending list. Core loop is BuildContext-free and pure.
library;

/// Pushes a form for each uuid in order, stopping (without erroring) the
/// first time a step fails [isSuccess] — i.e. the user backed out or
/// cancelled — so already-completed steps are not rolled back. Calls
/// [onStepSuccess] immediately after each successful step, not batched at
/// the end, so partial progress survives a mid-queue cancel.
typedef AgendaFormQueueStep<T> =
    Future<T?> Function(String animalUuid, int index, int total);

Future<List<String>> runAgendaFormQueue<T>({
  required List<String> animalUuids,
  required AgendaFormQueueStep<T> pushStep,
  required bool Function(T? result) isSuccess,
  required void Function(String animalUuid) onStepSuccess,
  bool Function()? shouldContinue,
}) async {
  final completed = <String>[];
  for (var i = 0; i < animalUuids.length; i++) {
    if (shouldContinue != null && !shouldContinue()) break;
    final uuid = animalUuids[i];
    final result = await pushStep(uuid, i, animalUuids.length);
    if (!isSuccess(result)) break;
    completed.add(uuid);
    onStepSuccess(uuid);
  }
  return completed;
}
