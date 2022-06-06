import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sqflite/sqflite.dart';

class InstantStatus {
  final dynamic _data;

  InstantStatus(this._data);

  dynamic get raw => _data;

  ProcessInfo? getProcessByID(String processID) {
    final processes = _data['cluster']['processes'];
    final process = processes[processID];
    if (process == null) {
      return null;
    }
    return ProcessInfo(process);
  }

  Map<String, List<ProcessRoleInfo>> roles() {
    final Map<String, List<ProcessRoleInfo>> ret = {};
    final processes = _data['cluster']['processes']
        as Map<String, dynamic>; // key is processId
    for (var procEntry in processes.entries) {
      final processId = procEntry.key;
      for (var roleObj in procEntry.value['roles'] as List<dynamic>) {
        final roleType = roleObj['role'] as String;
        final id = roleObj['id'] as String?;

        ret.putIfAbsent(roleType, () => []);
        ret[roleType]!.add(ProcessRoleInfo(roleType, processId, id, roleObj));
      }
    }
    return ret;
  }
}

class ProcessInfo {
  final dynamic _data;

  ProcessInfo(this._data);

  String get address => _data['address'];
}

class ProcessRoleInfo {
  final String? id;
  final String type;
  final String processId;
  final dynamic data;

  ProcessRoleInfo(this.type, this.processId, this.id, this.data);
}

