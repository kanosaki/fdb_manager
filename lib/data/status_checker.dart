import 'package:fdb_manager/data/status_history.dart';
import 'package:fdb_manager/models/status.dart';
import 'package:fdb_manager/models/link.dart';
import 'package:flutter/material.dart';

enum IssueSeverity {
  // clientFatal denotes InstantStatus was not fetched correctly and validation is not working at all.
  clientFatal,
  // fatal denotes cluster is not working, or cluster nodes which the client connecting is not working
  fatal,
  // error denotes cluster is working, but some functionality is degraded.
  error,
  // warning denotes cluster is working completely, but some data show signs of failure.
  warning,
  // note denotes cluster is working completely. but it suggests items you should check
  note,
  // info is just information.
  info,
}

const _rs = RichString.build;

RichString _srs(String message) {
  return RichString([StringSpan(message)]);
}

abstract class Issue {
  const Issue(this.name, this.severity);

  final String name;

  final IssueSeverity severity;
}

class MessageIssue extends Issue {
  const MessageIssue(String id, IssueSeverity severity, this.message)
      : super(id, severity);

  final RichString message;
}

class MetricIssue extends Issue {
  const MetricIssue(String name, IssueSeverity severity,
      {required this.current,
      required this.thresh,
      this.shouldNotAbove = true,
      this.note = const RichString([]),
      this.nextETA,
      this.nextThresh,
      this.nextSeverity})
      : super(name, severity);

  final double current;
  final double thresh;
  final bool shouldNotAbove;

  final double? nextThresh;

  final IssueSeverity? nextSeverity;

  final DateTime? nextETA;

  final RichString note;
}

class StatusValidationResult {
  const StatusValidationResult(this.issues, this.clientFatal);

  final List<Issue> issues;
  final bool clientFatal;
}

class StatusValidatorContext {
  const StatusValidatorContext(this.status, this.history);

  final StatusHistory history;
  final InstantStatus status;
}

class Threshold {
  const Threshold(
      {this.fatal, this.error, this.warning, this.normalizer = 1.0});

  const Threshold.shouldNotBelow(
      {double? fatal, double? error, double? warning, double fraction = 1.0})
      : this(
          fatal: fatal == null ? null : fatal * -1,
          error: error == null ? null : error * -1,
          warning: warning == null ? null : warning * -1,
          normalizer: fraction * -1,
        );

  const Threshold.shouldNotAbove(
      {double? fatal, double? error, double? warning, double fraction = 1.0})
      : this(
          fatal: fatal,
          error: error,
          warning: warning,
          normalizer: fraction,
        );

  final double? fatal;
  final double? error;
  final double? warning;
  final double normalizer;

  Iterable<MetricIssue> check(
      String id, dynamic current, RichString note) sync* {
    double value;
    if (current == null) {
      return;
    }
    if (current is num) {
      value = current.toDouble();
    } else {
      throw Exception('$current is invalid as number');
    }
    IssueSeverity? severity;
    double? thresh;
    double? nextThresh;
    IssueSeverity? nextSeverity;

    if (fatal != null && value / normalizer > fatal!) {
      severity = IssueSeverity.fatal;
      thresh = fatal! * normalizer;
    } else if (error != null && value / normalizer > error!) {
      severity = IssueSeverity.error;
      thresh = error! * normalizer;
      if (fatal != null) {
        nextSeverity = IssueSeverity.fatal;
        nextThresh = fatal! * normalizer;
      }
    } else if (warning != null && value / normalizer > warning!) {
      severity = IssueSeverity.warning;
      thresh = warning! * normalizer;
      if (error != null) {
        nextSeverity = IssueSeverity.error;
        nextThresh = error! * normalizer;
      }
    }

    if (severity == null) {
      return;
    }

    final additionalNote = shouldNotAbove
        ? _srs('(${current.toString()} > ${thresh!.toString()})')
        : _srs('(${current.toString()} < ${thresh!.toString()})');

    yield MetricIssue(id, severity,
        current: current as double,
        thresh: thresh,
        nextThresh: nextThresh,
        nextSeverity: nextSeverity,
        shouldNotAbove: shouldNotAbove,
        note: note.concat(additionalNote));
  }

  bool get shouldNotAbove => normalizer >= 0;
}

class StatusValidatorConfig {
  const StatusValidatorConfig({
    this.clusterTimestampDiffThresh = const Duration(seconds: 10),
    this.machineCPUUtilizationThresh =
        const Threshold.shouldNotAbove(error: 0.9, warning: 0.8),
    this.processCPUUtilizationThresh =
        const Threshold.shouldNotAbove(error: 0.9, warning: 0.8),
    this.processUptimeThresh = const Threshold.shouldNotAbove(),
    this.processRunLoopBusyThresh =
        const Threshold.shouldNotAbove(error: 0.9, warning: 0.8),
  });

  final Duration clusterTimestampDiffThresh;
  final Threshold machineCPUUtilizationThresh;
  final Threshold processCPUUtilizationThresh;
  final Threshold processUptimeThresh;
  final Threshold processRunLoopBusyThresh;
  final String naturalPrimaryDatacenter = "";
}

class StatusValidator {
  StatusValidator(this._c);

  final StatusValidatorConfig _c;

  DateTime clientWallClock() {
    return DateTime.now();
  }

  StatusValidationResult check(InstantStatus status, StatusHistory history) {
    final issues = checkIssues(StatusValidatorContext(status, history));
    final clientFatal =
        issues.any((e) => e.severity == IssueSeverity.clientFatal);
    return StatusValidationResult(issues.toList(), clientFatal);
  }

  Iterable<Issue> checkIssues(StatusValidatorContext c) sync* {
    final clientIssues = checkClient(c, c.status.raw['client']).toList();
    yield* clientIssues;
    if (clientIssues.any((e) => e.severity == IssueSeverity.clientFatal)) {
      return;
    }
    yield* checkCluster(c, c.status.raw['cluster']);
  }

  Iterable<Issue> checkClient(StatusValidatorContext c, dynamic obj) sync* {
    if (!obj['database_status']['available']) {
      yield MessageIssue(
          'client.database.not_available',
          IssueSeverity.clientFatal,
          _srs('Database is not available (maybe disconnected from cluster)'));
      return;
    }
    if (!obj['database_status']['healthy']) {
      yield MessageIssue('client.database.not_healthy', IssueSeverity.warning,
          _srs('Database is not healthy'));
    }
    if (!obj['coordinators']['quorum_reachable']) {
      yield MessageIssue('client.coordinator.quorum_unreachable',
          IssueSeverity.error, _srs('Coordinator quorum is not reachable'));
    }
    for (var coord in (obj['coordinators']['coordinators'] as List<dynamic>)) {
      if (!coord['reachable']) {
        yield MessageIssue(
            'client.coordinator[${coord['address']}].unreachable',
            IssueSeverity.error,
            _rs([
              'Coordinator ',
              ProcessAddressLink(coord['address']),
              ' is not reachable'
            ]));
      }
    }
    yield* (obj['messages'] as List<dynamic>).map((e) => MessageIssue(
        'client.message',
        IssueSeverity.warning,
        _rs(['client: ${e.toString()}'])));
    // TODO: check client timestamp?
  }

  Iterable<Issue> checkCluster(StatusValidatorContext c, dynamic obj) sync* {
    if (obj['active_primary_dc'] != _c.naturalPrimaryDatacenter) {
      yield MessageIssue(
          'cluster.active_primary_dc',
          IssueSeverity.note,
          _rs([
            'Primary Datacenter is',
            DatacenterLink(obj['active_primary_dc']),
            '(natural: ${_c.naturalPrimaryDatacenter})'
          ]));
    }
    // TODO: check bounce_impact
    // TODO: check cluster_controller_timestamp
    if (!obj['database_available']) {
      yield MessageIssue('cluster.database_available', IssueSeverity.error,
          _srs('Database is not available'));
    }
    if (obj['database_lock_state']['locked']) {
      yield MessageIssue('cluster.database_lock_state.locked',
          IssueSeverity.note, _srs('Database is LOCKED'));
    }
    if (!obj['full_replication']) {
      yield MessageIssue('cluster.full_replication', IssueSeverity.warning,
          _srs('Database not fully replicated'));
    }
    yield* (obj['messages'] as List<dynamic>).map((e) => MessageIssue(
        'cluster.message',
        IssueSeverity.warning,
        _rs(['cluster: ${e['name']}: ${e['reasons'].toString()}'])));
    // TODO: check datacenter_lag
    yield* checkClusterClients(c, obj['clients']);
    yield* checkClusterConfiguration(c, obj['configuration']);
    yield* checkClusterData(c, obj['data']);
    yield* checkClusterLatencyProbe(c, obj['latency_probe']);
    yield* checkClusterLayers(c, obj['layers']);
    yield* checkClusterLogs(c, obj['logs']);
    for (final entry in (obj['machines'] as Map<String, dynamic>).entries) {
      yield* checkClusterMachine(c, entry.key, entry.value);
    }
    for (final entry in (obj['processes'] as Map<String, dynamic>).entries) {
      yield* checkClusterProcess(c, entry.key, entry.value);
    }
    yield* checkClusterRecoveryState(c, obj['recovery_state']);
    yield* checkClusterWorkload(c, obj['workload']);
  }

  Iterable<Issue> checkClusterClients(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterConfiguration(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterData(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterLatencyProbe(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterLayers(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterLogs(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterMachine(
      StatusValidatorContext c, String id, dynamic obj) sync* {
    yield* _c.machineCPUUtilizationThresh.check(
        'cluster.machine[$id].cpu.logical_core_utilization.high',
        obj['cpu']['logical_core_utilization'],
        _rs(['Machine(', MachineLink(id), ') cpu utilization']));
    if (obj['excluded']) {
      yield MessageIssue('cluster.machine[$id].excluded', IssueSeverity.note,
          _rs(['Machine(', MachineLink(id), ') is excluded']));
    }
    // TODO: check memory and network
    // TODO: accumulate "excluded" warning
  }

  Iterable<Issue> checkClusterProcess(
      StatusValidatorContext c, String id, dynamic obj) sync* {
    yield* _c.processCPUUtilizationThresh.check(
        'cluster.process[$id].cpu.logical_core_utilization.high',
        obj['cpu']?['usage_cores'] ?? 0,
        _rs([
          'Process(',
          ProcessLink(id),
          ') high cpu utilization (> ${_c.processCPUUtilizationThresh}'
        ]));

    // TODO: check disk metrics
    // TODO: suppress if parent machine is already reported as 'excluded'?
    if (obj['excluded']) {
      yield MessageIssue('cluster.process[$id].excluded', IssueSeverity.note,
          _rs(['Process(', ProcessLink(id), ') is excluded']));
    }
    // TODO: check memory metrics
    yield* (obj['messages'] as List<dynamic>).map((e) => MessageIssue(
        'cluster.process[$id].message',
        IssueSeverity.warning,
        _rs([ProcessLink(id), ' ${e.toString()}'])));
    // TODO: check network
    for (final role in obj['roles']) {
      yield* checkClusterProcessRole(c, id, role);
    }
    yield* _c.processRunLoopBusyThresh.check(
        'cluster.process[$id].run_loop_busy',
        obj['run_loop_busy'],
        _rs(['Process(', ProcessLink(id), ') run_loop_busy is too high']));
    yield* _c.processUptimeThresh.check(
        'cluster.process[$id].uptime',
        obj['uptime_seconds'],
        _rs(['Process(', ProcessLink(id), ') uptime is too long']));
  }

  Iterable<Issue> checkClusterProcessRole(
      StatusValidatorContext c, String processID, dynamic obj) sync* {
    switch (obj['role']) {
      case 'storage':
        yield* checkClusterProcessRoleStorage(c, processID, obj);
    }
  }

  Iterable<Issue> checkClusterProcessRoleStorage(
      StatusValidatorContext c, String processID, dynamic obj) sync* {
    // TODO: check
  }

  Iterable<Issue> checkClusterQoS(StatusValidatorContext c, dynamic obj) sync* {
    if (obj['performance_limited_by']['name'] != 'workload') {
      yield MessageIssue(
          'cluster.qos.performance_limited_by',
          IssueSeverity.error,
          _srs(
              'Performance is limited by ${obj['performance_limited_by']['name']}: ${obj['performance_limited_by']['description']}'));
    }
    if (obj['batch_performance_limited_by']['name'] != 'workload') {
      yield MessageIssue(
          'cluster.qos.batch_performance_limited_by',
          IssueSeverity.error,
          _srs(
              'Batch Performance is limited by ${obj['batch_performance_limited_by']['name']}: ${obj['batch_performance_limited_by']['description']}'));
    }
  }

  Iterable<Issue> checkClusterRecoveryState(
      StatusValidatorContext c, dynamic obj) sync* {
    switch (obj['name']) {
      case 'fully_recovered':
        break;
      default:
        yield MessageIssue(
            'cluster.recovery_state',
            IssueSeverity.note,
            _srs(
                'Recovery in progress, state: ${obj['name']}, ${obj['description']}'));
    }
  }

  Iterable<Issue> checkClusterWorkload(
      StatusValidatorContext c, dynamic obj) sync* {
    // TODO: check
  }
}
