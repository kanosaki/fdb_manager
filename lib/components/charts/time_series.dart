import 'package:fdb_manager/data/status_history.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../agent_api.dart';

class ChartSeries {
  const ChartSeries({required this.name, required this.path});

  final String name;
  final List<String> path;
}

abstract class TimeSeriesChartBase extends StatelessWidget {
  TimeSeriesChartBase(
      {Key? key, charts.LayoutConfig? layout, Duration? span, bool? showLegend})
      : _layout = layout ??
            charts.LayoutConfig(
              topMarginSpec: charts.MarginSpec.fixedPixel(10),
              bottomMarginSpec: charts.MarginSpec.fixedPixel(15),
              leftMarginSpec: charts.MarginSpec.fixedPixel(50),
              rightMarginSpec: charts.MarginSpec.fixedPixel(10),
            ),
        _span = span ?? const Duration(minutes: 5),
        _showLegend = showLegend ?? false,
        super(key: key);

  final charts.LayoutConfig _layout;
  final Duration _span;

  final bool _showLegend;

  Iterable<ChartSeries> series();

  int baseFontSize() {
    return 10;
  }

  charts.NumericAxisSpec? primaryAxisSpec(
      BuildContext context, charts.Color? preferredColor, num? max) {
    return charts.NumericAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
        lineStyle: charts.LineStyleSpec(color: preferredColor),
        labelStyle: charts.TextStyleSpec(
          fontSize: baseFontSize(),
          color: preferredColor,
        ),
      ),
    );
  }

  charts.AxisSpec? domainAxisSpec(
      BuildContext context, charts.Color? preferredColor) {
    return charts.DateTimeAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
        lineStyle: charts.LineStyleSpec(color: preferredColor),
        labelStyle: charts.TextStyleSpec(
          fontSize: baseFontSize(),
          color: preferredColor,
        ),
      ),
    );
  }

  static num? _foldMax(Object? pv, dynamic e) {
    num d = 0;
    if (e == null) {
      d = 0;
    } else if (e is HistorySeriesEntry) {
      if (e.data is num) {
        d = e.data;
      } else if (e.data == null) {
        d = 0;
      } else {
        throw Exception('invalid invalid HistorySeriesEntry data: got ${e.data}');
      }
    } else if (e is num) {
      d = e;
    } else {
      throw Exception('invalid fold next value: got $e');
    }
    if (pv == null) {
      return d;
    }
    if (pv is! num) {
      throw Exception(
          'invalid fold previous value: num or null expected but got $pv');
    }
    if (d > pv) {
      return d;
    } else {
      return pv;
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.read<InstantStatusProvider>().history;
    final now = DateTime.now();
    final histories = series()
        .map((e) => history.series(e.name, now, _span, e.path))
        .toList();
    final max = histories.fold(null, (previousValue, element) {
      final fv = element.data.fold(null, (pv, e) => _foldMax(pv, e));
      return _foldMax(previousValue, fv);
    });
    List<charts.ChartBehavior<DateTime>>? behaviors = [];
    if (_showLegend) {
      behaviors.add(charts.SeriesLegend(
          position: charts.BehaviorPosition.inside,
          showMeasures: true,
          insideJustification: charts.InsideJustification.topEnd));
    }
    final theme = Theme.of(context);
    final themeColor = theme.textTheme.bodyMedium?.color ??
        const Color.fromRGBO(128, 128, 128, 1);
    final preferredColor = charts.Color(
        r: themeColor.red,
        g: themeColor.green,
        b: themeColor.blue,
        a: themeColor.alpha);
    return charts.TimeSeriesChart(
      histories,
      animate: false,
      layoutConfig: _layout,
      behaviors: behaviors,
      primaryMeasureAxis: primaryAxisSpec(context, preferredColor, max),
      domainAxis: domainAxisSpec(context, preferredColor),
    );
  }

  charts.NumericAxisSpec? dynamicLabelAxisSpec(BuildContext context,
      charts.Color? preferredColor, charts.MeasureFormatter? formatter) {
    return charts.NumericAxisSpec(
      tickProviderSpec: const charts.BasicNumericTickProviderSpec(
        dataIsInWholeNumbers: false,
      ),
      tickFormatterSpec: charts.BasicNumericTickFormatterSpec(formatter),
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
