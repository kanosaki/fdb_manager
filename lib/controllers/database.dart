import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

Future<DatabaseManager> openSQLiteDatabaseManager(String path) async {
  var db = await openDatabase(
    path,
    singleInstance: true,
    version: 1,
    onUpgrade: (db, ov, nv) async {
      await db.execute('''CREATE TABLE IF NOT EXISTS config (
              key TEXT NOT NULL, 
              value TEXT, 
              PRIMARY KEY(key))
              ''');
      await db.execute('''CREATE TABLE IF NOT EXISTS clusters (
              name TEXT NOT NULL, 
              base_url TEXT, 
              PRIMARY KEY(name))
              ''');
      log("schema upgraded from $ov to $nv");
    },
  );
  final version = await db.getVersion();
  log("database opened: version=$version");
  return SQLiteDatabaseManager(db);
}

abstract class DatabaseManager implements ChangeNotifier {
  Future<List<ClusterInfo>> listClusters();

  Future<String?> currentClusterName();

  Future setCurrentClusterName(String name);

  Future updateCluster(String name, ClusterInfo ci);

  Future deleteCluster(String name);

  Future close();

  bool isSupportSwitching();
}

class StaticDatabaseManager extends ChangeNotifier implements DatabaseManager {
  final ClusterInfo _ci;

  StaticDatabaseManager(String url) : _ci = ClusterInfo("default", url);

  @override
  Future close() async {}

  @override
  Future<String?> currentClusterName() async {
    return "default";
  }

  @override
  Future deleteCluster(String name) async {
    return;
  }

  @override
  bool isSupportSwitching() {
    return false;
  }

  @override
  Future<List<ClusterInfo>> listClusters() async {
    return [_ci];
  }

  @override
  Future setCurrentClusterName(String name) {
    throw Exception("not supported");
  }

  @override
  Future updateCluster(String name, ClusterInfo ci) {
    throw Exception("not supported");
  }
}

class SQLiteDatabaseManager extends ChangeNotifier implements DatabaseManager {
  SQLiteDatabaseManager(this._db);

  final Database _db;

  @override
  Future<List<ClusterInfo>> listClusters() async {
    final q = await _db.query('clusters', columns: ['name', 'base_url']);
    return q
        .map((e) => ClusterInfo(e['name'] as String, e['base_url'] as String))
        .toList();
  }

  @override
  Future<String?> currentClusterName() async {
    final q = await _db.query('config',
        columns: ['value'], where: "key = 'current_cluster'");
    try {
      return q.map((e) => e['value'] as String).first;
    } on StateError {
      return null;
    }
  }

  @override
  Future setCurrentClusterName(String name) async {
    await _db.insert('config', {'key': 'current_cluster', 'value': name},
        conflictAlgorithm: ConflictAlgorithm.replace);
    log("setCurrentClusterName $name");
  }

  @override
  Future updateCluster(String name, ClusterInfo ci) async {
    await _db.insert('clusters', {'name': name, 'base_url': ci.baseUrl},
        conflictAlgorithm: ConflictAlgorithm.replace);
    log("updateCluster $name $ci");
  }

  @override
  Future deleteCluster(String name) async {
    await _db.transaction((txn) async {
      txn.delete('clusters', where: 'name = ?', whereArgs: [name]);
      txn.delete('config',
          where: "key = 'current_cluster' and value = ?", whereArgs: [name]);
      log("deleteCluster $name");
    });
  }

  @override
  Future close() async {
    log("closing database...");
    await _db.close();
  }

  @override
  bool isSupportSwitching() {
    return true;
  }
}

typedef ClusterChangedCallback = void Function(ClusterInfo?);

class ClusterManager extends ChangeNotifier {
  ClusterManager(this._db);

  final DatabaseManager _db;
  String? _currentClusterName;

  ClusterChangedCallback? clusterChanged;

  Map<String, ClusterInfo> _clusters = {};

  Future load() async {
    log('loading clusters...');
    _clusters = {};
    for (var e in (await _db.listClusters())) {
      _clusters[e.name] = e;
    }
    _currentClusterName = await _db.currentClusterName();
  }

  ClusterInfo? currentCluster() {
    return _clusters[_currentClusterName];
  }

  Iterable<ClusterInfo> listClusters() {
    return _clusters.values;
  }

  Future setActiveClusterName(String name) async {
    _currentClusterName = name;
    await _db.setCurrentClusterName(name);
    await load();
    notifyListeners();
    final h = clusterChanged;
    if (h != null) {
      h(currentCluster());
    }
  }

  Future deleteCluster(String name) async {
    await _db.deleteCluster(name);
    await load();
    notifyListeners();
  }

  Future updateCluster(String name, ClusterInfo ci) async {
    await _db.updateCluster(name, ci);
    await load();
    notifyListeners();
  }
}

class ClusterInfo {
  const ClusterInfo(this.name, this.baseUrl);

  final String name;
  final String baseUrl;
}
