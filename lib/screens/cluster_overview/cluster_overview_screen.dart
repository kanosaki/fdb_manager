import 'package:fdb_manager/components/charts/cluster_scope.dart';
import 'package:fdb_manager/components/metric_bar.dart';
import 'package:fdb_manager/data/status_history.dart';
import 'package:fdb_manager/models/link.dart';
import 'package:fdb_manager/util/units.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../agent_api.dart';
import '../../../data/status_checker.dart';
import '../../../models/status.dart';

class ClusterOverview extends StatefulWidget {
  const ClusterOverview({Key? key}) : super(key: key);

  @override
  State<ClusterOverview> createState() => _ClusterOverviewState();
}

class _ClusterOverviewState extends State<ClusterOverview> {
  Widget buildPermanentStatuses(Map<String, dynamic> cluster) {
    final ccTimestamp = cluster['cluster_controller_timestamp'] as int;

    final avgPartitionSize =
        cluster['data']['average_partition_size_bytes'] as num?;
    final partitionCount = cluster['data']['partitions_count'] as num?;
    final totalKVSize = cluster['data']['total_kv_size_bytes'] as num?;
    final totalDiskUsed = cluster['data']['total_disk_used_bytes'] as num?;
    // final leastTLDiskRemaining = cluster['data']['least_operating_space_bytes_log_server'] as num?;
    // final leastSSDiskRemaining = cluster['data']['least_operating_space_bytes_storage_server'] as num?;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateTime.fromMillisecondsSinceEpoch(ccTimestamp * 1000,
                    isUtc: true)
                .toLocal()
                .toString()),
          ],
        ),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       child: Padding(padding: EdgeInsets.all(4), child: SizedBox(height: 20, child: MetricBar(
        //         text: 'TotalKV: ${numToBytesStr(totalKVSize ?? 0)} / TotalDisk: ${numToBytesStr(totalDiskUsed ?? 0)}',
        //         ratio: ,
        //       ))),
        //     ),
        //   ],
        // ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${intToSuffixedStr(partitionCount ?? 0)}partitions x ${numToBytesStr(avgPartitionSize ?? 0)}'),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'TotalKV: ${numToBytesStr(totalKVSize ?? 0)} / TotalDisk: ${numToBytesStr(totalDiskUsed ?? 0)}'),
          ],
        ),
        const Divider(),
        Row(children: [
          Expanded(
            flex: 1,
            child: Column(children: [
              Text('Latency Probe', style: theme.textTheme.subtitle1),
              SizedBox(height: 100, child: LatencyProbeChart(showLegend: true)),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Column(children: [
              Text('Read/Write rate', style: theme.textTheme.subtitle1),
              SizedBox(
                  height: 100, child: ReadWriteRateChart(showLegend: true)),
            ]),
          ),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Column(children: [
              Text('Transaction', style: theme.textTheme.subtitle1),
              SizedBox(
                  height: 100, child: TransactionRateChart(showLegend: true)),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Column(children: [
              Text('QoS', style: theme.textTheme.subtitle1),
              SizedBox(height: 100, child: QoSStateChart(showLegend: true)),
            ]),
          ),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Column(children: [
              Text('DC lag', style: theme.textTheme.subtitle1),
              SizedBox(height: 100, child: LagChart(showLegend: true)),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Column(children: [
              Text('Moving data', style: theme.textTheme.subtitle1),
              SizedBox(height: 100, child: MovingDataChart(showLegend: true)),
            ]),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fut = context.watch<InstantStatusProvider>().statusInstant();
    final history = context.read<InstantStatusProvider>().history;

    final sc = ScrollController();

    return FutureBuilder<InstantStatus>(
        future: fut,
        builder: (context, snapshot) {
          final status = snapshot.data;
          if (status == null) {
            return const Text('Loading...');
          }

          final validator = StatusValidator(const StatusValidatorConfig());
          final checkResult = validator.check(status, history);
          if (checkResult.clientFatal) {
            // TODO: show detailed errors
            return const Text('Agent is not connected to cluster');
          }
          final issues = checkResult.issues;
          final permanentStatus = buildPermanentStatuses(status.raw['cluster']);
          if (issues.isEmpty) {
            issues.add(MessageIssue('no-issue', IssueSeverity.info,
                RichString.build(['No issue'])));
          }
          return Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: permanentStatus),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            controller: sc,
                            itemCount: issues.length,
                            itemBuilder: (context, index) {
                              return RichText(
                                  text: buildIssueLine(
                                      context, status, history, issues[index]));
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  InlineSpan buildIssueLine(BuildContext context, InstantStatus status,
      StatusHistory history, Issue issue) {
    if (issue is MessageIssue) {
      return TextSpan(
          children: issue.message.elements
              .map((e) => buildRichStringElement(
                  context, status, history, e, issue.severity))
              .toList());
    } else if (issue is MetricIssue) {
      return TextSpan(
          children: issue.note.elements
              .map((e) => buildRichStringElement(
                  context, status, history, e, issue.severity))
              .toList());
    } else {
      throw Exception('unsupported issue type: ${issue.runtimeType}');
    }
  }

  InlineSpan buildRichStringElement(BuildContext context, InstantStatus status,
      StatusHistory history, RichStringElement e, IssueSeverity severity) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall;
    TextStyle style = baseStyle ?? const TextStyle();
    // Use theme?
    switch (severity) {
      case IssueSeverity.clientFatal:
        style = style.copyWith(
            color: const Color.fromRGBO(255, 128, 128, 1),
            fontWeight: FontWeight.bold,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 1));
        break;
      case IssueSeverity.fatal:
        style = style.copyWith(
            color: const Color.fromRGBO(255, 128, 128, 1),
            fontWeight: FontWeight.bold,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 1));
        break;
      case IssueSeverity.error:
        const color = Color.fromRGBO(126, 13, 13, 1.0);
        style = style.copyWith(
          color: color,
          decorationColor: color,
          decorationThickness: 0.5,
          decoration: TextDecoration.underline,
        );
        break;
      case IssueSeverity.warning:
        style = style.copyWith(color: const Color.fromRGBO(155, 99, 43, 1.0));
        break;
      case IssueSeverity.note:
        style = style.copyWith(color: const Color.fromRGBO(16, 121, 16, 1.0));
        break;
      default:
      // case of IssueSeverity.info
    }
    if (e is NullSpan) {
      return const TextSpan(text: '(null)');
    } else if (e is StringSpan) {
      return TextSpan(text: e.s, style: style);
    } else if (e is ProcessLink) {
      final addr = status.getProcessByID(e.processID)?.address;
      return TextSpan(
        text: addr ?? e.processID,
        style: style,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.pushNamed(context, '/process/details',
                arguments: e.processID);
          },
      );
    } else if (e is ProcessAddressLink) {
      return TextSpan(text: e.address, style: style);
    } else if (e is MachineLink) {
      final addr = status.getMachineByID(e.machineID)?.address;
      return TextSpan(text: addr ?? e.machineID, style: style);
    } else if (e is DatacenterLink) {
      return TextSpan(text: e.name, style: style);
    } else {
      throw Exception('unsupported RichStringElement type: ${e.runtimeType}');
    }
  }
}
