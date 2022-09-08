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
  Widget processWidget(
      InstantStatus status, ProcessByLocality locality, ProcessInfo process) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(2),
      child: Column(
        children: [
          Text(process.address),
          RoleTag(process.roles),
        ],
      ),
    );
  }

  Widget machineWidget(InstantStatus status, ProcessByLocality locality,
      String machineID, List<ProcessInfo> processes) {
    final procs = processes + processes + processes + processes;
    return SizedBox(
      height: 180,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Container(
          margin: const EdgeInsets.all(5),
          key: Key(machineID),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('M: $machineID'),
                  ],
                ),
              ),
              Expanded(
                child: GridView.extent(
                    physics: const NeverScrollableScrollPhysics(),
                    maxCrossAxisExtent: 200,
                    children: procs
                        .map((e) => processWidget(status, locality, e))
                        .toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget zoneWidget(InstantStatus status, ProcessByLocality locality,
      String zoneID, Map<String, List<ProcessInfo>> zone) {
    final machines =
        zone.entries.toList() + zone.entries.toList() + zone.entries.toList();
    const machinesPerRow = 2;
    final rowModels = unflatten(machines, machinesPerRow);
    final children = <Widget>[
      Text(zoneID),
      ...rowModels.map((e) => Expanded(
        child: Row(
            children: e
                .map((m) => FractionallySizedBox(
                    widthFactor: 1 / machinesPerRow,
                    child: machineWidget(status, locality, m.key, m.value)))
                .toList()),
      ))
    ];
    return Container(
      key: Key(zoneID),
      // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
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

          return Expanded(
            child: Column(
              children: [
                const Text('header'),
                Expanded(
                  child: ListView(
                      children: zones.entries
                          .map((e) =>
                              Expanded(child: zoneWidget(status, locality, e.key, e.value)))
                          .toList()),
                ),
              ],
            ),
          );
        });
  }
}
