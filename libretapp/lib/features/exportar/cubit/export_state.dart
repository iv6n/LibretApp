/// features › exportar › cubit › export_state — states for ExportCubit.
library;

import 'dart:io';

import 'package:equatable/equatable.dart';

sealed class ExportState extends Equatable {
  const ExportState();
}

final class ExportIdle extends ExportState {
  const ExportIdle();

  @override
  List<Object?> get props => [];
}

final class ExportLoading extends ExportState {
  const ExportLoading();

  @override
  List<Object?> get props => [];
}

final class ExportSuccess extends ExportState {
  const ExportSuccess(this.file);

  final File file;

  @override
  List<Object?> get props => [file];
}

final class ExportError extends ExportState {
  const ExportError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
