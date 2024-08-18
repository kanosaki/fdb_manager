import 'package:fdb_manager/components/process/basic_charts.dart';
import 'package:fdb_manager/models/status.dart';
import 'package:fdb_manager/screens/process_detail/components/role_proxy.dart';
import 'package:fdb_manager/screens/process_detail/components/role_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../agent_api.dart';
import 'components/role_log.dart';

class ProcessDetailsScreen extends StatefulWidget {
  const ProcessDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProcessDetailsScreenState();
}

class _ProcessDetailsScreenState extends State<ProcessDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final processId = ModalRoute.of(context)!.settings.arguments as String;
    final fut = context.watch<InstantStatusProvider>().statusInstant();
    return FutureBuilder<InstantStatus>(
        future: fut,
        builder: (context, snapshot) {
          final status = snapshot.data;
          if (status == null) {
            return const Text('Loading...');
          }
          final process = status.getProcessByID(processId);
          if (process == null) {
            return Text('Error: process $processId not found');
          }
          final theme = Theme.of(context);
          List<Widget> coreMetrics = [
            Text('Address: ${process.address}'),
            Text('Excluded: ${process.excluded}'),
            Text('Messages: ${process.messages.join(",")}'),
            Text('Version: ${process.version}'),
            Text('Uptime: ${process.uptime}'),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    Text('CPU', style: theme.textTheme.titleSmall),
                    SizedBox(
                        height: 80,
                        child: CPUUsageChart(
                          processId,
                          showLegend: true,
                        )),
                  ])),
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    Text('Memory', style: theme.textTheme.titleSmall),
                    SizedBox(
                        height: 80,
                        child: MemoryUsageChart(
                          processId,
                          showLegend: true,
                        )),
                  ])),
            ]),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    Text('Disk', style: theme.textTheme.titleSmall),
                    SizedBox(
                        height: 80,
                        child: DiskUsageChart(
                          processId,
                          showLegend: true,
                        )),
                  ])),
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    Text('Network', style: theme.textTheme.titleSmall),
                    SizedBox(
                        height: 80,
                        child: NetworkUsageChart(
                          processId,
                          showLegend: true,
                        )),
                  ])),
            ]),
          ];
          List<Widget> children = [];
          final roles = status.getRoles(processId) ?? [];
          for (var role in roles) {
            switch (role.type) {
              case 'storage':
                children.add(Text(
                  'Storage',
                  style: theme.textTheme.titleSmall,
                ));
                children.add(StorageRole(role));
                break;
              case 'log':
                children.add(Text(
                  'Log',
                  style: theme.textTheme.titleSmall,
                ));
                children.add(LogRole(role));
                break;
              case 'proxy':
                children.add(Text(
                  'Proxy',
                  style: theme.textTheme.titleSmall,
                ));
                children.add(ProxyRole(processId, role));
                break;
            }
          }
          final sc = ScrollController();

          return Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: coreMetrics,
                    )),
                Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        return children[index];
                      },
                      controller: sc,
                    )),
              ],
            ),
          );
        });
  }
}
