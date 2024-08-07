// Generic class to handle common data structures
// sample:
// {
//   "counter": 6821,
//   "hz": 0,
//   "roughness": -1
// }
class EventCounter {
  final num counter;
  final num hz;
  final num roughness;

  EventCounter(this.counter, this.hz, this.roughness);

  EventCounter.fromJson(dynamic data)
      : counter = data['counter'] as num,
        hz = data['hz'] as num,
        roughness = data['roughness'] as num;
}

class InstantStatus {
  final dynamic _data;

  InstantStatus(this._data);

  dynamic get raw => _data;

  ClientInfo get client => ClientInfo(_data['client']);

  ClusterInfo get cluster => ClusterInfo(_data['cluster']);

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

  Exclusions get exclusions {
    return Exclusions.fromData(
        _data['cluster']['configuration']['excluded_servers']);
  }
}

class ClusterInfo {
  final dynamic _data;

  ClusterInfo(this._data);

  int get clusterControllerTimestamp =>
      _data['cluster_controller_timestamp'] as int;

  BounceImpactInfo get bounceImpact => BounceImpactInfo(_data['bounce_impact']);

  String get connectionString => _data['connection_string'] as String;

  String get activePrimaryDC => _data['active_primary_dc'] as String;

  int get activeTSSCount => _data['active_tss_count'] as int;

  ClusterConfiguration get configuration =>
      ClusterConfiguration(_data['configuration']);

// sample:
//    "clients": {
//       "count": 2,
//       "supported_versions": [
//         {
//           "client_version": "7.1.40",
//           "connected_clients": [
//             {
//               "address": "127.0.0.1:59876",
//               "log_group": "default"
//             },
//             {
//               "address": "127.0.0.1:60544",
//               "log_group": "default"
//             }
//           ],
//           "count": 2,
//           "max_protocol_clients": [
//             {
//               "address": "127.0.0.1:59876",
//               "log_group": "default"
//             },
//             {
//               "address": "127.0.0.1:60544",
//               "log_group": "default"
//             }
//           ],
//           "max_protocol_count": 2,
//           "protocol_version": "fdb00b071010000",
//           "source_version": "3f31504f0e11fee14ee70248336229a9cc460eea"
//         }
//       ]
//     },
  ClusterClientInfo get clients => ClusterClientInfo(_data['clients']);

  ClusterDataInfo get data => ClusterDataInfo(_data['data']);

  bool get databaseAvailable => _data['database_available'] as bool;

  DatabaseLockStateInfo get databaseLockState =>
      DatabaseLockStateInfo(_data['database_lock_state']);

  DatacenterLagInfo get datacenterLag =>
      DatacenterLagInfo(_data['datacenter_lag']);

  int get degradedProcesses => _data['degraded_processes'] as int;

  FaultToleranceInfo get faultTolerance =>
      FaultToleranceInfo(_data['fault_tolerance']);

  bool get fullReplication => _data['full_replication'] as bool;

  int get generation => _data['generation'] as int;

  List<dynamic> get incompatibleConnections =>
      _data['incompatible_connections'] as List<dynamic>;

  LatencyProbe get latencyProbe => LatencyProbe(_data['latency_probe']);

  LayersInfo get layers => LayersInfo(_data['layers']);

  List<LogInfo> get logs => (_data['logs'] as List<Map<String, Object>>)
      .map((e) => LogInfo(e))
      .toList();

  Map<String, MachineInfo> get machines =>
      (_data['machines'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, MachineInfo(value)));

  List<String> get messages => _data['messages'] as List<String>;

  PageCacheInfo get pageCache => PageCacheInfo(_data['page_cache']);

  Map<String, ProcessInfo> get processes =>
      (_data['processes'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, ProcessInfo(value)));

  String get protocolVersion => _data['protocol_version'] as String;

  QoSInfo get qos => QoSInfo(_data['qos']);

  RecoveryStateInfo get recoveryState =>
      RecoveryStateInfo(_data['recovery_state']);

  WorkloadInfo get workload => WorkloadInfo(_data['workload']);
}

class BounceImpactInfo {
  final dynamic _data;

  BounceImpactInfo(this._data);

  bool get canCleanBounce => _data['can_clean_bounce'] as bool;
}

// sample:
// {
//   "cluster_file": {
//     "path": "/usr/local/etc/foundationdb/fdb.cluster",
//     "up_to_date": true
//   },
//   "coordinators": {
//     "coordinators": [
//       {
//         "address": "127.0.0.1:4689",
//         "protocol": "0fdb00b071010000",
//         "reachable": true
//       }
//     ],
//     "quorum_reachable": true
//   },
//   "database_status": {
//     "available": true,
//     "healthy": true
//   },
//   "messages": [],
//   "timestamp": 1722691467
// }
class ClientInfo {
  final dynamic _data;

  ClientInfo(this._data);

  ClusterFile get clusterFile => ClusterFile(_data['cluster_file']);

  CoordinatorsInfo get coordinators => CoordinatorsInfo(_data['coordinators']);

  DatabaseStatusInfo get databaseStatus =>
      DatabaseStatusInfo(_data['database_status']);

  List<String> get messages =>
      (_data['messages'] as List<dynamic>).map((e) => e as String).toList();

  int get timestamp => _data['timestamp'] as int;
}

class ClusterFile {
  final dynamic _data;

  ClusterFile(this._data);

  String get path => _data['path'] as String;

  bool get upToDate => _data['up_to_date'] as bool;
}

class CoordinatorsInfo {
  final dynamic _data;

  CoordinatorsInfo(this._data);

  List<CoordinatorInfo> get coordinators =>
      (_data['coordinators'] as List<dynamic>)
          .map((e) => CoordinatorInfo(e))
          .toList();

  bool get quorumReachable => _data['quorum_reachable'] as bool;
}

class CoordinatorInfo {
  final dynamic _data;

  CoordinatorInfo(this._data);

  String get address => _data['address'] as String;

  String get protocol => _data['protocol'] as String;

  bool get reachable => _data['reachable'] as bool;
}

class DatabaseStatusInfo {
  final dynamic _data;

  DatabaseStatusInfo(this._data);

  bool get available => _data['available'] as bool;

  bool get healthy => _data['healthy'] as bool;
}

class ClusterClientInfo {
  final dynamic _data;

  ClusterClientInfo(this._data);

  int get count => _data['count'] as int;

  List<ClientVersionInfo> get supportedVersions =>
      (_data['supported_versions'] as List<dynamic>)
          .map((e) => ClientVersionInfo(e))
          .toList();
}

class ClientVersionInfo {
  final dynamic _data;

  ClientVersionInfo(this._data);

  String get clientVersion => _data['client_version'] as String;

  List<ClientAddressInfo> get connectedClients =>
      (_data['connected_clients'] as List<dynamic>)
          .map((e) => ClientAddressInfo(e))
          .toList();

  int get maxProtocolCount => _data['max_protocol_count'] as int;

  List<ClientAddressInfo> get maxProtocolClients =>
      (_data['max_protocol_clients'] as List<dynamic>)
          .map((e) => ClientAddressInfo(e))
          .toList();

  String get protocolVersion => _data['protocol_version'] as String;

  String get sourceVersion => _data['source_version'] as String;
}

class ClientAddressInfo {
  final dynamic _data;

  ClientAddressInfo(this._data);

  String get address => _data['address'] as String;

  String get logGroup => _data['log_group'] as String;
}

// sample:
//     "configuration": {
//       "backup_worker_enabled": 0,
//       "blob_granules_enabled": 0,
//       "coordinators_count": 1,
//       "excluded_servers": [],
//       "log_spill": 2,
//       "perpetual_storage_wiggle": 0,
//       "perpetual_storage_wiggle_engine": "none",
//       "perpetual_storage_wiggle_locality": "0",
//       "redundancy_mode": "single",
//       "storage_engine": "ssd-2",
//       "storage_migration_type": "disabled",
//       "tenant_mode": "disabled",
//       "usable_regions": 1
//     },
class ClusterConfiguration {
  final dynamic _data;

  ClusterConfiguration(this._data);

  int get backupWorkerEnabled => _data['backup_worker_enabled'] as int;

  int get blobGranulesEnabled => _data['blob_granules_enabled'] as int;

  int get coordinatorsCount => _data['coordinators_count'] as int;

  List<String> get excludedServers =>
      (_data['excluded_servers'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

  int get logSpill => _data['log_spill'] as int;

  int get perpetualStorageWiggle => _data['perpetual_storage_wiggle'] as int;

  String get perpetualStorageWiggleEngine =>
      _data['perpetual_storage_wiggle_engine'] as String;

  String get perpetualStorageWiggleLocality =>
      _data['perpetual_storage_wiggle_locality'] as String;

  String get redundancyMode => _data['redundancy_mode'] as String;

  String get storageEngine => _data['storage_engine'] as String;

  String get storageMigrationType => _data['storage_migration_type'] as String;

  String get tenantMode => _data['tenant_mode'] as String;

  int get usableRegions => _data['usable_regions'] as int;
}

// sample:
// "data": {
//       "average_partition_size_bytes": 21130760,
//       "least_operating_space_bytes_log_server": 435931681173,
//       "least_operating_space_bytes_storage_server": 435931681133,
//       "moving_data": {
//         "highest_priority": 0,
//         "in_flight_bytes": 0,
//         "in_queue_bytes": 0,
//         "total_written_bytes": 0
//       },
//       "partitions_count": 9,
//       "state": {
//         "healthy": true,
//         "min_replicas_remaining": 1,
//         "name": "healthy"
//       },
//       "system_kv_size_bytes": 147569250,
//       "team_trackers": [
//         {
//           "in_flight_bytes": 0,
//           "primary": true,
//           "state": {
//             "healthy": true,
//             "min_replicas_remaining": 1,
//             "name": "healthy"
//           },
//           "unhealthy_servers": 0
//         }
//       ],
//       "total_disk_used_bytes": 761929904,
//       "total_kv_size_bytes": 157901250
//     },
class ClusterDataInfo {
  final dynamic _data;

  ClusterDataInfo(this._data);

  int get averagePartitionSizeBytes =>
      _data['average_partition_size_bytes'] as int;

  int get leastOperatingSpaceBytesLogServer =>
      _data['least_operating_space_bytes_log_server'] as int;

  int get leastOperatingSpaceBytesStorageServer =>
      _data['least_operating_space_bytes_storage_server'] as int;

  MovingDataInfo get movingData => MovingDataInfo(_data['moving_data']);

  int get partitionsCount => _data['partitions_count'] as int;

  DataStateInfo get state => DataStateInfo(_data['state']);

  int get systemKVSizeBytes => _data['system_kv_size_bytes'] as int;

  List<TeamTrackersInfo> get teamTrackers =>
      (_data['team_trackers'] as List<dynamic>)
          .map((e) => TeamTrackersInfo(e))
          .toList();

  int get totalDiskUsedBytes => _data['total_disk_used_bytes'] as int;

  int get totalKVSizeBytes => _data['total_kv_size_bytes'] as int;
}

class MovingDataInfo {
  final dynamic _data;

  MovingDataInfo(this._data);

  int get highestPriority => _data['highest_priority'] as int;

  int get inFlightBytes => _data['in_flight_bytes'] as int;

  int get inQueueBytes => _data['in_queue_bytes'] as int;

  int get totalWrittenBytes => _data['total_written_bytes'] as int;
}

class DataStateInfo {
  final dynamic _data;

  DataStateInfo(this._data);

  bool get healthy => _data['healthy'] as bool;

  int get minReplicasRemaining => _data['min_replicas_remaining'] as int;

  String get name => _data['name'] as String;
}

class TeamTrackersInfo {
  final dynamic _data;

  TeamTrackersInfo(this._data);

  int get inFlightBytes => _data['in_flight_bytes'] as int;

  bool get primary => _data['primary'] as bool;

  DataStateInfo get state => DataStateInfo(_data['state']);

  int get unhealthyServers => _data['unhealthy_servers'] as int;
}

class DatabaseLockStateInfo {
  final dynamic _data;

  DatabaseLockStateInfo(this._data);

  bool get locked => _data['locked'] as bool;
}

// sample:
// {
//       "seconds": 0,
//       "versions": 0
//     }
class DatacenterLagInfo {
  final dynamic _data;

  DatacenterLagInfo(this._data);

  num get seconds => _data['seconds'] as num;

  int get versions => _data['versions'] as int;
}

// sample:
// {
//       "max_zone_failures_without_losing_availability": 0,
//       "max_zone_failures_without_losing_data": 0
//     }
class FaultToleranceInfo {
  final dynamic _data;

  FaultToleranceInfo(this._data);

  int get maxZoneFailuresWithoutLosingAvailability =>
      _data['max_zone_failures_without_losing_availability'] as int;

  int get maxZoneFailuresWithoutLosingData =>
      _data['max_zone_failures_without_losing_data'] as int;
}

// sample:
// {
//       "batch_priority_transaction_start_seconds": 0.0011711099999999999,
//       "commit_seconds": 0.017771200000000001,
//       "immediate_priority_transaction_start_seconds": 0.0032098299999999999,
//       "read_seconds": 0.00034713700000000002,
//       "transaction_start_seconds": 0.00149274
//     }
class LatencyProbe {
  final dynamic _data;

  LatencyProbe(this._data);

  double get batchPriorityTransactionStartSeconds =>
      _data['batch_priority_transaction_start_seconds'] as double;

  double get commitSeconds => _data['commit_seconds'] as double;

  double get immediatePriorityTransactionStartSeconds =>
      _data['immediate_priority_transaction_start_seconds'] as double;

  double get readSeconds => _data['read_seconds'] as double;

  double get transactionStartSeconds =>
      _data['transaction_start_seconds'] as double;
}

// sample:
// {
//         "address": "127.0.0.1",
//         "contributing_workers": 4,
//         "cpu": {
//           "logical_core_utilization": 0.25488899999999998
//         },
//         "excluded": false,
//         "locality": {
//           "machineid": "9c7af1a02294582cfa6158311c593879",
//           "processid": "fec1d44658890fb0141475b662fb2d71",
//           "zoneid": "9c7af1a02294582cfa6158311c593879"
//         },
//         "machine_id": "9c7af1a02294582cfa6158311c593879",
//         "memory": {
//           "committed_bytes": 30325342208,
//           "free_bytes": 70451200,
//           "total_bytes": 30395793408
//         },
//         "network": {
//           "megabits_received": {
//             "hz": 0
//           },
//           "megabits_sent": {
//             "hz": 0
//           },
//           "tcp_segments_retransmitted": {
//             "hz": 0
//           }
//         }
//       }
class MachineInfo {
  final dynamic _data;

  MachineInfo(this._data);

  String get address => _data['address'];

  int get contributingWorkers => _data['contributing_workers'] as int;

  double get logicalCoreUtilization =>
      _data['cpu']['logical_core_utilization'] as double;

  bool get excluded => _data['excluded'];

  LocalityInfo get locality => LocalityInfo(_data['locality']);

  String get machineID => _data['machine_id'];

  String? get datacenterID => _data['datacenter_id'];

  MemoryInfo get memory => MemoryInfo(_data['memory']);

  NetworkInfo get network => NetworkInfo(_data['network']);
}

class LocalityInfo {
  final dynamic _data;

  LocalityInfo(this._data);

  String get machineID => _data['machineid'] as String;

  String get processID => _data['processid'] as String;

  String get zoneID => _data['zoneid'] as String;
}

class MemoryInfo {
  final dynamic _data;

  MemoryInfo(this._data);

  int get committedBytes => _data['committed_bytes'] as int;

  int get freeBytes => _data['free_bytes'] as int;

  int get totalBytes => _data['total_bytes'] as int;
}

class NetworkInfo {
  final dynamic _data;

  NetworkInfo(this._data);

  num get megabitsReceivedHz => _data['megabits_received']['hz'] as num;

  num get megabitsSentHz => _data['megabits_sent']['hz'] as num;

  num get tcpSegmentsRetransmittedHz =>
      _data['tcp_segments_retransmitted']['hz'] as num;
}

// sample:
//     "page_cache": {
//       "log_hit_rate": 1,
//       "storage_hit_rate": 1
//     },
class PageCacheInfo {
  final dynamic _data;

  PageCacheInfo(this._data);

  double get logHitRate => _data['log_hit_rate'] as double;

  double get storageHitRate => _data['storage_hit_rate'] as double;
}

// sample:
// {
//         "begin_version": 58826593724949,
//         "current": true,
//         "epoch": 316,
//         "log_fault_tolerance": 0,
//         "log_interfaces": [
//           {
//             "address": "127.0.0.1:4692",
//             "healthy": true,
//             "id": "90ca4eed5846876e"
//           },
//           {
//             "address": "127.0.0.1:4689",
//             "healthy": true,
//             "id": "a9eeda4eda306176"
//           }
//         ],
//         "log_replication_factor": 1,
//         "log_write_anti_quorum": 0,
//         "possibly_losing_data": false
//       }
class LogInfo {
  final dynamic _data;

  LogInfo(this._data);

  int get beginVersion => _data['begin_version'] as int;

  bool get current => _data['current'] as bool;

  int get epoch => _data['epoch'] as int;

  int get logFaultTolerance => _data['log_fault_tolerance'] as int;

  List<LogInterfaceInfo> get logInterfaces =>
      (_data['log_interfaces'] as List<dynamic>)
          .map((e) => LogInterfaceInfo(e))
          .toList();

  int get logReplicationFactor => _data['log_replication_factor'] as int;

  int get logWriteAntiQuorum => _data['log_write_anti_quorum'] as int;

  bool get possiblyLosingData => _data['possibly_losing_data'] as bool;
}

class LogInterfaceInfo {
  final dynamic _data;

  LogInterfaceInfo(this._data);

  String get address => _data['address'];

  bool get healthy => _data['healthy'] as bool;

  String get id => _data['id'];
}

class LayersInfo {
  final dynamic _data;

  LayersInfo(this._data);

  bool get valid => _data['_valid'] as bool;

  String? get error => _data['_error'] as String?;

  BackupLayerInfo get backup => BackupLayerInfo(_data['backup']);
}

// sample:
// {
//         "blob_recent_io": {
//           "bytes_per_second": 0,
//           "bytes_sent": 0,
//           "requests_failed": 0,
//           "requests_successful": 0
//         },
//         "instances": {
//           "06477be4acbe6f9d9b9c3b55773ea5a4": {
//             "blob_stats": {
//               "recent": {
//                 "bytes_per_second": 0,
//                 "bytes_sent": 0,
//                 "requests_failed": 0,
//                 "requests_successful": 0
//               },
//               "total": {
//                 "bytes_sent": 0,
//                 "requests_failed": 0,
//                 "requests_successful": 0
//               }
//             },
//             "configured_workers": 10,
//             "id": "06477be4acbe6f9d9b9c3b55773ea5a4",
//             "last_updated": 1722691073.1571782,
//             "main_thread_cpu_seconds": 545.59401400000002,
//             "memory_usage": 420971446272,
//             "process_cpu_seconds": 601.26363300000003,
//             "resident_size": 19120128,
//             "version": "7.1.40"
//           }
//         },
//         "instances_running": 1,
//         "last_updated": 1722691073.1571782,
//         "paused": false,
//         "tags": {},
//         "total_workers": 10
class BackupLayerInfo {
  final dynamic _data;

  BackupLayerInfo(this._data);

  BlobRecentIOInfo get blobRecentIO =>
      BlobRecentIOInfo(_data['blob_recent_io']);

  Map<String, BackupInstanceInfo> get instances =>
      (_data['instances'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, BackupInstanceInfo(value)));

  int get instancesRunning => _data['instances_running'] as int;

  double get lastUpdated => _data['last_updated'] as double;

  bool get paused => _data['paused'] as bool;

  Map<String, dynamic> get tags => (_data['tags'] as Map<dynamic, dynamic>)
      .map((key, value) => MapEntry(key.toString(), value as dynamic));

  int get totalWorkers => _data['total_workers'] as int;
}

class BlobRecentIOInfo {
  final dynamic _data;

  BlobRecentIOInfo(this._data);

  int get bytesPerSecond => _data['bytes_per_second'] as int;

  int get bytesSent => _data['bytes_sent'] as int;

  int get requestsFailed => _data['requests_failed'] as int;

  int get requestsSuccessful => _data['requests_successful'] as int;
}

class BackupInstanceInfo {
  final dynamic _data;

  BackupInstanceInfo(this._data);

  BlobStatsInfo get blobStats => BlobStatsInfo(_data['blob_stats']);

  int get configuredWorkers => _data['configured_workers'] as int;

  String get id => _data['id'] as String;

  double get lastUpdated => _data['last_updated'] as double;

  double get mainThreadCpuSeconds => _data['main_thread_cpu_seconds'] as double;

  int get memoryUsage => _data['memory_usage'] as int;

  double get processCpuSeconds => _data['process_cpu_seconds'] as double;

  int get residentSize => _data['resident_size'] as int;

  String get version => _data['version'] as String;
}

class BlobStatsInfo {
  final dynamic _data;

  BlobStatsInfo(this._data);

  BlobRecentIOInfo get recent => BlobRecentIOInfo(_data['recent']);

  BlobTotalIOInfo get total => BlobTotalIOInfo(_data['total']);
}

class BlobTotalIOInfo {
  final dynamic _data;

  BlobTotalIOInfo(this._data);

  int get bytesSent => _data['bytes_sent'] as int;

  int get requestsFailed => _data['requests_failed'] as int;

  int get requestsSuccessful => _data['requests_successful'] as int;
}

// sample:
//  {
//         "address": "127.0.0.1:4690",
//         "class_source": "command_line",
//         "class_type": "unset",
//         "command_line": "/usr/local/libexec/fdbserver --cluster_file=/usr/local/etc/foundationdb/fdb.cluster --datadir=/usr/local/foundationdb/data/4690 --listen_address=public --logdir=/usr/local/foundationdb/logs --public_address=auto:4690",
//         "cpu": {
//           "usage_cores": 0.029672199999999999
//         },
//         "disk": {
//           "busy": 0.0289518,
//           "free_bytes": 485394300928,
//           "reads": {
//             "counter": 7283259,
//             "hz": 94.442700000000002,
//             "sectors": 0
//           },
//           "total_bytes": 994662584320,
//           "writes": {
//             "counter": 35836376,
//             "hz": 181.89699999999999,
//             "sectors": 0
//           }
//         },
//         "excluded": false,
//         "fault_domain": "9c7af1a02294582cfa6158311c593879",
//         "locality": {
//           "machineid": "9c7af1a02294582cfa6158311c593879",
//           "processid": "164e2bfa10a839e3d22140458435cd13",
//           "zoneid": "9c7af1a02294582cfa6158311c593879"
//         },
//         "machine_id": "9c7af1a02294582cfa6158311c593879",
//         "memory": {
//           "available_bytes": 212025344,
//           "limit_bytes": 8589934592,
//           "rss_bytes": 52084736,
//           "unused_allocated_memory": 131072,
//           "used_bytes": 422001360896
//         },
//         "messages": [],
//         "network": {
//           "connection_errors": {
//             "hz": 0
//           },
//           "connections_closed": {
//             "hz": 0
//           },
//           "connections_established": {
//             "hz": 0
//           },
//           "current_connections": 4,
//           "megabits_received": {
//             "hz": 0.200575
//           },
//           "megabits_sent": {
//             "hz": 0.11658
//           },
//           "tls_policy_failures": {
//             "hz": 0
//           }
//         },
//         "roles": [
//             .....
//         ],
//         "run_loop_busy": 0.00000000000000000,
//         "uptime_seconds": 1722691073.1571782,
//         "version": "7.1.40"
//       }
//
class ProcessInfo {
  final dynamic _data;

  ProcessInfo(this._data);

  String get address => _data['address'];

  double get cpuUsageCores => _data['cpu']['usage_cores'] as double;

  ProcessDiskStats get disk => ProcessDiskStats(_data['disk']);

  ProcessMemoryStats get memory => ProcessMemoryStats(_data['memory']);

  ProcessNetworkStats get network => ProcessNetworkStats(_data['network']);

  bool get excluded => _data['excluded'];

  List<String> get messages =>
      (_data['messages'] as List<dynamic>).map((e) => e.toString()).toList();

  String get version => _data['version'];

  Duration get uptime => Duration(
      milliseconds:
          (normalizeToDouble(_data['uptime_seconds']) * 1000).round());

  LocalityInfo get locality => LocalityInfo(_data['locality']);

  String get faultDomain => _data['fault_domain'] as String;

  List<String> get roleNames => (_data['roles'] as List<dynamic>)
      .map((e) => e['role'] as String)
      .toList();

  List<Role> get roles =>
      (_data['roles'] as List<dynamic>).map((e) => makeRole(e)).toList();

  double get busy => _data['run_loop_busy'] as double;

  String get machineID => _data['machine_id'] as String;
}

// sample:
// {
//           "busy": 0.0289518,
//           "free_bytes": 485394300928,
//           "reads": {
//             "counter": 7283259,
//             "hz": 94.442700000000002,
//             "sectors": 0
//           },
//           "total_bytes": 994662584320,
//           "writes": {
//             "counter": 35836376,
//             "hz": 181.89699999999999,
//             "sectors": 0
//           }
//         }
class ProcessDiskStats {
  final dynamic _data;

  ProcessDiskStats(this._data);

  double get busy => _data['busy'];

  int get freeBytes => _data['free_bytes'];

  ProcessDiskIOStats get reads => ProcessDiskIOStats(_data['reads']);

  int get totalBytes => _data['total_bytes'];

  ProcessDiskIOStats get writes => ProcessDiskIOStats(_data['writes']);
}

class ProcessDiskIOStats {
  final dynamic _data;

  ProcessDiskIOStats(this._data);

  int get counter => _data['counter'];

  double get hz => _data['hz'];

  int get sectors => _data['sectors'];
}

// sample:
//  {
//   "available_bytes": 212025344,
//   "limit_bytes": 8589934592,
//   "rss_bytes": 52084736,
//   "unused_allocated_memory": 131072,
//   "used_bytes": 422001360896
// }
class ProcessMemoryStats {
  final dynamic _data;

  ProcessMemoryStats(this._data);

  int get availableBytes => _data['available_bytes'];

  int get limitBytes => _data['limit_bytes'];

  int get usedBytes => _data['used_bytes'];

  int get rssBytes => _data['rss_bytes'];

  int get unusedAllocatedMemory => _data['unused_allocated_memory'];
}

// sample:
// {
//   "connection_errors": {
//     "hz": 0
//   },
//   "connections_closed": {
//     "hz": 0
//   },
//   "connections_established": {
//     "hz": 0
//   },
//   "current_connections": 4,
//   "megabits_received": {
//     "hz": 0.200575
//   },
//   "megabits_sent": {
//     "hz": 0.11658
//   },
//   "tls_policy_failures": {
//     "hz": 0
//   }
// }
class ProcessNetworkStats {
  final dynamic _data;

  ProcessNetworkStats(this._data);

  int get currentConnections => _data['current_connections'];

  num get connectionErrorsHz => _data['connection_errors']['hz'] as num;

  num get connectionsClosedHz => _data['connections_closed']['hz'] as num;

  num get connectionsEstablishedHz =>
      _data['connections_established']['hz'] as num;

  num get tlsPolicyFailuresHz => _data['tls_policy_failures']['hz'] as num;

  num get mbpsReceived => _data['megabits_received']['hz'] as num;

  num get mbpsSent => _data['megabits_sent']['hz'] as num;
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
            final machineID = e.value.locality.machineID;
            final machine = _machines[machineID]!;
            return machine.datacenterID == dcID;
          }).map((e) => e.value);
    final zoneMap = <String, Map<String, List<ProcessInfo>>>{};
    for (var pi in processes) {
      final zoneID = pi.locality.zoneID; // TODO: handle empty value
      final machineID = pi.locality.machineID;
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

enum ExclusionType { address, locality }

class Exclusion {
  late final ExclusionType type;

  // formats:
  //   if type == address: "IP:PORT"
  //   if type == locality:"
  //     "locality_dcid:<...>"
  //     "locality_zone:<...>"
  late final String value;

  Exclusion(this.type, this.value);

  Exclusion.fromData(dynamic data) {
    final locality = data['locality'] as String?;
    final address = data['address'] as String?;
    if (locality != null) {
      type = ExclusionType.locality;
      value = locality;
    } else if (address != null) {
      type = ExclusionType.address;
      value = address;
    } else {
      throw Exception('invalid exclusion data: $data');
    }
  }
}

class Exclusions {
  late final List<Exclusion> exclusions;

  Exclusions(this.exclusions);

  // pass cluster.configuration.excluded_servers
  Exclusions.fromData(dynamic data) {
    exclusions =
        (data as List<dynamic>).map((e) => Exclusion.fromData(e)).toList();
  }

  bool isExcluded(String address) {
    return exclusions
        .any((e) => e.type == ExclusionType.address && e.value == address);
  }

  bool isExcludedByZoneID(String zoneID) {
    final expr = "locality_zoneid:$zoneID";
    return exclusions
        .any((e) => e.type == ExclusionType.locality && e.value == expr);
  }

  bool isExcludedByDatacenterID(String dcID) {
    final expr = "locality_dcid:$dcID";
    return exclusions
        .any((e) => e.type == ExclusionType.locality && e.value == expr);
  }

  bool isExcludedByMachineID(String machineID) {
    final expr = "locality_machineid:$machineID";
    return exclusions
        .any((e) => e.type == ExclusionType.locality && e.value == expr);
  }
}

class Role {
  final dynamic _data;

  Role(this._data);

  String get name => _data['role'] as String;

  String get id => _data['id'] as String;
}

Role makeRole(dynamic data) {
  final name = data['role'] as String;
  switch (name) {
    case 'log':
      return LogRoleInfo(data);
    case 'storage':
      return StorageRoleInfo(data);
    case 'coordinator':
      return CoordinatorRoleInfo(data);
    case 'grv_proxy':
      return GRVProxyRoleInfo(data);
    case 'commit_proxy':
      return CommitProxyRoleInfo(data);
    default:
      return Role(data);
  }
}

// sample:
// {
//   "data_version": 58892064583324,
//   "durable_bytes": {
//     "counter": 6821,
//     "hz": 0,
//     "roughness": -1
//   },
//   "id": "90ca4eed5846876e",
//   "input_bytes": {
//     "counter": 6821,
//     "hz": 0,
//     "roughness": -1
//   },
//   "kvstore_available_bytes": 485394296832,
//   "kvstore_free_bytes": 485394296832,
//   "kvstore_total_bytes": 994662584320,
//   "kvstore_used_bytes": 104894464,
//   "queue_disk_available_bytes": 485394296832,
//   "queue_disk_free_bytes": 485394296832,
//   "queue_disk_total_bytes": 994662584320,
//   "queue_disk_used_bytes": 2497703936,
//   "role": "log"
// }
class LogRoleInfo extends Role {
  LogRoleInfo(dynamic data) : super(data);

  int get dataVersion => _data['data_version'] as int;

  EventCounter get durableBytes =>
      EventCounter.fromJson(_data['durable_bytes']);

  String get id => _data['id'] as String;

  EventCounter get inputBytes => EventCounter.fromJson(_data['input_bytes']);

  int get kvstoreAvailableBytes => _data['kvstore_available_bytes'] as int;

  int get kvstoreFreeBytes => _data['kvstore_free_bytes'] as int;

  int get kvstoreTotalBytes => _data['kvstore_total_bytes'] as int;

  int get kvstoreUsedBytes => _data['kvstore_used_bytes'] as int;

  int get queueDiskAvailableBytes => _data['queue_disk_available_bytes'] as int;

  int get queueDiskFreeBytes => _data['queue_disk_free_bytes'] as int;

  int get queueDiskTotalBytes => _data['queue_disk_total_bytes'] as int;

  int get queueDiskUsedBytes => _data['queue_disk_used_bytes'] as int;
}

// sample:
// {
//   "bytes_queried": {
//     "counter": 404125985,
//     "hz": 5840.0699999999997,
//     "roughness": 2872.8699999999999
//   },
//   "data_lag": {
//     "seconds": 0.886965,
//     "versions": 886965
//   },
//   "data_version": 58892064583324,
//   "durability_lag": {
//     "seconds": 5,
//     "versions": 5000000
//   },
//   "durable_bytes": {
//     "counter": 7368120,
//     "hz": 0,
//     "roughness": -1
//   },
//   "durable_version": 58892059583324,
//   "fetched_versions": {
//     "counter": 65475858375,
//     "hz": 817598,
//     "roughness": 1421150
//   },
//   "fetches_from_logs": {
//     "counter": 73964,
//     "hz": 0.79957199999999995,
//     "roughness": 0.38981399999999999
//   },
//   "finished_queries": {
//     "counter": 541623,
//     "hz": 6.3965699999999996,
//     "roughness": 1.9395500000000001
//   },
//   "id": "9a28adf8f0b092b8",
//   "input_bytes": {
//     "counter": 7369244,
//     "hz": 224.68000000000001,
//     "roughness": 1123
//   },
//   "keys_queried": {
//     "counter": 1233008,
//     "hz": 16.191299999999998,
//     "roughness": 6.9676600000000004
//   },
//   "kvstore_available_bytes": 485394296832,
//   "kvstore_free_bytes": 485394296832,
//   "kvstore_inline_keys": 0,
//   "kvstore_total_bytes": 994662584320,
//   "kvstore_total_nodes": 0,
//   "kvstore_total_size": 0,
//   "kvstore_used_bytes": 213381120,
//   "local_rate": 100,
//   "low_priority_queries": {
//     "counter": 0,
//     "hz": 0,
//     "roughness": -1
//   },
//   "mutation_bytes": {
//     "counter": 280248,
//     "hz": 8.3955000000000002,
//     "roughness": 41
//   },
//   "mutations": {
//     "counter": 6547,
//     "hz": 0.19989299999999999,
//     "roughness": 0
//   },
//   "query_queue_max": 3,
//   "read_latency_statistics": {
//     "count": 401,
//     "max": 0.0053000499999999997,
//     "mean": 0.00029585400000000002,
//     "median": 0.00015497200000000002,
//     "min": 0.000026941300000000002,
//     "p25": 0.00010895700000000001,
//     "p90": 0.00047206900000000004,
//     "p95": 0.0010461800000000001,
//     "p99": 0.0029928699999999999,
//     "p99.9": 0.0053000499999999997
//   },
//   "role": "storage",
//   "storage_metadata": {
//     "created_time_datetime": "2024-02-22 12:39:18.000 +0000",
//     "created_time_timestamp": 1708610000.0000002
//   },
//   "stored_bytes": 77367000,
//   "total_queries": {
//     "counter": 541623,
//     "hz": 6.3965699999999996,
//     "roughness": 1.9395500000000001
//   }
// }
class StorageRoleInfo extends Role {
  StorageRoleInfo(dynamic data) : super(data);

  EventCounter get bytesQueried =>
      EventCounter.fromJson(_data['bytes_queried']);

  DatacenterLagInfo get dataLag => DatacenterLagInfo(_data['data_lag']);

  int get dataVersion => _data['data_version'] as int;

  DatacenterLagInfo get durabilityLag =>
      DatacenterLagInfo(_data['durability_lag']);

  EventCounter get durableBytes =>
      EventCounter.fromJson(_data['durable_bytes']);

  int get durableVersion => _data['durable_version'] as int;

  EventCounter get fetchedVersions =>
      EventCounter.fromJson(_data['fetched_versions']);

  EventCounter get fetchesFromLogs =>
      EventCounter.fromJson(_data['fetches_from_logs']);

  EventCounter get finishedQueries =>
      EventCounter.fromJson(_data['finished_queries']);

  String get id => _data['id'] as String;

  EventCounter get inputBytes => EventCounter.fromJson(_data['input_bytes']);

  EventCounter get keysQueried => EventCounter.fromJson(_data['keys_queried']);

  int get kvstoreAvailableBytes => _data['kvstore_available_bytes'] as int;

  int get kvstoreFreeBytes => _data['kvstore_free_bytes'] as int;

  int get kvstoreInlineKeys => _data['kvstore_inline_keys'] as int;

  int get kvstoreTotalBytes => _data['kvstore_total_bytes'] as int;

  int get kvstoreTotalNodes => _data['kvstore_total_nodes'] as int;

  int get kvstoreTotalSize => _data['kvstore_total_size'] as int;

  int get kvstoreUsedBytes => _data['kvstore_used_bytes'] as int;

  int get localRate => _data['local_rate'] as int;

  EventCounter get lowPriorityQueries =>
      EventCounter.fromJson(_data['low_priority_queries']);

  EventCounter get mutationBytes =>
      EventCounter.fromJson(_data['mutation_bytes']);

  EventCounter get mutations => EventCounter.fromJson(_data['mutations']);

  int get queryQueueMax => _data['query_queue_max'] as int;

  LatencyStatistics get readLatencyStatistics =>
      LatencyStatistics(_data['read_latency_statistics']);

  String get role => _data['role'] as String;

  StorageMetadata get storageMetadata => StorageMetadata(_data['storage_metadata']);

  int get storedBytes => _data['stored_bytes'] as int;

  EventCounter get totalQueries =>
      EventCounter.fromJson(_data['total_queries']);
}

class LatencyStatistics {
  final dynamic _data;

  LatencyStatistics(this._data);

  int get count => _data['count'] as int;

  num get max => _data['max'] as num;

  num get mean => _data['mean'] as num;

  num get median => _data['median'] as num;

  num get min => _data['min'] as num;

  num get p25 => _data['p25'] as num;

  num get p90 => _data['p90'] as num;

  num get p95 => _data['p95'] as num;

  num get p99 => _data['p99'] as num;

  num get p999 => _data['p99.9'] as num;
}

class StorageMetadata {
  final dynamic _data;

  StorageMetadata(this._data);

  String get createdTimeDatetime => _data['created_time_datetime'] as String;

  double get createdTimeTimestamp => _data['created_time_timestamp'] as double;
}

// sample:
// {
//   "commit_batching_window_size": {
//     "count": 32,
//     "max": 0.0025184700000000001,
//     "mean": 0.0022820399999999999,
//     "median": 0.0023,
//     "min": 0.0019340100000000001,
//     "p25": 0.0022006400000000002,
//     "p90": 0.00243772,
//     "p95": 0.0025083700000000002,
//     "p99": 0.0025184700000000001,
//     "p99.9": 0.0025184700000000001
//   },
//   "commit_latency_statistics": {
//     "count": 4,
//     "max": 0.029984,
//     "mean": 0.023799499999999998,
//     "median": 0.024367999999999997,
//     "min": 0.013767,
//     "p25": 0.013767,
//     "p90": 0.029984,
//     "p95": 0.029984,
//     "p99": 0.029984,
//     "p99.9": 0.029984
//   },
//   "id": "c8eafa7e69fe7423",
//   "role": "commit_proxy"
// }
class CommitProxyRoleInfo extends Role {
  CommitProxyRoleInfo(dynamic data) : super(data);

  LatencyStatistics get commitBatchingWindowSize =>
      LatencyStatistics(_data['commit_batching_window_size']);

  LatencyStatistics get commitLatencyStatistics =>
      LatencyStatistics(_data['commit_latency_statistics']);
}

// sample:
// {
//   "grv_latency_statistics": {
//     "batch": {
//       "count": 12,
//       "max": 0.001472,
//       "mean": 0.00060031800000000008,
//       "median": 0.00053596500000000001,
//       "min": 0.00021290800000000002,
//       "p25": 0.00030493700000000002,
//       "p90": 0.00092101100000000001,
//       "p95": 0.001472,
//       "p99": 0.001472,
//       "p99.9": 0.001472
//     },
//     "default": {
//       "count": 382,
//       "max": 0.0083129399999999996,
//       "mean": 0.0010091,
//       "median": 0.00056910500000000009,
//       "min": 0.00018906600000000002,
//       "p25": 0.000388861,
//       "p90": 0.0022349399999999999,
//       "p95": 0.0037770300000000002,
//       "p99": 0.0070450299999999999,
//       "p99.9": 0.0083129399999999996
//     }
//   },
//   "id": "4a551c70b1f3a8d9",
//   "role": "grv_proxy"
// }
class GRVProxyInfo extends Role {
  GRVProxyInfo(dynamic data) : super(data);

  LatencyStatistics get grvLatencyStatistics =>
      LatencyStatistics(_data['grv_latency_statistics']);
}

class CoordinatorRoleInfo extends Role {
  CoordinatorRoleInfo(dynamic data) : super(data);

  // Coordinators doesn't have id.
  @override
  String get id => "";
}

// sample:
// {
//   "grv_latency_statistics": {
//     "batch": {
//       "count": 0,
//       "max": 0,
//       "mean": 0,
//       "median": 0,
//       "min": 0,
//       "p25": 0,
//       "p90": 0,
//       "p95": 0,
//       "p99": 0,
//       "p99.9": 0
//     },
//     "default": {
//       "count": 333,
//       "max": 0.030861099999999999,
//       "mean": 0.00129638,
//       "median": 0.00057482700000000009,
//       "min": 0.00019908,
//       "p25": 0.00040507300000000004,
//       "p90": 0.0023870499999999999,
//       "p95": 0.0045688200000000003,
//       "p99": 0.010272999999999999,
//       "p99.9": 0.030861099999999999
//     }
//   },
//   "id": "4a551c70b1f3a8d9",
//   "role": "grv_proxy"
// }
class GRVProxyRoleInfo extends Role {
  GRVProxyRoleInfo(dynamic data) : super(data);

  GRVProxyLatencyStatistics get grvLatencyStatistics =>
      GRVProxyLatencyStatistics(_data['grv_latency_statistics']);
}

class GRVProxyLatencyStatistics {
  final dynamic _data;

  GRVProxyLatencyStatistics(this._data);

  LatencyStatistics get batch => LatencyStatistics(_data['batch']);

  LatencyStatistics get defaultStats => LatencyStatistics(_data['default']);
}

// sample:
// {
//   "batch_performance_limited_by": {
//     "description": "The database is not being saturated by the workload.",
//     "name": "workload",
//     "reason_id": 2
//   },
//   "batch_released_transactions_per_second": 0.034379399999999997,
//   "batch_transactions_per_second_limit": 141407000.00000003,
//   "limiting_data_lag_storage_server": {
//     "seconds": 0,
//     "versions": 0
//   },
//   "limiting_durability_lag_storage_server": {
//     "seconds": 5.0726100000000001,
//     "versions": 5072608
//   },
//   "limiting_queue_bytes_storage_server": 287,
//   "performance_limited_by": {
//     "description": "The database is not being saturated by the workload.",
//     "name": "workload",
//     "reason_id": 2
//   },
//   "released_transactions_per_second": 4.5098900000000004,
//   "throttled_tags": {
//     "auto": {
//       "busy_read": 0,
//       "busy_write": 0,
//       "count": 0,
//       "recommended_only": 0
//     },
//     "manual": {
//       "count": 0
//     }
//   },
//   "transactions_per_second_limit": 680007000,
//   "worst_data_lag_storage_server": {
//     "seconds": 0,
//     "versions": 0
//   },
//   "worst_durability_lag_storage_server": {
//     "seconds": 5.0726100000000001,
//     "versions": 5072608
//   },
//   "worst_queue_bytes_log_server": 163,
//   "worst_queue_bytes_storage_server": 289
// }
class QoSInfo {
  final dynamic _data;

  QoSInfo(this._data);

  QoSData get batchPerformanceLimitedBy =>
      QoSData(_data['batch_performance_limited_by']);

  double get batchReleasedTransactionsPerSecond =>
      _data['batch_released_transactions_per_second'] as double;

  double get batchTransactionsPerSecondLimit =>
      _data['batch_transactions_per_second_limit'] as double;

  DatacenterLagInfo get limitingDataLagStorageServer =>
      DatacenterLagInfo(_data['limiting_data_lag_storage_server']);

  DatacenterLagInfo get limitingDurabilityLagStorageServer =>
      DatacenterLagInfo(_data['limiting_durability_lag_storage_server']);

  int get limitingQueueBytesStorageServer =>
      _data['limiting_queue_bytes_storage_server'] as int;

  QoSData get performanceLimitedBy => QoSData(_data['performance_limited_by']);

  double get releasedTransactionsPerSecond =>
      _data['released_transactions_per_second'] as double;

  Map<String, dynamic> get throttledTags =>
      _data['throttled_tags'] as Map<String, dynamic>;

  int get transactionsPerSecondLimit =>
      _data['transactions_per_second_limit'] as int;

  DatacenterLagInfo get worstDataLagStorageServer =>
      DatacenterLagInfo(_data['worst_data_lag_storage_server']);

  DatacenterLagInfo get worstDurabilityLagStorageServer =>
      DatacenterLagInfo(_data['worst_durability_lag_storage_server']);

  int get worstQueueBytesLogServer =>
      _data['worst_queue_bytes_log_server'] as int;

  int get worstQueueBytesStorageServer =>
      _data['worst_queue_bytes_storage_server'] as int;
}

class QoSData {
  final dynamic _data;

  QoSData(this._data);

  String get description => _data['description'] as String;

  String get name => _data['name'] as String;

  int get reasonID => _data['reason_id'] as int;
}

// sample:
// {
//   "active_generations": 1,
//   "description": "Recovery complete.",
//   "name": "fully_recovered",
//   "seconds_since_last_recovered": 10244.6
// }
class RecoveryStateInfo {
  final dynamic _data;

  RecoveryStateInfo(this._data);

  int get activeGenerations => _data['active_generations'] as int;

  String get description => _data['description'] as String;

  String get name => _data['name'] as String;

  double get secondsSinceLastRecovered =>
      _data['seconds_since_last_recovered'] as double;
}

// sample:
// {
//   "bytes": {
//     "read": {
//       "counter": 67531418,
//       "hz": 6586.0699999999997,
//       "roughness": 5657.2299999999996
//     },
//     "written": {
//       "counter": 313293,
//       "hz": 14.373799999999999,
//       "roughness": 71
//     }
//   },
//   "keys": {
//     "read": {
//       "counter": 212730,
//       "hz": 20.778099999999998,
//       "roughness": 16.9056
//     }
//   },
//   "operations": {
//     "location_requests": {
//       "counter": 4102,
//       "hz": 0.399594,
//       "roughness": 0
//     },
//     "low_priority_reads": {
//       "counter": 0,
//       "hz": 0,
//       "roughness": 0
//     },
//     "memory_errors": {
//       "counter": 0,
//       "hz": 0,
//       "roughness": 0
//     },
//     "read_requests": {
//       "counter": 215113,
//       "hz": 19.988199999999999,
//       "roughness": 5.7924300000000004
//     },
//     "reads": {
//       "counter": 215113,
//       "hz": 19.988199999999999,
//       "roughness": 5.7924300000000004
//     },
//     "writes": {
//       "counter": 2327,
//       "hz": 0.39927199999999996,
//       "roughness": 1
//     }
//   },
//   "transactions": {
//     "committed": {
//       "counter": 3299,
//       "hz": 0.399594,
//       "roughness": 0
//     },
//     "conflicted": {
//       "counter": 1,
//       "hz": 0,
//       "roughness": 0
//     },
//     "rejected_for_queued_too_long": {
//       "counter": 0,
//       "hz": 0,
//       "roughness": 0
//     },
//     "started": {
//       "counter": 76631,
//       "hz": 7.5979099999999997,
//       "roughness": 2.13957
//     },
//     "started_batch_priority": {
//       "counter": 2002,
//       "hz": 0.19994499999999998,
//       "roughness": 0
//     },
//     "started_default_priority": {
//       "counter": 45379,
//       "hz": 4.39879,
//       "roughness": 0.87644499999999992
//     },
//     "started_immediate_priority": {
//       "counter": 29250,
//       "hz": 2.99918,
//       "roughness": 1.73841
//     }
//   }
// }
class WorkloadInfo {
  final dynamic _data;

  WorkloadInfo(this._data);

  WorkloadBytesInfo get bytes => WorkloadBytesInfo(_data['bytes']);

  WorkloadKeysInfo get keys => WorkloadKeysInfo(_data['keys']);

  WorkloadOperationsInfo get operations =>
      WorkloadOperationsInfo(_data['operations']);

  WorkloadTransactionsInfo get transactions =>
      WorkloadTransactionsInfo(_data['transactions']);
}

class WorkloadBytesInfo {
  final dynamic _data;

  WorkloadBytesInfo(this._data);

  EventCounter get read => EventCounter.fromJson(_data['read']);

  EventCounter get written => EventCounter.fromJson(_data['written']);
}

class WorkloadKeysInfo {
  final dynamic _data;

  WorkloadKeysInfo(this._data);

  EventCounter get read => EventCounter.fromJson(_data['read']);
}

class WorkloadOperationsInfo {
  final dynamic _data;

  WorkloadOperationsInfo(this._data);

  EventCounter get locationRequests =>
      EventCounter.fromJson(_data['location_requests']);

  EventCounter get lowPriorityReads =>
      EventCounter.fromJson(_data['low_priority_reads']);

  EventCounter get memoryErrors =>
      EventCounter.fromJson(_data['memory_errors']);

  EventCounter get readRequests =>
      EventCounter.fromJson(_data['read_requests']);

  EventCounter get reads => EventCounter.fromJson(_data['reads']);

  EventCounter get writes => EventCounter.fromJson(_data['writes']);
}

class WorkloadTransactionsInfo {
  final dynamic _data;

  WorkloadTransactionsInfo(this._data);

  EventCounter get committed => EventCounter.fromJson(_data['committed']);

  EventCounter get conflicted => EventCounter.fromJson(_data['conflicted']);

  EventCounter get rejectedForQueuedTooLong =>
      EventCounter.fromJson(_data['rejected_for_queued_too_long']);

  EventCounter get started => EventCounter.fromJson(_data['started']);

  EventCounter get startedBatchPriority =>
      EventCounter.fromJson(_data['started_batch_priority']);

  EventCounter get startedDefaultPriority =>
      EventCounter.fromJson(_data['started_default_priority']);

  EventCounter get startedImmediatePriority =>
      EventCounter.fromJson(_data['started_immediate_priority']);
}
