import 'package:fdb_manager/components/metric_bar.dart';
import 'package:fdb_manager/util/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../agent_api.dart';
import '../../components/role.dart';
import '../../models/status.dart';

class LocalityScreen extends StatefulWidget {
  const LocalityScreen({Key? key}) : super(key: key);

  @override
  State<LocalityScreen> createState() => _LocalityScreenState();
}

const String processPerMachineKey = 'ui.locality_screen.machines_per_row';

class _LocalityScreenState extends State<LocalityScreen> {
  int machinesPerRow = 2;

  @override
  void initState() {
    super.initState();
    context.read<InstantStatusProvider>().updatePeriodic();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        machinesPerRow = prefs.getInt(processPerMachineKey) ?? 2;
      });
    });
  }

  Widget processWidget(
      InstantStatus status, ProcessByLocality locality, ProcessInfo process) {
    final memUsage = (process.memory.rssBytes).toDouble() /
        process.memory.limitBytes.toDouble();
    final excluded = process.excluded;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: excluded ? Colors.grey : null,
      ),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(2),
      child: SizedBox(
        width: 200,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(process.address),
              RoleTag(process.roleNames, grouped: false, darkened: excluded),
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
                      text: 'MEM ${(memUsage * 100).toStringAsFixed(0)}%')),
              SizedBox(
                  height: 20,
                  child: MetricBar(
                      ratio: process.disk.busy.toDouble(),
                      text:
                          'Disk busy ${(process.disk.busy * 100).toStringAsFixed(0)}%')),
              Text('Tx:${process.network.mbpsSent.toStringAsFixed(1)}Mbps'),
              Text('Rx:${process.network.mbpsReceived.toStringAsFixed(1)}Mbps'),
            ],
          ),
        ),
      ),
    );
  }

  Widget machineWidget(InstantStatus status, ProcessByLocality locality,
      String machineID, List<ProcessInfo> processes) {
    final machine = status.getMachineByID(machineID);
    final exclusions = status.exclusions;
    final machineExcluded = exclusions.isExcludedByMachineID(machineID);
    final excluded = machine?.excluded ?? machineExcluded;
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: excluded ? Colors.grey : null,
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        key: Key(machineID),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (excluded) const Icon(Icons.block, color: Colors.red),
                Text('M: $machineID'),
              ],
            ),
            Wrap(
              children: processes
                  .map((e) => processWidget(status, locality, e))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget zoneWidget(InstantStatus status, ProcessByLocality locality,
      String zoneID, Map<String, List<ProcessInfo>> zone) {
    final machines = zone.entries.toList();
    final rowModels = unflattenWithPadNull(machines, machinesPerRow);
    final excluded = status.exclusions.isExcludedByZoneID(zoneID);
    final children = <Widget>[
      ...rowModels.map((e) => Row(
          children: e
              .map((m) => Expanded(
                  child: m == null
                      ? Container()
                      : machineWidget(status, locality, m.key, m.value)))
              .toList()))
    ];
    return Container(
      margin: const EdgeInsets.all(5),
      key: Key(zoneID),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: excluded ? Colors.grey : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (excluded) const Icon(Icons.block, color: Colors.red),
              Text(zoneID),
              // show action menu
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'exclude',
                    child: Text('Exclude'),
                  ),
                  const PopupMenuItem(
                    value: 'include',
                    child: Text('Include'),
                  ),
                ],
                onSelected: (value) {
                  print('selected $value');
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
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

          return Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                // configurator
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      // processes per machine dropdown
                      const Text('Processes per machine: '),
                      DropdownButton<int>(
                        value: machinesPerRow,
                        items: [1, 2, 3, 4, 5]
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text("$e")))
                            .toList(),
                        onChanged: (value) {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setInt(processPerMachineKey, value!);
                          });
                          setState(() {
                            machinesPerRow = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // main list
                Expanded(
                  child: ListView(
                      children: zones.entries
                          .map(
                              (e) => zoneWidget(status, locality, e.key, e.value))
                          .toList()),
                ),
              ],
            ),
          );
        });
  }
}
