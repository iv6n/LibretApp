/// features \u203a directorio \u203a animales \u203a application \u203a bloc \u203a animal_state \u2014 state for AnimalBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

enum AnimalStatus { initial, loading, success, failure }

class AnimalState extends Equatable {
  const AnimalState({
    this.status = AnimalStatus.initial,
    this.animals = const [],
    this.selectedAnimal,
    this.errorMessage,
  });

  factory AnimalState.initial() => const AnimalState();
  factory AnimalState.loading() =>
      const AnimalState(status: AnimalStatus.loading);
  factory AnimalState.success({
    required List<AnimalEntity> animals,
    AnimalEntity? selectedAnimal,
  }) {
    return AnimalState(
      status: AnimalStatus.success,
      animals: animals,
      selectedAnimal: selectedAnimal,
    );
  }

  factory AnimalState.failure({
    required String message,
    List<AnimalEntity> animals = const [],
    AnimalEntity? selectedAnimal,
  }) {
    return AnimalState(
      status: AnimalStatus.failure,
      animals: animals,
      selectedAnimal: selectedAnimal,
      errorMessage: message,
    );
  }
  final AnimalStatus status;
  final List<AnimalEntity> animals;
  final AnimalEntity? selectedAnimal;
  final String? errorMessage;

  bool get isLoading => status == AnimalStatus.loading;
  bool get isSuccess => status == AnimalStatus.success;
  bool get isError => status == AnimalStatus.failure;
  bool get hasSelectedAnimal => selectedAnimal != null;

  AnimalState copyWith({
    AnimalStatus? status,
    List<AnimalEntity>? animals,
    AnimalEntity? selectedAnimal,
    String? errorMessage,
  }) {
    return AnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AnimalState selectAnimal(AnimalEntity? newSelection) =>
      copyWith(selectedAnimal: newSelection);

  AnimalState updateAnimals(List<AnimalEntity> newAnimals) {
    final stillSelected =
        selectedAnimal != null &&
        newAnimals.any((a) => a.uuid == selectedAnimal!.uuid);
    return copyWith(
      animals: newAnimals,
      selectedAnimal: stillSelected ? selectedAnimal : null,
    );
  }

  @override
  List<Object?> get props => [status, animals, selectedAnimal, errorMessage];
}
