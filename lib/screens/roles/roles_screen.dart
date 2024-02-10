import 'package:fdb_manager/models/status.dart';
import 'package:fdb_manager/util/units.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../agent_api.dart';
import '../../data/status_history.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InstantStatusProvider>().updatePeriodic();
  }

  Widget buildRowForRole(StatusHistory history, InstantStatus status,
      String roleType, List<ProcessRoleInfo> pris) {
    Widget buildRoleLog() {
      return const Text('');
    }

    Widget buildRoleProxy() {
      return const Text('');
    }

    Widget buildRoleDefault() {
      return Column(
        children: pris.map((e) {
          final process = status.getProcessByID(e.processId)!;
          return Text(process.address);
        }).toList(),
      );
    }

    Widget buildRoleStorage() {
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
          final availableBytes = e.data['kvstore_available_bytes'];
          final availableBytesStr = availableBytes != null ? numToBytesStr(availableBytes) : 'N/A';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${process.address} available=$availableBytesStr'),
              Row(children: [
                SizedBox(width: 200, height: 70, child: queryCountChart),
                SizedBox(width: 200, height: 70, child: latencyChart),
              ]),
            ],
          );
        }).toList(),
      );
    }

    final builders = {
      'coordinator': buildRoleDefault,
      'ratekeeper': buildRoleDefault,
      'master': buildRoleDefault,
      'data_distributor': buildRoleDefault,
      'cluster_controller': buildRoleDefault,
      'resolver': buildRoleDefault,
      'log': buildRoleLog,
      'proxy': buildRoleProxy,
      'storage': buildRoleStorage,
    };
    final builder = builders[roleType];
    if (builder == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(roleType)],
      );
    }
    final content = builder();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(roleType),
        content,
      ],
    );
  }

  // TODO: dupe code, refactor
  Widget buildClusterHeader(Map<String, dynamic> cluster) {
    final ccTimestamp = cluster['cluster_controller_timestamp'] as int;
    return Row(children: [
      Text(DateTime.fromMillisecondsSinceEpoch(ccTimestamp * 1000, isUtc: true)
          .toLocal()
          .toString())
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final history = context.read<InstantStatusProvider>().history;
    final fut = context.watch<InstantStatusProvider>().statusInstant();
    return FutureBuilder<InstantStatus>(
        future: fut,
        builder: (context, snapshot) {
          final status = snapshot.data;
          if (status == null) {
            return const Text('Loading...');
          }
          final raw = status.raw;
          final available =
              raw['client']['database_status']['available'] as bool;
          if (!available) {
            return const SafeArea(
              child: Text('Agent is not connected to cluster'),
            );
          }

          final cluster = raw['cluster'] as Map<String, dynamic>;
          final roles = status.roles().entries.toList();

          final rolesList = ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final entry = roles.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    buildRowForRole(history, status, entry.key, entry.value),
                  ],
                );
              });

          return Column(
            children: [
              buildClusterHeader(cluster),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: rolesList),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
