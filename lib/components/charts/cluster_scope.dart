import 'package:fdb_manager/components/charts/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../agent_api.dart';
import 'time_series.dart';

class LatencyProbeChart extends TimeSeriesChartBase {
  LatencyProbeChart(
      {Key? key,/* charts.LayoutConfig? layout,*/ Duration? span, bool? showLegend})
      : super(key: key, /*layout: layout,*/ span: span, showLegend: showLegend);

  // @override
  // charts.NumericAxisSpec? primaryAxisSpec(
  //     BuildContext context, charts.Color? preferredColor, num? max) {
  //   return dynamicLabelAxisSpec(
  //     context,
  //     preferredColor,
  //     formatDurationSeconds(max),
  //   );
  // }

  @override
  Iterable<ChartSeries> series() {
    return [
      const ChartSeries(name: 'Tx Start', path: [
        'cluster',
        'latency_probe',
        'transaction_start_seconds',
      ]),
      const ChartSeries(name: 'Tx Commit', path: [
        'cluster',
        'latency_probe',
        'commit_seconds',
      ]),
      const ChartSeries(name: 'Read', path: [
        'cluster',
        'latency_probe',
        'read_seconds',
      ]),
    ];
  }
}

class ReadWriteRateChart extends TimeSeriesChartBase {
  ReadWriteRateChart(
      {Key? key, /*charts.LayoutConfig? layout, */Duration? span, bool? showLegend})
      : super(
          key: key,
          // layout: layout,
          span: span,
          showLegend: showLegend,
        );

  // @override
  // charts.NumericAxisSpec? primaryAxisSpec(
  //     BuildContext context, charts.Color? preferredColor, num? max) {
  //   return dynamicLabelAxisSpec(
  //       context,
  //       preferredColor,
  //       formatterBaseFn(max, ['', 'Ki', 'Mi', 'Gi', 'Ti'],
  //           unit: 'B/s', base: 1024));
  // }

  @override
  Iterable<ChartSeries> series() {
    return [
      const ChartSeries(name: 'read', path: [
        'cluster',
        'workload',
        'bytes',
        'read',
        'hz',
      ]),
      const ChartSeries(name: 'write', path: [
        'cluster',
        'workload',
        'bytes',
        'written',
        'hz',
      ]),
    ];
  }
}

class TransactionRateChart extends TimeSeriesChartBase {
  TransactionRateChart(
      {Key? key,/* charts.LayoutConfig? layout,*/ Duration? span, bool? showLegend})
      : super(
          key: key,
          // layout: layout,
          span: span,
          showLegend: showLegend,
        );

  // @override charts.NumericAxisSpec? primaryAxisSpec(
  //     BuildContext context, charts.Color? preferredColor, num? max) {
  //   return dynamicLabelAxisSpec(context, preferredColor,
  //       formatterBaseFn(max, ['', 'K', 'M', 'G', 'T'], unit: 'Hz', base: 1000));
  // }

  @override
  Iterable<ChartSeries> series() {
    return [
      const ChartSeries(name: 'Commit', path: [
        'cluster',
        'workload',
        'transactions',
        'committed',
        'hz',
      ]),
      const ChartSeries(name: 'Conflict', path: [
        'cluster',
        'workload',
        'transactions',
        'conflicted',
        'hz',
      ]),
    ];
  }
}

class QoSStateChart extends TimeSeriesChartBase {
  QoSStateChart(
      {Key? key, /*charts.LayoutConfig? layout,*/ Duration? span, bool? showLegend})
      : super(
          key: key,
          // layout: layout,
          span: span,
          showLegend: showLegend,
        );

  // @override
  // charts.NumericAxisSpec? primaryAxisSpec(
  //     BuildContext context, charts.Color? preferredColor, num? max) {
  //   return dynamicLabelAxisSpec(context, preferredColor,
  //       formatterBaseFn(max, ['', 'K', 'M', 'G', 'T'], unit: 'Hz', base: 1000));
  // }

  @override
  Iterable<ChartSeries> series() {
    return [
      const ChartSeries(name: 'TPS Limit', path: [
        'cluster',
        'qos',
        'transactions_per_second_limit',
      ]),
    ];
  }
}

class MovingDataChart extends TimeSeriesChartBase {
  MovingDataChart(
      {Key? key, /*charts.LayoutConfig? layout,*/ Duration? span, bool? showLegend})
      : super(key: key, /*layout: layout,*/ span: span, showLegend: showLegend);

  // @override
  // charts.NumericAxisSpec? primaryAxisSpec(
  //     BuildContext context, charts.Color? preferredColor, num? max) {
  //   return dynamicLabelAxisSpec(
  //     context,
  //     preferredColor,
  //     formatCapacity(max),
  //   );
  // }

  @override
  Iterable<ChartSeries> series() {
    return [
      const ChartSeries(name: 'In Flight', path: [
        'cluster',
        'data',
        'moving_data',
        'in_flight_bytes',
      ]),
      const ChartSeries(name: 'Queued', path: [
        'cluster',
        'data',
        'moving_data',
        'in_queue_bytes',
      ]),
    ];
  }
}

class LagChart extends TimeSeriesChartBase {
  LagChart(
      {Key? key, /*charts.LayoutConfig? layout,*/ Duration? span, bool? showLegend})
      : super(key: key, /*layout: layout,*/ span: span, showLegend: showLegend);
  var _enableDCLag = false;

  // @override
  // charts.NumericAxisSpec? primaryAxisSpec(
  //     BuildContext context, charts.Color? preferredColor, num? max) {
  //   return dynamicLabelAxisSpec(
  //     context,
  //     preferredColor,
  //     formatDurationSeconds(max),
  //   );
  // }
  //
  @override
  Widget build(BuildContext context) {
    final history = context.read<InstantStatusProvider>().history;
    _enableDCLag = history.latest?.data?['cluster']?['active_primary_dc'] != '';

    return super.build(context);
  }

  @override
  Iterable<ChartSeries> series() {
    var baseCharts = [
      const ChartSeries(name: 'SS Data', path: [
        'cluster',
        'qos',
        'worst_data_lag_storage_server',
        'seconds',
      ]),
      const ChartSeries(name: 'SS Durable', path: [
        'cluster',
        'qos',
        'worst_durability_lag_storage_server',
        'seconds',
      ]),
    ];
    if (_enableDCLag) {
      baseCharts.add(const ChartSeries(name: 'DC', path: [
        'cluster',
        'datacenter_lag',
        'seconds',
      ]));
    }
    return baseCharts;
  }
}
