import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../agent_api.dart';
import '../charts/time_series.dart';

class CPUUsageChart extends TimeSeriesChartBase {
  CPUUsageChart(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span, bool? showLegend})
      : super(key: key, layout: layout, span: span, showLegend: showLegend);

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'usage_cores', path: [
        'cluster',
        'processes',
        processID,
        'cpu',
        'usage_cores',
      ])
    ];
  }
}

class DiskUsageChart extends TimeSeriesChartBase {
  DiskUsageChart(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span, bool? showLegend})
      : super(key: key, layout: layout, span: span, showLegend: showLegend);

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'read', path: [
        'cluster',
        'processes',
        processID,
        'disk',
        'reads',
        'hz',
      ]),
      ChartSeries(name: 'write', path: [
        'cluster',
        'processes',
        processID,
        'disk',
        'writes',
        'hz',
      ])
    ];
  }
}

class NetworkUsageChart extends TimeSeriesChartBase {
  NetworkUsageChart(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span, bool? showLegend})
      : super(
          key: key,
          layout: layout,
          span: span,
          showLegend: showLegend,
        );

  @override
  charts.NumericAxisSpec? primaryAxisSpec(
      BuildContext context, charts.Color? preferredColor) {
    return charts.NumericAxisSpec(
      tickProviderSpec: const charts.BasicNumericTickProviderSpec(
        dataIsInWholeNumbers: false,
      ),
      tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
        (measure) => measure == null ? '' : '${measure}Mbps',
      ),
      renderSpec: charts.GridlineRendererSpec(
        lineStyle: charts.LineStyleSpec(color: preferredColor),
        labelStyle: charts.TextStyleSpec(
          fontSize: baseFontSize(),
          color: preferredColor,
        ),
      ),
    );
  }

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'tx', path: [
        'cluster',
        'processes',
        processID,
        'network',
        'megabits_sent',
        'hz',
      ]),
      ChartSeries(name: 'rx', path: [
        'cluster',
        'processes',
        processID,
        'network',
        'megabits_received',
        'hz',
      ])
    ];
  }
}
