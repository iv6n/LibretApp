import 'package:flutter_bloc/flutter_bloc.dart';
import 'animales_state.dart';

class AnimalesBloc extends Bloc<dynamic, AnimalesState> {
  AnimalesBloc() : super(AnimalesInitial());
}

class AnimalesInitial extends AnimalesState {}

class AnimalesLoading extends AnimalesState {}

class AnimalesLoaded extends AnimalesState {
  final List<dynamic> visibleAnimals;
  final List<dynamic> allAnimals;
  final bool isSearching;
  final String searchQuery;
  AnimalesLoaded({
    this.visibleAnimals = const [],
    this.allAnimals = const [],
    this.isSearching = false,
    this.searchQuery = '',
  });
}

class AnimalesError extends AnimalesState {
  final String message;
  AnimalesError(this.message);
}
