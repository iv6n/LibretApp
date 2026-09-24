/// Compact derived performance section used by the lot detail page.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/tenancy/farm_context_service.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/feed_service.dart';
import 'package:libretapp/features/directorio/lotes/application/lote_performance_cubit.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/domain/services/weight_performance_calculator.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class LotePerformancePanel extends StatelessWidget {
  const LotePerformancePanel({required this.lote, super.key});

  final LoteEntity lote;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LotePerformanceCubit(
        animalRepository: locator<AnimalRepository>(),
        weightRepository: locator<WeightRecordRepository>(),
        feedService: locator.isRegistered<FeedService>()
            ? locator<FeedService>()
            : null,
        farmContextRepository: locator.isRegistered<FarmContextRepository>()
            ? locator<FarmContextRepository>()
            : null,
      )..load(lote),
      child: const _LotePerformanceView(),
    );
  }
}

class _LotePerformanceView extends StatelessWidget {
  const _LotePerformanceView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<LotePerformanceCubit, LotePerformanceState>(
      builder: (context, state) {
        if (state.isLoading || state.status == LotePerformanceStatus.initial) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state.status == LotePerformanceStatus.failure) {
          return _SectionCard(
            title: l10n.lotePerformanceTitle,
            child: Text(state.errorMessage ?? l10n.lotePerformanceLoadError),
          );
        }

        final summary = state.summary;
        if (summary == null || summary.measuredAnimalCount == 0) {
          return _SectionCard(
            title: l10n.lotePerformanceTitle,
            child: Text(l10n.lotePerformanceEmpty),
          );
        }

        return Column(
          children: [
            LotePerformanceCard(summary: summary),
            if (state.sessions.length > 1)
              _SessionHistory(sessions: state.sessions),
            if (_hasEconomics(state.economics))
              _EconomicsCard(metrics: state.economics!),
          ],
        );
      },
    );
  }
}

/// Compact, report-style performance card that can be reused by a share
/// preview or a future report export without creating a raster image.
class LotePerformanceCard extends StatelessWidget {
  const LotePerformanceCard({required this.summary, super.key});

  final LotPerformanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final previous = summary.previousSession;
    final currentAverage = summary.averageWeightKg;
    final sessionDelta =
        currentAverage == null || previous?.averageWeightKg == null
        ? null
        : currentAverage - previous!.averageWeightKg!;

    return _SectionCard(
      title: l10n.lotePerformanceTitle,
      trailing: Text(
        '${summary.measuredAnimalCount}/${summary.activeAnimalCount}',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      child: Column(
        children: [
          _MetricGrid(
            metrics: [
              _MetricValue(
                l10n.lotePerformanceTotal,
                '${summary.totalWeightKg.toStringAsFixed(1)} kg',
              ),
              _MetricValue(l10n.lotePerformanceAverage, _kg(currentAverage)),
              _MetricValue(
                l10n.lotePerformanceAdgAverage,
                _adg(summary.averageAdgKgPerDay),
              ),
              _MetricValue(l10n.lotePerformanceGain, _kg(summary.totalGainKg)),
            ],
          ),
          if (sessionDelta != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.compare_arrows, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${l10n.lotePerformancePrevious}: ${_signedKg(sessionDelta)}',
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CountLine(
                  color: Colors.green,
                  label: l10n.lotePerformanceGood,
                  count: summary.goodCount,
                ),
              ),
              Expanded(
                child: _CountLine(
                  color: Colors.amber.shade800,
                  label: l10n.lotePerformanceBelow,
                  count: summary.belowAverageCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _CountLine(
                  color: Colors.red,
                  label: l10n.lotePerformanceNoGain,
                  count: summary.noGainCount,
                ),
              ),
              Expanded(
                child: _CountLine(
                  color: Colors.grey,
                  label: l10n.lotePerformanceNoReference,
                  count: summary.noReferenceCount,
                ),
              ),
            ],
          ),
          if (summary.unmeasuredAnimalCount > 0) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.lotePerformanceUnmeasured(summary.unmeasuredAnimalCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionHistory extends StatelessWidget {
  const _SessionHistory({required this.sessions});

  final List<WeighingSessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SectionCard(
      title: l10n.lotePerformanceSessions,
      child: Column(
        children: sessions.take(6).map((session) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(width: 70, child: Text(_date(session.date))),
                Expanded(
                  child: Text(
                    '${_kg(session.averageWeightKg)} ${l10n.lotePerformanceAverage.toLowerCase()}',
                  ),
                ),
                Text(_adg(session.averageAdgKgPerDay)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EconomicsCard extends StatelessWidget {
  const _EconomicsCard({required this.metrics});

  final LotEconomicMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SectionCard(
      title: l10n.lotePerformanceEconomics,
      child: _MetricGrid(
        metrics: [
          if (metrics.dailyFeedCost != null)
            _MetricValue(
              l10n.lotePerformanceFeedPerDay,
              _money(metrics.dailyFeedCost),
            ),
          if (metrics.feedCostPerKgGain != null)
            _MetricValue(
              l10n.lotePerformanceCostPerKg,
              _money(metrics.feedCostPerKgGain),
            ),
          if (metrics.feedMargin != null)
            _MetricValue(
              l10n.lotePerformanceMargin,
              _money(metrics.feedMargin),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_MetricValue> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 10,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: 132,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricValue {
  const _MetricValue(this.label, this.value);

  final String label;
  final String value;
}

class _CountLine extends StatelessWidget {
  const _CountLine({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 10, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          '$label: $count',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}

bool _hasEconomics(LotEconomicMetrics? metrics) =>
    metrics != null &&
    (metrics.dailyFeedCost != null ||
        metrics.feedCostPerKgGain != null ||
        metrics.feedMargin != null);

String _kg(double? value) =>
    value == null ? '—' : '${value.toStringAsFixed(1)} kg';

String _adg(double? value) =>
    value == null ? '—' : '${value.toStringAsFixed(2)} kg/d';

String _signedKg(double value) =>
    '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)} kg';

String _money(double? value) =>
    value == null ? '—' : '\$${value.toStringAsFixed(2)}';

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
