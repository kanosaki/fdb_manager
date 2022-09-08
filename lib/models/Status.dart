import 'dart:io';

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

  ProcessByLocality locality() {
    final processes = (_data['cluster']['processes'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, ProcessInfo(value)));
    final machines = (_data['cluster']['machines'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, MachineInfo(value)));
    final regs = regions();
    return ProcessByLocality(regs, processes, machines);
  }

  List<RegionInfo> regions() {
    final config = (_data['cluster']['configuration']['regions']
        as List<Map<String, dynamic>>?);
    if (config == null) {
      return [];
    }
    return config.map((e) => RegionInfo(e)).toList();
  }
}

class MachineInfo {
  final dynamic _data;

  MachineInfo(this._data);

  String get address => _data['address'];

  bool get excluded => _data['excluded'];

  Map<String, String> get locality => _data['locality'];

  String? get datacenterID => _data['datacenter_id'];
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

  Map<String, dynamic> get locality => _data['locality'];

  List<String> get roles =>
      (_data['roles'] as List<dynamic>).map((e) => e['role'] as String).toList();
}

class RegionInfo {
  final dynamic _data;

  RegionInfo(this._data);

  // TODO: find out how to retrieve region name from status.json
  String get name => "";

  List<DatacenterInfo> get datacenters =>
      (_data['datacenters'] as Map<String, dynamic>)
          .values
          .map((v) => DatacenterInfo(v, this))
          .toList();
}

class DatacenterInfo {
  final dynamic _data;
  final RegionInfo region;

  DatacenterInfo(this._data, this.region);

  String get id => _data['id'];
}

double normalizeToDouble(dynamic v) {
  if (v is num) {
    return v.toDouble();
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

class ProcessByLocality {
  final List<RegionInfo> _regions;
  final Map<String, ProcessInfo> _processes;
  final Map<String, MachineInfo> _machines;

  ProcessByLocality(this._regions, this._processes, this._machines);

  bool get isRegionConfigured => _regions.isNotEmpty;

  Map<String, Map<String, List<ProcessInfo>>> zones({String? dcID}) {
    Iterable<ProcessInfo> processes = dcID == null
        ? _processes.values
        : _processes.entries.where((e) {
            final machineID = e.value.locality['machineid'] as String;
            final machine = _machines[machineID]!;
            return machine.datacenterID == dcID;
          }).map((e) => e.value);
    final zoneMap = <String, Map<String, List<ProcessInfo>>>{};
    for (var pi in processes) {
      final zoneID =
          pi.locality['zoneid'] as String; // TODO: handle empty value
      final machineID = pi.locality['machineid'] as String;
      if (!zoneMap.containsKey(zoneID)) {
        zoneMap[zoneID] = <String, List<ProcessInfo>>{};
      }
      final machineMap = zoneMap[zoneID]!;
      if (!machineMap.containsKey(machineID)) {
        machineMap[machineID] = [pi];
      } else {
        machineMap[machineID]!.add(pi);
      }
    }
    return zoneMap;
  }
}
