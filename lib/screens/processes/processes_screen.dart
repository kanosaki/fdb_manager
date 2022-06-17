import 'dart:ffi';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:fdb_manager/agent_api.dart';
import 'package:fdb_manager/components/process/basic_charts.dart';
import 'package:fdb_manager/models/status.dart';
import 'package:fdb_manager/responsive.dart';
import 'package:fdb_manager/util/units.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

import '../../constants.dart';

class ProcessesScreen extends StatefulWidget {
  const ProcessesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends State<ProcessesScreen> {
  String? _selectedProcess = null;

  @override
  void initState() {
    super.initState();
    context.read<InstantStatusProvider>().updatePeriodic();
  }

  final rolesSymbolMap = {
    'coordinator': 'CO',
    'master': 'M',
    'cluster_controller': 'CC',
    'ratekeeper': 'RK',
    'data_distributor': 'DD',
    'proxy': 'P',
    'log': 'L',
    'storage': 'S',
    'resolver': 'RS',
  };

  String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  String aggregateRoles(List<dynamic> roles) {
    var roleSymbols = [];
    for (var e in roles) {
      final role = e['role'];
      final roleSymbol =
          rolesSymbolMap[role] ?? (throw Exception('unknown role $role'));
      roleSymbols.add(roleSymbol);
    }
    return roleSymbols.join(",");
  }

  Widget buildRowForProcess(String procId, dynamic data) {
    // data['cpu'] could be null (at just after cluster initialization?)
    if (data['cpu'] == null) {
      return Column(
        children: const [Text('Process details is not available')],
      );
    }
    final cpuUsage = data['cpu']['usage_cores'] as double;
    final memAvailable = data['memory']['used_bytes'] as int;
    final cells = <Widget>[
      Text(data['address']),
      Text(aggregateRoles(data['roles'])),
      Text(formatPercentage(cpuUsage)),
      Text(numToBytesStr(memAvailable)),
      Text(
          'Tx: ${(data['network']['megabits_sent']['hz'] as double).toStringAsFixed(2)}Mbps'),
      Text(
          'Rx: ${(data['network']['megabits_received']['hz'] as double).toStringAsFixed(2)}Mbps'),
    ];
    return Column(
      children: [
        InkWell(
            onTap: () {
              setState(() {
                _selectedProcess = procId;
              });
            },
            child: Row(children: cells)),
        Container(
          margin: const EdgeInsets.only(left: 10),
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (data['roles'] as List<dynamic>)
                .map((e) => buildProcessDetailsRole(e))
                .toList(),
          ),
        ),
      ],
    );
  }

  String _printDuration(Object secondsObj) {
    double seconds = 0.0;
    switch (secondsObj.runtimeType) {
      case int:
        seconds = (secondsObj as int).toDouble();
        break;
      case double:
        seconds = secondsObj as double;
        break;
      default:
        throw Exception('invalid duration type ${secondsObj.runtimeType}');
    }
    final duration = Duration(milliseconds: (seconds * 1000).round());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}h${twoDigitMinutes}m${twoDigitSeconds}s";
  }

  Widget buildProcessDetailsRole(dynamic roleObj) {
    switch (roleObj['role']) {
      case 'coordinator':
        return Text(roleObj['role']);
      default:
        return Text("${roleObj['role']} (${roleObj['id']})");
    }
  }

  Widget buildProcessDetails(dynamic processObj) {
    if (processObj == null) {
      return const Text('(invalid process id)');
    }
    final items = <Widget>[];
    items.add(Text('Version: ${processObj['version']}'));
    items.add(Text('Uptime: ${_printDuration(processObj['uptime_seconds'])}'));

    items.add(Text(
        'Loop busy: ${((processObj['run_loop_busy'] as double) * 100.0).toStringAsFixed(2)}%'));
    items.add(const Divider());
    for (var roleObj in (processObj['roles'] as List<dynamic>)) {
      items.add(Container(
        padding: const EdgeInsets.all(3.0),
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
        child: buildProcessDetailsRole(roleObj),
      ));
      items.add(const Divider());
    }
    return Column(
      children: items,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fut = context.watch<InstantStatusProvider>().statusInstant();

    return FutureBuilder<InstantStatus>(
      future: fut,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null) {
          return const Text('Loading...');
        }
        final raw = status.raw;

        final available = raw['client']['database_status']['available'] as bool;
        if (!available) {
          return const SafeArea(
            child: Text('Agent is not connected to cluster'),
          );
        }

        final cluster = raw['cluster'] as Map<String, dynamic>;
        final processes = cluster['processes'] as Map<String, dynamic>;

        final processTable = DataTable2(
          columns: const [
            DataColumn2(label: Text('Address')),
            DataColumn2(label: Text('Roles')),
            DataColumn2(label: Text('CPU')),
            DataColumn2(label: Text('Disk')),
            DataColumn2(label: Text('Net')),
          ],
          rows: processes.entries.map((e) {
            void onTap() {
              Navigator.pushNamed(context, '/process/details',
                  arguments: e.key);
            }

            const width = 200.0;
            const height = 50.0;

            return DataRow(cells: [
              DataCell(Text(e.value['address']), onTap: onTap),
              DataCell(Text(aggregateRoles(e.value['roles']))),
              DataCell(
                SizedBox(
                    height: height, width: width, child: CPUUsageChart(e.key)),
              ),
              DataCell(
                SizedBox(
                    height: height, width: width, child: DiskUsageChart(e.key)),
              ),
              DataCell(
                SizedBox(
                    height: height,
                    width: width,
                    child: NetworkUsageChart(e.key)),
              ),
            ]);
          }).toList(),
          horizontalMargin: 5,
          columnSpacing: 5,
          dataRowHeight: 50,
          headingRowHeight: 20,
          sortColumnIndex: 0,
        );
        var bodyRowItems = [
          Expanded(
              flex: _selectedProcess == null ? 1 : 2,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: processTable,
              )),
        ];
        if (_selectedProcess != null) {
          bodyRowItems.add(
            Expanded(
                flex: 1,
                child: Container(
                    child: buildProcessDetails(processes[_selectedProcess]))),
          );
        }
        // TODO: Use LayoutBuilder to make it responsive
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bodyRowItems,
              ),
            ],
          ),
        );
      },
    );
  }
}
