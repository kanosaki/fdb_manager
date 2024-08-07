import 'package:fdb_manager/models/status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('client', () {
    final client = InstantStatus(sampleJson).client;
    expect(client.clusterFile.path, '/usr/local/etc/foundationdb/fdb.cluster');
    expect(client.clusterFile.upToDate, true);
    expect(client.coordinators.coordinators.length, 1);
    expect(client.coordinators.coordinators[0].address, '127.0.0.1:4689');
    expect(client.coordinators.coordinators[0].protocol, '0fdb00b071010000');
    expect(client.coordinators.coordinators[0].reachable, true);
    expect(client.coordinators.quorumReachable, true);
    expect(client.databaseStatus.available, true);
    expect(client.databaseStatus.healthy, true);
    expect(client.messages, isEmpty);
    expect(client.timestamp, 1722691467);
  });

  test('cluster: primitive fields', () {
    final cluster = InstantStatus(sampleJson).cluster;
    expect(cluster.activePrimaryDC, 'abc');
    expect(cluster.bounceImpact.canCleanBounce, true);
    expect(cluster.activeTSSCount, 0);
    expect(cluster.clusterControllerTimestamp, 1722691467);
    expect(cluster.connectionString, 'f2ZNMI9C:7iWTlmxx@127.0.0.1:4689');
    expect(cluster.databaseAvailable, true);

    expect(cluster.databaseLockState.locked, false);
    expect(cluster.datacenterLag.seconds, 0);
    expect(cluster.datacenterLag.versions, 0);
    expect(cluster.degradedProcesses, 0);
    expect(cluster.fullReplication, true);
    expect(cluster.generation, 316);
    expect(cluster.incompatibleConnections, isEmpty);
    expect(cluster.protocolVersion, 'fdb00b071010000');
  });

  test('cluster.clients', () {
    final clients = InstantStatus(sampleJson).cluster.clients;
    expect(clients.count, 2);
    expect(clients.supportedVersions.length, 1);
    final version = clients.supportedVersions[0];
    expect(version.clientVersion, '7.1.40');
    expect(version.connectedClients.length, 2);
    expect(version.connectedClients[0].address, '127.0.0.1:59876');
    expect(version.connectedClients[0].logGroup, 'default');
    expect(version.maxProtocolClients[1].address, '127.0.0.1:60544');
    expect(version.maxProtocolClients[1].logGroup, 'default');
    expect(version.maxProtocolCount, 2);
    expect(version.protocolVersion, 'fdb00b071010000');
    expect(version.sourceVersion, '3f31504f0e11fee14ee70248336229a9cc460eea');
  });

  test('cluster.configuration', () {
    final configuration = InstantStatus(sampleJson).cluster.configuration;
    expect(configuration.backupWorkerEnabled, 0);
    expect(configuration.blobGranulesEnabled, 0);
    expect(configuration.coordinatorsCount, 1);
    expect(configuration.excludedServers, isEmpty);
    expect(configuration.logSpill, 2);
    expect(configuration.perpetualStorageWiggle, 0);
    expect(configuration.perpetualStorageWiggleEngine, 'none');
    expect(configuration.perpetualStorageWiggleLocality, '0');
    expect(configuration.redundancyMode, 'single');
    expect(configuration.storageEngine, 'ssd-2');
    expect(configuration.storageMigrationType, 'disabled');
    expect(configuration.tenantMode, 'disabled');
    expect(configuration.usableRegions, 1);
  });

  test('clsuter.data', () {
    final data = InstantStatus(sampleJson).cluster.data;
    expect(data.averagePartitionSizeBytes, 21130760);
    expect(data.leastOperatingSpaceBytesLogServer, 435931681173);
    expect(data.leastOperatingSpaceBytesStorageServer, 435931681133);
    expect(data.movingData.highestPriority, 0);
    expect(data.movingData.inFlightBytes, 0);
    expect(data.movingData.inQueueBytes, 0);
    expect(data.movingData.totalWrittenBytes, 0);
    expect(data.partitionsCount, 9);
    expect(data.state.healthy, true);
    expect(data.state.minReplicasRemaining, 1);
    expect(data.state.name, 'healthy');
    expect(data.systemKVSizeBytes, 147569250);
    expect(data.teamTrackers.length, 1);
    expect(data.teamTrackers[0].inFlightBytes, 0);
    expect(data.teamTrackers[0].primary, true);
    expect(data.teamTrackers[0].state.healthy, true);
    expect(data.teamTrackers[0].state.minReplicasRemaining, 1);
    expect(data.teamTrackers[0].state.name, 'healthy');
    expect(data.teamTrackers[0].unhealthyServers, 0);
    expect(data.totalDiskUsedBytes, 761929904);
    expect(data.totalKVSizeBytes, 157901250);
  });

  test('cluster.layers', () {
    final layers = InstantStatus(sampleJson).cluster.layers;
    expect(layers.valid, true);
    expect(layers.error, null);
    expect(layers.backup.instances.length, 1);
    final backup = layers.backup.instances['06477be4acbe6f9d9b9c3b55773ea5a4']!;
    expect(backup.blobStats.recent.bytesPerSecond, 0);
    expect(backup.blobStats.recent.bytesSent, 0);
    expect(backup.blobStats.recent.requestsFailed, 0);
    expect(backup.blobStats.recent.requestsSuccessful, 0);
    expect(backup.blobStats.total.bytesSent, 0);
    expect(backup.blobStats.total.requestsFailed, 0);
    expect(backup.blobStats.total.requestsSuccessful, 0);
    expect(backup.configuredWorkers, 10);
    expect(backup.id, '06477be4acbe6f9d9b9c3b55773ea5a4');
    expect(backup.lastUpdated, 1722635963.386173);
    expect(backup.mainThreadCpuSeconds, 307.81969399999997);
    expect(backup.memoryUsage, 420971446272);
    expect(backup.processCpuSeconds, 339.93697000000003);
    expect(backup.residentSize, 18989056);
    expect(backup.version, '7.1.40');
    expect(layers.backup.instancesRunning, 1);
    expect(layers.backup.lastUpdated, 1722635963.386173);
    expect(layers.backup.paused, false);
    expect(layers.backup.tags, {});
    expect(layers.backup.totalWorkers, 10);
  });

  test('cluster.logs', () {
    final logs = InstantStatus(sampleJson).cluster.logs;
    expect(logs.length, 1);
    final log = logs[0];
    expect(log.beginVersion, 58826593724949);
    expect(log.current, true);
    expect(log.epoch, 316);
    expect(log.logFaultTolerance, 0);
    expect(log.logInterfaces.length, 2);
    expect(log.logInterfaces[0].address, '127.0.0.1:4692');
    expect(log.logInterfaces[0].healthy, true);
    expect(log.logInterfaces[0].id, '90ca4eed5846876e');
    expect(log.logReplicationFactor, 1);
    expect(log.logWriteAntiQuorum, 0);
    expect(log.possiblyLosingData, false);
  });

  test('cluster.machines', () {
    final machines = InstantStatus(sampleJson).cluster.machines;
    expect(machines.length, 1);
    final machine = machines['9c7af1a02294582cfa6158311c593879']!;
    expect(machine.address, '127.0.0.1');
    expect(machine.contributingWorkers, 4);
    expect(machine.logicalCoreUtilization, 0.25488899999999998);
    expect(machine.excluded, false);
    expect(machine.locality.machineID, '9c7af1a02294582cfa6158311c593879');
    expect(machine.locality.processID, 'fec1d44658890fb0141475b662fb2d71');
    expect(machine.locality.zoneID, '9c7af1a02294582cfa6158311c593879');
    expect(machine.memory.committedBytes, 30325342208);
    expect(machine.memory.freeBytes, 70451200);
    expect(machine.memory.totalBytes, 30395793408);
    expect(machine.network.megabitsReceivedHz, 0);
    expect(machine.network.megabitsSentHz, 0);
    expect(machine.network.tcpSegmentsRetransmittedHz, 0);
  });

  test('cluster.qos', () {
    final qos = InstantStatus(sampleJson).cluster.qos;
    expect(qos.batchPerformanceLimitedBy.description,
        'The database is not being saturated by the workload.');
    expect(qos.batchPerformanceLimitedBy.name, 'workload');
    expect(qos.batchPerformanceLimitedBy.reasonID, 2);
    expect(qos.batchReleasedTransactionsPerSecond, 0.034379399999999997);
    expect(qos.batchTransactionsPerSecondLimit, 141407000.00000003);
  });

  test('cluster.recoverystate', () {
    final recoveryState = InstantStatus(sampleJson).cluster.recoveryState;
    expect(recoveryState.activeGenerations, 1);
    expect(recoveryState.description, 'Recovery complete.');
    expect(recoveryState.name, 'fully_recovered');
    expect(recoveryState.secondsSinceLastRecovered, 10244.6);
  });

  test('cluster.workload', () {
    final workload = InstantStatus(sampleJson).cluster.workload;
    expect(workload.bytes.read.counter, 67531418);
    expect(workload.bytes.read.hz, 6586.0699999999997);
    expect(workload.bytes.read.roughness, 5657.2299999999996);
    expect(workload.bytes.written.counter, 313293);
    expect(workload.bytes.written.hz, 14.373799999999999);
    expect(workload.bytes.written.roughness, 71);
    expect(workload.keys.read.counter, 212730);
    expect(workload.keys.read.hz, 20.778099999999998);
    expect(workload.keys.read.roughness, 16.9056);
    expect(workload.operations.locationRequests.counter, 4102);
    expect(workload.operations.locationRequests.hz, 0.399594);
    expect(workload.operations.locationRequests.roughness, 0);
    expect(workload.operations.lowPriorityReads.counter, 0);
    expect(workload.operations.lowPriorityReads.hz, 0);
    expect(workload.operations.lowPriorityReads.roughness, 0);
    expect(workload.operations.memoryErrors.counter, 0);
    expect(workload.operations.memoryErrors.hz, 0);
    expect(workload.operations.memoryErrors.roughness, 0);
    expect(workload.operations.readRequests.counter, 215113);
    expect(workload.operations.readRequests.hz, 19.988199999999999);
    expect(workload.operations.readRequests.roughness, 5.7924300000000004);
    expect(workload.operations.reads.counter, 215113);
    expect(workload.operations.reads.hz, 19.988199999999999);
    expect(workload.operations.reads.roughness, 5.7924300000000004);
    expect(workload.operations.writes.counter, 2327);
    expect(workload.operations.writes.hz, 0.39927199999999996);
    expect(workload.operations.writes.roughness, 1);
    expect(workload.transactions.committed.counter, 3299);
    expect(workload.transactions.committed.hz, 0.399594);
    expect(workload.transactions.committed.roughness, 0);
    expect(workload.transactions.conflicted.counter, 1);
    expect(workload.transactions.conflicted.hz, 0);
    expect(workload.transactions.conflicted.roughness, 0);
    expect(workload.transactions.rejectedForQueuedTooLong.counter, 0);
    expect(workload.transactions.rejectedForQueuedTooLong.hz, 0);
    expect(workload.transactions.rejectedForQueuedTooLong.roughness, 0);
    expect(workload.transactions.started.counter, 76631);
    expect(workload.transactions.started.hz, 7.5979099999999997);
    expect(workload.transactions.started.roughness, 2.13957);
    expect(workload.transactions.startedBatchPriority.counter, 2002);
    expect(workload.transactions.startedBatchPriority.hz, 0.19994499999999998);
    expect(workload.transactions.startedBatchPriority.roughness, 0);
    expect(workload.transactions.startedDefaultPriority.counter, 45379);
    expect(workload.transactions.startedDefaultPriority.hz, 4.39879);
    expect(workload.transactions.startedDefaultPriority.roughness, 0.87644499999999992);
    expect(workload.transactions.startedImmediatePriority.counter, 29250);
    expect(workload.transactions.startedImmediatePriority.hz, 2.99918);
    expect(workload.transactions.startedImmediatePriority.roughness, 1.73841);

  });
}

const sampleJson = {
  "client": {
    "cluster_file": {
      "path": "/usr/local/etc/foundationdb/fdb.cluster",
      "up_to_date": true
    },
    "coordinators": {
      "coordinators": [
        {
          "address": "127.0.0.1:4689",
          "protocol": "0fdb00b071010000",
          "reachable": true
        }
      ],
      "quorum_reachable": true
    },
    "database_status": {"available": true, "healthy": true},
    "messages": [],
    "timestamp": 1722691467
  },
  "cluster": {
    "active_primary_dc": "abc",
    "active_tss_count": 0,
    "bounce_impact": {"can_clean_bounce": true},
    "clients": {
      "count": 2,
      "supported_versions": [
        {
          "client_version": "7.1.40",
          "connected_clients": [
            {"address": "127.0.0.1:59876", "log_group": "default"},
            {"address": "127.0.0.1:60544", "log_group": "default"}
          ],
          "count": 2,
          "max_protocol_clients": [
            {"address": "127.0.0.1:59876", "log_group": "default"},
            {"address": "127.0.0.1:60544", "log_group": "default"}
          ],
          "max_protocol_count": 2,
          "protocol_version": "fdb00b071010000",
          "source_version": "3f31504f0e11fee14ee70248336229a9cc460eea"
        }
      ]
    },
    "cluster_controller_timestamp": 1722691467,
    "configuration": {
      "backup_worker_enabled": 0,
      "blob_granules_enabled": 0,
      "coordinators_count": 1,
      "excluded_servers": [],
      "log_spill": 2,
      "perpetual_storage_wiggle": 0,
      "perpetual_storage_wiggle_engine": "none",
      "perpetual_storage_wiggle_locality": "0",
      "redundancy_mode": "single",
      "storage_engine": "ssd-2",
      "storage_migration_type": "disabled",
      "tenant_mode": "disabled",
      "usable_regions": 1
    },
    "connection_string": "f2ZNMI9C:7iWTlmxx@127.0.0.1:4689",
    "data": {
      "average_partition_size_bytes": 21130760,
      "least_operating_space_bytes_log_server": 435931681173,
      "least_operating_space_bytes_storage_server": 435931681133,
      "moving_data": {
        "highest_priority": 0,
        "in_flight_bytes": 0,
        "in_queue_bytes": 0,
        "total_written_bytes": 0
      },
      "partitions_count": 9,
      "state": {
        "healthy": true,
        "min_replicas_remaining": 1,
        "name": "healthy"
      },
      "system_kv_size_bytes": 147569250,
      "team_trackers": [
        {
          "in_flight_bytes": 0,
          "primary": true,
          "state": {
            "healthy": true,
            "min_replicas_remaining": 1,
            "name": "healthy"
          },
          "unhealthy_servers": 0
        }
      ],
      "total_disk_used_bytes": 761929904,
      "total_kv_size_bytes": 157901250
    },
    "database_available": true,
    "database_lock_state": {"locked": false},
    "datacenter_lag": {"seconds": 0, "versions": 0},
    "degraded_processes": 0,
    "fault_tolerance": {
      "max_zone_failures_without_losing_availability": 0,
      "max_zone_failures_without_losing_data": 0
    },
    "full_replication": true,
    "generation": 316,
    "incompatible_connections": [],
    "latency_probe": {
      "batch_priority_transaction_start_seconds": 0.0010979200000000001,
      "commit_seconds": 0.019460000000000002,
      "immediate_priority_transaction_start_seconds": 0.0010500000000000002,
      "read_seconds": 0.00023150400000000003,
      "transaction_start_seconds": 0.00178123
    },
    "layers": {
      "_valid": true,
      "backup": {
        "blob_recent_io": {
          "bytes_per_second": 0,
          "bytes_sent": 0,
          "requests_failed": 0,
          "requests_successful": 0
        },
        "instances": {
          "06477be4acbe6f9d9b9c3b55773ea5a4": {
            "blob_stats": {
              "recent": {
                "bytes_per_second": 0,
                "bytes_sent": 0,
                "requests_failed": 0,
                "requests_successful": 0
              },
              "total": {
                "bytes_sent": 0,
                "requests_failed": 0,
                "requests_successful": 0
              }
            },
            "configured_workers": 10,
            "id": "06477be4acbe6f9d9b9c3b55773ea5a4",
            "last_updated": 1722635963.386173,
            "main_thread_cpu_seconds": 307.81969399999997,
            "memory_usage": 420971446272,
            "process_cpu_seconds": 339.93697000000003,
            "resident_size": 18989056,
            "version": "7.1.40"
          }
        },
        "instances_running": 1,
        "last_updated": 1722635963.386173,
        "paused": false,
        "tags": {},
        "total_workers": 10
      }
    },
    "logs": [
      {
        "begin_version": 58826593724949,
        "current": true,
        "epoch": 316,
        "log_fault_tolerance": 0,
        "log_interfaces": [
          {
            "address": "127.0.0.1:4692",
            "healthy": true,
            "id": "90ca4eed5846876e"
          },
          {
            "address": "127.0.0.1:4689",
            "healthy": true,
            "id": "a9eeda4eda306176"
          }
        ],
        "log_replication_factor": 1,
        "log_write_anti_quorum": 0,
        "possibly_losing_data": false
      }
    ],
    "machines": {
      "9c7af1a02294582cfa6158311c593879": {
        "address": "127.0.0.1",
        "contributing_workers": 4,
        "cpu": {"logical_core_utilization": 0.25488899999999998},
        "excluded": false,
        "locality": {
          "machineid": "9c7af1a02294582cfa6158311c593879",
          "processid": "fec1d44658890fb0141475b662fb2d71",
          "zoneid": "9c7af1a02294582cfa6158311c593879"
        },
        "machine_id": "9c7af1a02294582cfa6158311c593879",
        "memory": {
          "committed_bytes": 30325342208,
          "free_bytes": 70451200,
          "total_bytes": 30395793408
        },
        "network": {
          "megabits_received": {"hz": 0},
          "megabits_sent": {"hz": 0},
          "tcp_segments_retransmitted": {"hz": 0}
        }
      }
    },
    "messages": [],
    "page_cache": {"log_hit_rate": 1, "storage_hit_rate": 1},
    "processes": {},
    "protocol_version": "fdb00b071010000",
    "qos": {
      "batch_performance_limited_by": {
        "description": "The database is not being saturated by the workload.",
        "name": "workload",
        "reason_id": 2
      },
      "batch_released_transactions_per_second": 0.034379399999999997,
      "batch_transactions_per_second_limit": 141407000.00000003,
      "limiting_data_lag_storage_server": {"seconds": 0, "versions": 0},
      "limiting_durability_lag_storage_server": {
        "seconds": 5.0726100000000001,
        "versions": 5072608
      },
      "limiting_queue_bytes_storage_server": 287,
      "performance_limited_by": {
        "description": "The database is not being saturated by the workload.",
        "name": "workload",
        "reason_id": 2
      },
      "released_transactions_per_second": 4.5098900000000004,
      "throttled_tags": {
        "auto": {
          "busy_read": 0,
          "busy_write": 0,
          "count": 0,
          "recommended_only": 0
        },
        "manual": {"count": 0}
      },
      "transactions_per_second_limit": 680007000,
      "worst_data_lag_storage_server": {"seconds": 0, "versions": 0},
      "worst_durability_lag_storage_server": {
        "seconds": 5.0726100000000001,
        "versions": 5072608
      },
      "worst_queue_bytes_log_server": 163,
      "worst_queue_bytes_storage_server": 289
    },
    "recovery_state": {
      "active_generations": 1,
      "description": "Recovery complete.",
      "name": "fully_recovered",
      "seconds_since_last_recovered": 10244.6
    },
    "workload": {
      "bytes": {
        "read": {
          "counter": 67531418,
          "hz": 6586.0699999999997,
          "roughness": 5657.2299999999996
        },
        "written": {
          "counter": 313293,
          "hz": 14.373799999999999,
          "roughness": 71
        }
      },
      "keys": {
        "read": {
          "counter": 212730,
          "hz": 20.778099999999998,
          "roughness": 16.9056
        }
      },
      "operations": {
        "location_requests": {"counter": 4102, "hz": 0.399594, "roughness": 0},
        "low_priority_reads": {"counter": 0, "hz": 0, "roughness": 0},
        "memory_errors": {"counter": 0, "hz": 0, "roughness": 0},
        "read_requests": {
          "counter": 215113,
          "hz": 19.988199999999999,
          "roughness": 5.7924300000000004
        },
        "reads": {
          "counter": 215113,
          "hz": 19.988199999999999,
          "roughness": 5.7924300000000004
        },
        "writes": {"counter": 2327, "hz": 0.39927199999999996, "roughness": 1}
      },
      "transactions": {
        "committed": {"counter": 3299, "hz": 0.399594, "roughness": 0},
        "conflicted": {"counter": 1, "hz": 0, "roughness": 0},
        "rejected_for_queued_too_long": {"counter": 0, "hz": 0, "roughness": 0},
        "started": {
          "counter": 76631,
          "hz": 7.5979099999999997,
          "roughness": 2.13957
        },
        "started_batch_priority": {
          "counter": 2002,
          "hz": 0.19994499999999998,
          "roughness": 0
        },
        "started_default_priority": {
          "counter": 45379,
          "hz": 4.39879,
          "roughness": 0.87644499999999992
        },
        "started_immediate_priority": {
          "counter": 29250,
          "hz": 2.99918,
          "roughness": 1.73841
        }
      }
    }
  }
};
