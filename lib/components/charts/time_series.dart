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
      BuildContext context, charts.Color? preferredColor) {
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

  @override
  Widget build(BuildContext context) {
    final history = context.read<InstantStatusProvider>().history;
    final now = DateTime.now();
    final histories = series()
        .map((e) => history.series(e.name, now, _span, e.path))
        .toList();
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
      primaryMeasureAxis: primaryAxisSpec(context, preferredColor),
      domainAxis: domainAxisSpec(context, preferredColor),
    );
  }
}
