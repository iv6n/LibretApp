// Exportaciones agrupadas del módulo de animales
export 'domain/domain.dart' hide AnimalStatus;
export 'application/application.dart';
export 'infrastructure/infrastructure.dart';
export 'bloc/animales_bloc.dart';
export 'bloc/animales_event.dart' hide AddAnimal, UpdateAnimal;
export 'bloc/animales_state.dart';
export 'view/view.dart';
export 'widgets/widgets.dart'
    hide showCreateAnimalSheet, showAnimalFiltersSheet;
