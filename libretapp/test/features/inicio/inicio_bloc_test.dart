import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/finanzas/domain/enums/financial_period_preset.dart';
import 'package:libretapp/features/finanzas/domain/finance_summary_service.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Inicio shows main data before optional panels and isolates failures',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = SharedPrefsService(
        await SharedPreferences.getInstance(),
      );
      final dashboard = Completer<InicioDashboardData>();
      final finance = Completer<FinanceSummaryDetail>();
      final library = Completer<List<LibraryManifestBook>>();
      final bloc = InicioBloc(
        dashboardService: _DashboardService(dashboard.future),
        configRepository: DashboardConfigRepository(preferences),
        financeService: _FinanceService(finance.future),
        libraryRepository: _LibraryRepository(library.future),
      );
      addTearDown(bloc.close);

      bloc.add(const LoadInicio());
      final loadedMain = bloc.stream.firstWhere(
        (state) => state.status == InicioStatus.loaded,
      );
      dashboard.complete(_dashboardData());

      final mainState = await loadedMain;
      expect(mainState.data, isNotNull);
      expect(mainState.financeLoading, isTrue);
      expect(mainState.libraryLoading, isTrue);

      final libraryLoaded = bloc.stream.firstWhere(
        (state) => state.data != null && !state.libraryLoading,
      );
      library.complete(const []);
      final withLibrary = await libraryLoaded;
      expect(withLibrary.libraryPicks, isEmpty);
      expect(withLibrary.financeLoading, isTrue);

      final financeFailed = bloc.stream.firstWhere(
        (state) => state.financeErrorMessage != null,
      );
      finance.completeError(StateError('finance offline'));
      final finalState = await financeFailed;
      expect(finalState.status, InicioStatus.loaded);
      expect(finalState.financeLoading, isFalse);
      expect(finalState.financeErrorMessage, contains('finance offline'));
      expect(finalState.data, isNotNull);
    },
  );
}

InicioDashboardData _dashboardData() => InicioDashboardData(
  profileName: 'Test',
  farmName: 'Farm',
  totalAnimals: 0,
  totalAnimalCapacity: 0,
  attentionAnimals: 0,
  activeLotes: 0,
  totalLocations: 0,
  upcomingEventsCount: 0,
  upcomingEvents: const <AgendaEntry>[],
  alerts: const <InicioAlertItem>[],
  tasks: const <InicioTaskItem>[],
  lastUpdated: DateTime(2026, 1, 1),
  categoryBreakdown: const [],
  upcomingCalvings: const [],
);

class _DashboardService implements InicioDashboardService {
  _DashboardService(this.result);
  final Future<InicioDashboardData> result;

  @override
  Future<InicioDashboardData> loadDashboard() => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FinanceService implements FinanceSummaryService {
  _FinanceService(this.result);
  final Future<FinanceSummaryDetail> result;

  @override
  Future<FinanceSummaryDetail> loadForPreset({
    FinancialPeriodPreset preset = FinancialPeriodPreset.thisMonth,
    DateTime? now,
  }) => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LibraryRepository implements LibraryRepository {
  _LibraryRepository(this.result);
  final Future<List<LibraryManifestBook>> result;

  @override
  Future<List<LibraryManifestBook>> getAll() => result;

  @override
  Future<List<LibraryManifestBook>> search(String query) => result;

  @override
  Future<BookContent> loadBookContent(LibraryManifestBook book) =>
      throw UnimplementedError();
}
