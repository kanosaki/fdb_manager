import 'dart:async';
import 'dart:convert';

import 'package:fdb_manager/models/Status.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'data/status_history.dart';

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

  StatusHistory get history => _history;

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
