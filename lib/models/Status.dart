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

  MachineInfo? getMachineByID(String machineID) {
    final machines = _data['cluster']['machines'];
    final machine = machines[machineID];
    if (machine == null) {
      return null;
    }
    return MachineInfo(machine);
  }

  List<ProcessRoleInfo>? getRoles(String processID) {
    final processes = _data['cluster']['processes'];
    final process = processes[processID];
    if (process == null) {
      return null;
    }
    final roles = process['roles'] as List<dynamic>;
    return roles.map((e) {
      final roleType = e['role'] as String;
      final id = e['id'] as String?;
      return ProcessRoleInfo(roleType, processID, id, e);
    }).toList();
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

class MachineInfo {
  final dynamic _data;

  MachineInfo(this._data);

  String get address => _data['address'];

  bool get excluded => _data['excluded'];
}

class ProcessInfo {
  final dynamic _data;

  ProcessInfo(this._data);

  String get address => _data['address'];

  bool get excluded => _data['excluded'];

  List<String> get messages =>
      (_data['messages'] as List<dynamic>).map((e) => e.toString()).toList();

  String get version => _data['version'];

  Duration get uptime => Duration(
      milliseconds:
          (normalizeToDouble(_data['uptime_seconds']) * 1000).round());
}

double normalizeToDouble(dynamic v) {
  if (v is int) {
    return v.toDouble();
  } else if (v is double) {
    return v;
  } else {
    throw Exception('not a double: ${v.toString()}');
  }
}

class ProcessRoleInfo {
  final String? id;
  final String type;
  final String processId;
  final dynamic data;

  ProcessRoleInfo(this.type, this.processId, this.id, this.data);
}
