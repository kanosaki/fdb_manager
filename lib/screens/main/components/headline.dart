import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fdb_manager/components/metric_bar.dart';
import 'package:fdb_manager/data/status_history.dart';
import 'package:fdb_manager/models/link.dart';
import 'package:fdb_manager/util/units.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../agent_api.dart';
import '../../../components/charts/time_series.dart';
import '../../../data/status_checker.dart';
import '../../../models/status.dart';

class Headline extends StatefulWidget {
  const Headline({Key? key}) : super(key: key);

  @override
  State<Headline> createState() => _HeadlineState();
}

class _HeadlineState extends State<Headline> {
  @override
  Widget build(BuildContext context) {
    final fut = context.watch<InstantStatusProvider>().statusInstant();
    final history = context.read<InstantStatusProvider>().history;

    return FutureBuilder<InstantStatus>(
        future: fut,
        builder: (context, snapshot) {
          final status = snapshot.data;
          if (status == null) {
            return const Text('Loading...');
          }

          final validator = StatusValidator(const StatusValidatorConfig());
          final checkResult = validator.check(status, history);
          if (checkResult.clientFatal) {
            // TODO: show detailed errors
            return const Text('Agent is not connected to cluster');
          }
          final theme = Theme.of(context);
          final issues = checkResult.issues;
          final cluster = status.raw['cluster'];
          final readBytes = cluster['workload']['bytes']['read']['hz'];
          final writeBytes = cluster['workload']['bytes']['written']['hz'];

          final metricFontStyle = theme.textTheme.bodySmall?.copyWith(
            fontFamily: GoogleFonts.robotoMono().fontFamily,
          );

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: SizedBox(
                    width: 100,
                    child: ReadWriteRateChart(
                      layout: charts.LayoutConfig(
                        topMarginSpec: charts.MarginSpec.fixedPixel(5),
                        bottomMarginSpec: charts.MarginSpec.fixedPixel(5),
                        leftMarginSpec: charts.MarginSpec.fixedPixel(5),
                        rightMarginSpec: charts.MarginSpec.fixedPixel(5),
                      ),
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'R: ${numToBytesStr(readBytes, underPointDigits: 1, padSuffix: true).padLeft(10)}/s',
                        style: metricFontStyle),
                    Text(
                        'W: ${numToBytesStr(writeBytes, underPointDigits: 1, padSuffix: true).padLeft(10)}/s',
                        style: metricFontStyle),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Text('${issues.length}issues'),
              ),
            ],
          );
        });
  }
}

class ReadWriteRateChart extends TimeSeriesChartBase {
  ReadWriteRateChart(
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
          dataIsInWholeNumbers: false),
      tickFormatterSpec: charts.BasicNumericTickFormatterSpec((measure) => ''),
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
  charts.AxisSpec? domainAxisSpec(
      BuildContext context, charts.Color? preferredColor) {
    return charts.DateTimeAxisSpec(
      tickFormatterSpec:
          charts.BasicDateTimeTickFormatterSpec((datetime) => ''),
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
