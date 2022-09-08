import 'dart:developer';
import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:fdb_manager/agent_api.dart';
import 'package:fdb_manager/components/process/basic_charts.dart';
import 'package:fdb_manager/components/role.dart';
import 'package:fdb_manager/models/status.dart';
import 'package:fdb_manager/responsive.dart';
import 'package:fdb_manager/util/units.dart';
import 'package:fl_chart/fl_chart.dart';
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
  ProcessGroupBy groupBy = ProcessGroupBy.None;
  MetricStyle metricStyle = MetricStyle.Chart;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<InstantStatusProvider>().updatePeriodic();
  }

  String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  Widget aggregateRoles(List<dynamic> roles) {
    final rs = roles.map((e) => e['role'] as String).toList();
    return RoleTag(rs);
  }

  Widget _processesTable(Map<String, dynamic> processes) {
    final processTable = DataTable2(
      columns: const [
        DataColumn2(label: Text('Address')),
        DataColumn2(label: Text('Roles')),
        DataColumn2(label: Text('CPU')),
        DataColumn2(label: Text('Mem')),
        DataColumn2(label: Text('Disk')),
        DataColumn2(label: Text('Net')),
      ],
      rows: processes.entries.map((e) {
        void onTap() {
          Navigator.pushNamed(context, '/process/details', arguments: e.key);
        }

        const width = 200.0;
        const height = 50.0;

        return DataRow(cells: [
          DataCell(Text(e.value['address']), onTap: onTap),
          DataCell(aggregateRoles(e.value['roles'])),
          DataCell(
            SizedBox(height: height, width: width, child: CPUUsageChart(e.key)),
          ),
          DataCell(
            SizedBox(
                height: height, width: width, child: MemoryUsageChart(e.key)),
          ),
          DataCell(
            SizedBox(
                height: height, width: width, child: DiskUsageChart(e.key)),
          ),
          DataCell(
            SizedBox(
                height: height, width: width, child: NetworkUsageChart(e.key)),
          ),
        ]);
      }).toList(),
      horizontalMargin: 5,
      columnSpacing: 5,
      dataRowHeight: 50,
      headingRowHeight: 20,
      sortColumnIndex: 0,
    );
    return processTable;
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
        final processTable = _processesTable(processes);

        var bodyRowItems = [
          Expanded(
              child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: processTable,
          )),
        ];
        // TODO: Use LayoutBuilder to make it responsive
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: SizedBox(
                height: 25,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicWidth(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 100,
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    hintText: 'Filter...',
                                  ),
                                  onChanged: (s) {
                                    setState(() {
                                      searchQuery = s;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            DropdownButton<ProcessGroupBy>(
                                isDense: true,
                                items: ProcessGroupBy.values
                                    .map((e) => DropdownMenuItem(
                                        child: Text(e.name), value: e))
                                    .toList(),
                                value: groupBy,
                                onChanged: (e) {
                                  setState(() {
                                    groupBy = e!;
                                  });
                                }),
                            DropdownButton<MetricStyle>(
                                isDense: true,
                                items: MetricStyle.values
                                    .map((e) => DropdownMenuItem(
                                        child: Text(e.name), value: e))
                                    .toList(),
                                value: metricStyle,
                                onChanged: (e) {
                                  setState(() {
                                    metricStyle = e!;
                                  });
                                }),
                          ]),
                    ]),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bodyRowItems,
            ),
          ],
        );
      },
    );
  }
}

enum ProcessGroupBy {
  None,
  ByRole,
  ByMachine,
}

enum MetricStyle {
  Chart,
  Gauge,
}
