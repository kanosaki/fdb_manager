import 'dart:ffi';
import 'dart:math';

import 'package:fdb_manager/agent_api.dart';
import 'package:fdb_manager/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String intToBytesStr(int size) {
    var tmpSize = size;
    const suffixes = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'EiB'];
    var i = 0;
    for (; i < suffixes.length; i++) {
      if (tmpSize < 1024) {
        break;
      }
      tmpSize ~/= 1024;
    }
    final fpSize = size / pow(1024, i);
    return '${fpSize.toStringAsPrecision(4)}${suffixes[i]}';
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
      Text(intToBytesStr(memAvailable)),
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

  Widget buildClusterHeader(Map<String, dynamic> cluster) {
    final ccTimestamp = cluster['cluster_controller_timestamp'] as int;
    return Row(children: [
      Text(DateTime.fromMillisecondsSinceEpoch(ccTimestamp * 1000, isUtc: true)
          .toLocal()
          .toString())
    ]);
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

        final available =
            raw['client']['database_status']['available'] as bool;
        if (!available) {
          return const SafeArea(
            child: Text('Agent is not connected to cluster'),
          );
        }

        final cluster = raw['cluster'] as Map<String, dynamic>;
        final processes = cluster['processes'] as Map<String, dynamic>;

        final procEntries = processes.entries.toList();
        final processList = ListView.builder(
            itemCount: procEntries.length,
            itemBuilder: (context, index) {
              final entry = procEntries.elementAt(index);
              return buildRowForProcess(entry.key, entry.value);
            });
        var bodyRowItems = [
          Expanded(
              flex: _selectedProcess == null ? 1 : 2,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: processList,
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
        return SafeArea(
          child: Column(
            children: [
              buildClusterHeader(cluster),
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bodyRowItems,
              )),
            ],
          ),
        );
      },
    );
  }
}
