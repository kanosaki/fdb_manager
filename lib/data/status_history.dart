import 'package:sqflite/sqflite.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../models/Status.dart';

class HistoryEntry {
  DateTime timestamp;
  dynamic data;

  HistoryEntry(this.timestamp, this.data);
}

class HistorySeriesEntry {
  dynamic data;
  DateTime timestamp;

  HistorySeriesEntry(this.timestamp, this.data);
}

class StatusHistory {
  final List<HistoryEntry> _history = [];
  final int capacity = 1000;

  StatusHistory() {
    var db = openDatabase('fdb_manager.db',
        version: 1, onCreate: (Database db, int version) {});
  }

  void add(DateTime timestamp, dynamic data) {
    if (_history.length >= capacity) {
      _history.removeAt(0);
    }
    _history.add(HistoryEntry(timestamp, data));
  }

  charts.Series<dynamic, DateTime> series(
      String id, DateTime timestamp, Duration length, List<String> path) {
    var timestampFrom = timestamp.subtract(length);
    var beginIndex =
        _history.indexWhere((e) => e.timestamp.isAfter(timestampFrom));
    var endIndex =
        _history.lastIndexWhere((e) => e.timestamp.isBefore(timestamp));

    final data = _history
        .getRange(beginIndex, endIndex)
        .map((e) => HistorySeriesEntry(e.timestamp, selectByPath(e, path)))
        .toList();

    return charts.Series(
      id: id,
      data: data,
      domainFn: (he, _) => he.timestamp,
      measureFn: (he, _) => he.data,
    );
  }

  List<dynamic> query(DateTime timestamp, Duration length, List<String> path) {
    var timestampFrom = timestamp.subtract(length);
    var beginIndex =
        _history.indexWhere((e) => e.timestamp.isAfter(timestampFrom));
    var endIndex =
        _history.lastIndexWhere((e) => e.timestamp.isBefore(timestamp));

    return _history
        .getRange(beginIndex, endIndex)
        .map((e) => selectByPath(e, path))
        .toList();
  }

  static dynamic selectByPath(HistoryEntry entry, List<String> path) {
    dynamic current = entry.data;
    List<String> cwd = [];
    for (var elem in path) {
      if (current == null) {
        return null;
      } else if (current is Map<String, dynamic>) {
        current = current[elem];
      } else {
        current = selectElementByKey(cwd, elem, current);
      }
      cwd.add(elem);
    }
    return current;
  }

  static dynamic selectElementByKey(
      List<String> cwd, String key, dynamic element) {
    if (matchPath(['cluster', 'processes', '', 'roles'], cwd)) {
      for (var elem in element) {
        if (elem['role'] == key) {
          return elem;
        }
      }
      return null;
    } else {
      throw Exception('key is not defined for $cwd/$key');
    }
  }

  static bool matchPath(List<String> pattern, List<String> target) {
    if (pattern.length > target.length) {
      return false;
    }
    for (int i = 0; i < pattern.length; i++) {
      final pat = pattern[i];
      if (pat == '') {
        // wildcard
        continue;
      }
      if (pat != target[i]) {
        return false;
      }
    }
    return true;
  }
}
