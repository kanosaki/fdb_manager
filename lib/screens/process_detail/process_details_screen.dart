import 'package:fdb_manager/components/process/basic_charts.dart';
import 'package:fdb_manager/models/status.dart';
import 'package:fdb_manager/screens/process_detail/components/role_proxy.dart';
import 'package:fdb_manager/screens/process_detail/components/role_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
          List<Widget> children = [
            Text('CPU', style: theme.textTheme.subtitle1),
            SizedBox(
                height: 100,
                child: CPUUsageChart(
                  processId,
                  showLegend: true,
                )),
            Text('Disk', style: theme.textTheme.subtitle1),
            SizedBox(
                height: 100,
                child: DiskUsageChart(
                  processId,
                  showLegend: true,
                )),
            Text('Network', style: theme.textTheme.subtitle1),
            SizedBox(
                height: 100,
                child: NetworkUsageChart(
                  processId,
                  showLegend: true,
                )),
          ];
          final roles = status.getRoles(processId) ?? [];
          for (var role in roles) {
            switch (role.type) {
              case 'storage':
                children.add(Text(
                  'Storage',
                  style: theme.textTheme.subtitle1,
                ));
                children.add(StorageRole(role));
                break;
              case 'log':
                children.add(Text(
                  'Log',
                  style: theme.textTheme.subtitle1,
                ));
                children.add(LogRole(role));
                break;
              case 'proxy':
                children.add(Text(
                  'Proxy',
                  style: theme.textTheme.subtitle1,
                ));
                children.add(ProxyRole(processId, role));
                break;
            }
          }
          final sc = ScrollController();

          return Expanded(child: Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Address: ${process.address}'),
                        Text('Excluded: ${process.excluded}'),
                        Text('Messages: ${process.messages.join(",")}'),
                        Text('Version: ${process.version}'),
                        Text('Uptime: ${process.uptime}'),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
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
          ));
        });
  }
}
