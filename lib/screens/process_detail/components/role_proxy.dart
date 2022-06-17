import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../../agent_api.dart';
import '../../../components/charts/time_series.dart';
import '../../../models/status.dart';

class ProxyRole extends StatelessWidget {
  const ProxyRole(this.processID, this.role, {Key? key}) : super(key: key);

  final ProcessRoleInfo role;
  final String processID;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(children: [
      Text('GRV Latency', style: theme.textTheme.bodyText1),
      SizedBox(height: 100, child: GRVLatencyDefault(processID)),
      Text('GRV Batch Latency', style: theme.textTheme.bodyText1),
      SizedBox(height: 100, child: GRVLatencyBatch(processID)),
      Text('Commit Latency', style: theme.textTheme.bodyText1),
      SizedBox(height: 100, child: CommitLatency(processID)),
    ]);
  }
}

mixin _LatencyChartMixin on TimeSeriesChartBase {
  @override
  charts.NumericAxisSpec? primaryAxisSpec(
      BuildContext context, charts.Color? preferredColor) {
    return charts.NumericAxisSpec(
      tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          dataIsInWholeNumbers: false),
      tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
          (measure) => measure == null ? '' : '${measure * 1000}ms'),
      renderSpec: charts.GridlineRendererSpec(
        lineStyle: charts.LineStyleSpec(color: preferredColor),
        labelStyle: charts.TextStyleSpec(
          fontSize: baseFontSize(),
          color: preferredColor,
        ),
      ),
    );
  }
}

class GRVLatencyDefault extends TimeSeriesChartBase with _LatencyChartMixin {
  GRVLatencyDefault(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span})
      : super(
          key: key,
          layout: layout,
          span: span,
          showLegend: true,
        );

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'median', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'grv_latency_statistics',
        'default',
        'median',
      ]),
      ChartSeries(name: 'p99', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'grv_latency_statistics',
        'default',
        'p99',
      ]),
      ChartSeries(name: 'p99.9', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'grv_latency_statistics',
        'default',
        'p99.9',
      ])
    ];
  }
}

class GRVLatencyBatch extends TimeSeriesChartBase with _LatencyChartMixin {
  GRVLatencyBatch(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span})
      : super(
          key: key,
          layout: layout,
          span: span,
          showLegend: true,
        );

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'median', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'grv_latency_statistics',
        'batch',
        'median',
      ]),
      ChartSeries(name: 'p99', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'grv_latency_statistics',
        'batch',
        'p99',
      ]),
      ChartSeries(name: 'p99.9', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'grv_latency_statistics',
        'batch',
        'p99.9',
      ]),
    ];
  }
}

class CommitLatency extends TimeSeriesChartBase with _LatencyChartMixin {
  CommitLatency(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span})
      : super(
          key: key,
          layout: layout,
          span: span,
          showLegend: true,
        );

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'median', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'commit_latency_statistics',
        'median',
      ]),
      ChartSeries(name: 'p99', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'commit_latency_statistics',
        'p99',
      ]),
      ChartSeries(name: 'p99.9', path: [
        'cluster',
        'processes',
        processID,
        'roles',
        'proxy',
        'commit_latency_statistics',
        'p99.9',
      ]),
    ];
  }
}
