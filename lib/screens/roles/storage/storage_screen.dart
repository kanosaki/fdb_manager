import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../agent_api.dart';
import '../../../data/status_history.dart';
import '../../../models/status.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../../util/units.dart';

class StoragesScreen extends StatefulWidget {
  const StoragesScreen({Key? key}) : super(key: key);

  @override
  State<StoragesScreen> createState() => _StoragesScreenState();
}

class _StoragesScreenState extends State<StoragesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InstantStatusProvider>().updatePeriodic();
  }

  Widget buildRoleStorage(StatusHistory history, InstantStatus status,
      String roleType, List<ProcessRoleInfo> pris) {
    final now = DateTime.now();
    const length = Duration(minutes: 5);
    final layout = charts.LayoutConfig(
      topMarginSpec: charts.MarginSpec.fixedPixel(10),
      bottomMarginSpec: charts.MarginSpec.fixedPixel(15),
      leftMarginSpec: charts.MarginSpec.fromPixel(minPixel: 20, maxPixel: 50),
      rightMarginSpec: charts.MarginSpec.fixedPixel(10),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pris.map((e) {
        var keysQueriedSeries = history.series('id', now, length, [
          'cluster',
          'processes',
          e.processId,
          'roles',
          'storage',
          'keys_queried',
          'hz'
        ]);
        var mutationsSeries = history.series('id', now, length, [
          'cluster',
          'processes',
          e.processId,
          'roles',
          'storage',
          'mutations',
          'hz'
        ]);
        var latencyMedianSeries = history.series('id', now, length, [
          'cluster',
          'processes',
          e.processId,
          'roles',
          'storage',
          'read_latency_statistics',
          'median'
        ]);
        var latency99Series = history.series('id', now, length, [
          'cluster',
          'processes',
          e.processId,
          'roles',
          'storage',
          'read_latency_statistics',
          'p99'
        ]);
        var queryCountChart = charts.TimeSeriesChart(
            [keysQueriedSeries, mutationsSeries],
            animate: false, layoutConfig: layout);
        var latencyChart = charts.TimeSeriesChart(
          [latencyMedianSeries, latency99Series],
          animate: false,
          layoutConfig: layout,
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                dataIsInWholeNumbers: false),
            tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                    (measure) => measure == null ? '' : '${measure * 1000}ms'),
          ),
        );
        final process = status.getProcessByID(e.processId)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${process.address} available=${numToBytesStr(e.data['kvstore_available_bytes'])}'),
            Row(children: [
              SizedBox(child: queryCountChart, width: 200, height: 70),
              SizedBox(child: latencyChart, width: 200, height: 70),
            ]),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fut = context.watch<InstantStatusProvider>().statusInstant();

    return FutureBuilder<InstantStatus>(
      future: fut,
      builder: (context, snapshot) {
        return Container();
      },
    );
  }
}
