library;
import 'package:flutter/material.dart';
import 'package:libretapp/features/registro/view/registro_reproduccion_page.dart';

/// Both entry points use the same cycle editor.
class AnimalReproductionFormPage extends StatelessWidget {
  const AnimalReproductionFormPage({required this.animalUuid, this.recordId, super.key});
  final String animalUuid;
  final String? recordId;
  bool get isEditing => recordId != null;
  @override
  Widget build(BuildContext context) => RegistroReproduccionPage(animalUuid: animalUuid, recordId: recordId);
}
