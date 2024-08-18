import 'dart:ui';

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
          final clusterState = checkResult.clusterFailure
              ? ClusterState.Fail
              : (issues.isEmpty ? ClusterState.Ok : ClusterState.Warn);
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
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: SizedBox(
                    width: 100,
                    child: ReadWriteRateChart(
                      // layout: charts.LayoutConfig(
                      //   topMarginSpec: charts.MarginSpec.fixedPixel(10),
                      //   bottomMarginSpec: charts.MarginSpec.fixedPixel(10),
                      //   leftMarginSpec: charts.MarginSpec.fixedPixel(5),
                      //   rightMarginSpec: charts.MarginSpec.fixedPixel(5),
                      // ),
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TricolorIndicator(clusterState),
                    checkResult.clientFatal ? const Text('Disconnected') : Text('${issues.length} issues'),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class ReadWriteRateChart extends TimeSeriesChartBase {
  ReadWriteRateChart(
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
  //   return charts.NumericAxisSpec(
  //     tickProviderSpec: const charts.BasicNumericTickProviderSpec(
  //         dataIsInWholeNumbers: false),
  //     tickFormatterSpec: charts.BasicNumericTickFormatterSpec((measure) => ''),
  //     renderSpec: charts.GridlineRendererSpec(
  //       lineStyle: charts.LineStyleSpec(color: preferredColor),
  //       labelStyle: charts.TextStyleSpec(
  //         fontSize: baseFontSize(),
  //         color: preferredColor,
  //       ),
  //     ),
  //   );
  // }

  // @override
  // charts.AxisSpec? domainAxisSpec(
  //     BuildContext context, charts.Color? preferredColor) {
  //   return charts.DateTimeAxisSpec(
  //     tickFormatterSpec:
  //         charts.BasicDateTimeTickFormatterSpec((datetime) => ''),
  //     renderSpec: charts.GridlineRendererSpec(
  //       lineStyle: charts.LineStyleSpec(color: preferredColor),
  //       labelStyle: charts.TextStyleSpec(
  //         fontSize: baseFontSize(),
  //         color: preferredColor,
  //       ),
  //     ),
  //   );
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

enum ClusterState { None, Ok, Warn, Fail }

// Tri-color indicator colors: from JIS Z 9103:2018(MOD)
const tciOKColor = Color(0xFF00B06B);
const tciNoticeColor = Color(0xFFF2E700);
const tciStopColor = Color(0xFFFF4B00);

class TricolorIndicator extends StatelessWidget {
  const TricolorIndicator(this.state,
      {Key? key, this.width = 30, this.height = 20})
      : super(key: key);
  final double width, height;
  final ClusterState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: state == ClusterState.Ok ? tciOKColor : Colors.grey,
            border: Border.all(color: Colors.black),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: state == ClusterState.Warn ? tciNoticeColor : Colors.grey,
            border: Border.all(color: Colors.black),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: state == ClusterState.Fail ? tciStopColor : Colors.grey,
            border: Border.all(color: Colors.black),
            shape: BoxShape.rectangle,
          ),
        ),
      ],
    );
  }
}
