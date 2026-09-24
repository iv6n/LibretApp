/// features > directorio > animales > animals — barrel export for the animales sub-feature.
library;

// Exportaciones agrupadas del mÃ³dulo de animales
export 'advisor/advisor.dart';
export 'domain/domain.dart' hide AnimalStatus;
export 'domain/animal_identification.dart';
export 'domain/animal_movement_details.dart';
export 'reproduccion/reproduccion.dart';
export 'application/application.dart';
export 'infrastructure/infrastructure.dart';
export 'bloc/animales_bloc.dart';
export 'bloc/animales_event.dart' hide AddAnimal, UpdateAnimal;
export 'bloc/animales_state.dart';
export 'view/view.dart';
export 'widgets/widgets.dart';
