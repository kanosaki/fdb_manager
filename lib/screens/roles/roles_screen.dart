import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../agent_api.dart';

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

  Widget buildRoleLog(InstantStatus status,List<ProcessRoleInfo> pris) {
    return const Text('');
  }

  Widget buildRoleProxy(InstantStatus status,List<ProcessRoleInfo> pris) {
    return const Text('');
  }

  Widget buildRoleStorage(InstantStatus status,List<ProcessRoleInfo> pris) {
    return const Text('');
  }

  Widget buildRoleDefault(InstantStatus status, List<ProcessRoleInfo> pris) {
    return Column(
      children: pris.map((e) {
        final process = status.getProcessByID(e.processId)!;
        return Text(process.address);
      }).toList(),
    );
  }

  Widget buildRowForRole(InstantStatus status, String roleType, List<ProcessRoleInfo> pris) {
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
    final content = builder(status, pris);
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
                    buildRowForRole(status, entry.key, entry.value),
                  ],
                );
              });

          return SafeArea(
            child: Column(
              children: [
                buildClusterHeader(cluster),
                Expanded(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: rolesList),
                  ],
                )),
              ],
            ),
          );
        });
  }
}
