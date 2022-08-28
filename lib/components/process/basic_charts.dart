import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../agent_api.dart';
import '../charts/format.dart';
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

class MemoryUsageChart extends TimeSeriesChartBase {
  MemoryUsageChart(this.processID,
      {Key? key, charts.LayoutConfig? layout, Duration? span, bool? showLegend})
      : super(key: key, layout: layout, span: span, showLegend: showLegend);

  final String processID;

  @override
  Iterable<ChartSeries> series() {
    return [
      ChartSeries(name: 'available', path: [
        'cluster',
        'processes',
        processID,
        'memory',
        'available_bytes',
      ])
    ];
  }

  @override
  charts.NumericAxisSpec? primaryAxisSpec(
      BuildContext context, charts.Color? preferredColor, num? max) {
    return dynamicLabelAxisSpec(
      context,
      preferredColor,
      formatCapacity(max),
    );
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
      BuildContext context, charts.Color? preferredColor, num? max) {
    return dynamicLabelAxisSpec(
        context,
        preferredColor,
        formatterBaseFn(max, ['M', 'G', 'T', 'P'],
            unit: 'bps', base: 1000));
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
