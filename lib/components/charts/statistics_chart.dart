import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../agent_api.dart';
import '../charts/format.dart';
import '../charts/time_series.dart';

class StatisticsChart extends TimeSeriesChartBase {
  StatisticsChart(this.basePath,
      {this.percentiles,
      this.isLatency = false,
      Key? key,
      charts.LayoutConfig? layout,
      Duration? span,
      bool? showLegend})
      : super(key: key, layout: layout, span: span, showLegend: showLegend);

  static final defaultPercentiles = ['p50', 'p99', 'p99.9'];

  final List<String> basePath;
  final bool isLatency;
  final List<String>? percentiles;

  @override
  charts.NumericAxisSpec? primaryAxisSpec(
      BuildContext context, charts.Color? preferredColor, num? max) {
    if (isLatency) {
      return charts.NumericAxisSpec(
          tickProviderSpec: const charts.BasicNumericTickProviderSpec(
              dataIsInWholeNumbers: false),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                  (measure) => measure == null ? '' : '${measure * 1000}ms'));
    }
    return super.primaryAxisSpec(context, preferredColor, max);
  }

  @override
  Iterable<ChartSeries> series() {
    final percentiles = this.percentiles ?? defaultPercentiles;
    return percentiles.map((e) => ChartSeries(name: e, path: [...basePath, e]));
  }
}
