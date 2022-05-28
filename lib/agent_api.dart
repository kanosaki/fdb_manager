import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AgentApi {
  final String baseUrl;
  final http.Client httpClient;

  AgentApi(this.baseUrl, this.httpClient);

  Future<dynamic> fetchStatusInstant() async {
    final url = Uri.parse('$baseUrl/v1/status/now');
    final resp = await httpClient.get(url);
    if (resp.statusCode != 200) {
      throw Exception('api failed code = ${resp.statusCode}');
    }
    return jsonDecode(resp.body);
  }
}

class InstantStatusProvider with ChangeNotifier {
  final AgentApi api;

  InstantStatusProvider(this.api);

  final StatusHistory _history = StatusHistory();
  InstantStatus? _cache;
  Timer? _timer;

  void updatePeriodic() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchStatusInstant();
    });
  }

  Future<InstantStatus> statusInstant() async {
    if (_cache != null) {
      return _cache!;
    }
    await fetchStatusInstant();
    return _cache!;
  }

  Future<dynamic> fetchStatusInstant() async {
    final now = DateTime.now();
    var result = await api.fetchStatusInstant();
    _cache = InstantStatus(result);
    _history.add(now, result);
    notifyListeners();
    return _cache;
  }
}

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

class StatusHistory {
  void add(DateTime timestamp, dynamic data) {}
}
