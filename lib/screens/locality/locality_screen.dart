import 'package:fdb_manager/components/metric_bar.dart';
import 'package:fdb_manager/util/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../agent_api.dart';
import '../../components/role.dart';
import '../../models/status.dart';

class LocalityScreen extends StatefulWidget {
  const LocalityScreen({Key? key}) : super(key: key);

  @override
  State<LocalityScreen> createState() => _LocalityScreenState();
}

class _LocalityScreenState extends State<LocalityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InstantStatusProvider>().updatePeriodic();
  }

  Widget processWidget(
      InstantStatus status, ProcessByLocality locality, ProcessInfo process) {
    final memUsage = process.memory.usedBytes.toDouble() / process.memory.availableBytes;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(process.address),
          RoleTag(process.roles),
          SizedBox(
              height: 20,
              child: MetricBar(
                  ratio: process.cpuUsageCores,
                  text:
                      'CPU ${(process.cpuUsageCores * 100).toStringAsFixed(0)}%')),
          SizedBox(
              height: 20,
              child: MetricBar(
                  ratio: memUsage,
                  text:
                  'MEM ${(memUsage * 100).toStringAsFixed(0)}%')),
          SizedBox(
              height: 20,
              child: MetricBar(
                  ratio: process.disk.busy,
                  text:
                      'Disk busy ${(process.disk.busy * 100).toStringAsFixed(0)}%')),
          Text('Tx:${process.network.mbpsSent.toStringAsFixed(1)}Mbps'),
          Text('Rx:${process.network.mbpsReceived.toStringAsFixed(1)}Mbps'),
        ],
      ),
    );
  }

  Widget machineWidget(InstantStatus status, ProcessByLocality locality,
      String machineID, List<ProcessInfo> processes) {
    final machine = status.getMachineByID(machineID);
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Container(
        margin: const EdgeInsets.all(5),
        key: Key(machineID),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('M: $machineID'),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 160,
                child: GridView.extent(
                    // physics: const NeverScrollableScrollPhysics(),
                    maxCrossAxisExtent: 160,
                    children: processes
                        .map((e) => processWidget(status, locality, e))
                        .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget zoneWidget(InstantStatus status, ProcessByLocality locality,
      String zoneID, Map<String, List<ProcessInfo>> zone) {
    final machines = zone.entries.toList();
    const machinesPerRow = 2;
    final rowModels = unflattenWithPadNull(machines, machinesPerRow);
    final children = <Widget>[
      Text(zoneID),
      ...rowModels.map((e) => Row(
          children: e
              .map((m) => Expanded(
                  child: m == null
                      ? Container()
                      : machineWidget(status, locality, m.key, m.value)))
              .toList()))
    ];
    return Container(
      key: Key(zoneID),
      // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
          final locality = status.locality();
          if (locality.isRegionConfigured) {
            return const Text('TODO');
          }
          final zones = locality.zones();

          return Column(
            children: [
              Expanded(
                child: ListView(
                    children: zones.entries
                        .map(
                            (e) => zoneWidget(status, locality, e.key, e.value))
                        .toList()),
              ),
            ],
          );
        });
  }
}
