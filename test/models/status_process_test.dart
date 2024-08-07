import 'package:fdb_manager/models/status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cluster.processes', () {
    final processes = processJsonMap.map((key, value) =>
        MapEntry(key, ProcessInfo(value)));
    final process1 = processes['164e2bfa10a839e3d22140458435cd13']!;
    expect(process1.address, '127.0.0.1:4690');
    expect(process1.cpuUsageCores, 0.0312015);
    expect(process1.disk.busy, 0.050798599999999999);
    expect(process1.disk.freeBytes, 485664808960);
    expect(process1.disk.reads.counter, 4744343);
    expect(process1.disk.reads.hz, 133.196);
    expect(process1.disk.reads.sectors, 0);
    expect(process1.disk.totalBytes, 994662584320);
    expect(process1.disk.writes.counter, 19643911);
    expect(process1.disk.writes.hz, 237.19300000000001);
    expect(process1.disk.writes.sectors, 0);
    expect(process1.excluded, false);
    expect(process1.faultDomain, '9c7af1a02294582cfa6158311c593879');
    expect(process1.locality.machineID, '9c7af1a02294582cfa6158311c593879');
    expect(process1.locality.processID, '164e2bfa10a839e3d22140458435cd13');
    expect(process1.locality.zoneID, '9c7af1a02294582cfa6158311c593879');
    expect(process1.machineID, '9c7af1a02294582cfa6158311c593879');
    expect(process1.memory.availableBytes, 73883648);
    expect(process1.memory.limitBytes, 8589934592);
    expect(process1.memory.rssBytes, 51953664);
    expect(process1.memory.unusedAllocatedMemory, 0);
    expect(process1.memory.usedBytes, 422001360896);
    expect(process1.messages, isEmpty);
    expect(process1.network.connectionErrorsHz, 0);
    expect(process1.network.connectionsClosedHz, 0);
    expect(process1.network.connectionsEstablishedHz, 0);
    expect(process1.network.currentConnections, 4);
    expect(process1.network.mbpsReceived, 0.21074599999999999);
    expect(process1.network.mbpsSent, 0.170542);
    expect(process1.network.tlsPolicyFailuresHz, 0);
    expect(process1.roles.length, 5);
  });

  test('cluster.processes_role(storage)', () {
    final role = ProcessInfo(processJsonMap['164e2bfa10a839e3d22140458435cd13'])
        .roles[4];
    final storage = role as StorageRoleInfo;
    expect(storage.bytesQueried.counter, 0);
    expect(storage.bytesQueried.hz, 0);
    expect(storage.bytesQueried.roughness, -1);
    expect(storage.dataLag.seconds, 1.6302099999999999);
    expect(storage.dataLag.versions, 1630211);
    expect(storage.dataVersion, 58836935894911);
    expect(storage.durabilityLag.seconds, 5);
    expect(storage.durabilityLag.versions, 5000000);
    expect(storage.durableBytes.counter, 1934);
    expect(storage.durableBytes.hz, 0);
    expect(storage.durableBytes.roughness, -1);
    expect(storage.durableVersion, 58836930894911);
    expect(storage.fetchedVersions.counter, 10347169962);
    expect(storage.fetchedVersions.hz, 999559);
    expect(storage.fetchedVersions.roughness, 1323580);
    expect(storage.fetchesFromLogs.counter, 11931);
    expect(storage.fetchesFromLogs.hz, 0.99956099999999992);
    expect(storage.fetchesFromLogs.roughness, 0.32358399999999998);
    expect(storage.finishedQueries.counter, 0);
    expect(storage.finishedQueries.hz, 0);
    expect(storage.finishedQueries.roughness, -1);
    expect(storage.inputBytes.counter, 1934);
    expect(storage.inputBytes.hz, 0);
    expect(storage.inputBytes.roughness, -1);
    expect(storage.keysQueried.counter, 0);
    expect(storage.keysQueried.hz, 0);
    expect(storage.keysQueried.roughness, -1);
    expect(storage.kvstoreAvailableBytes, 485664813056);
    expect(storage.kvstoreFreeBytes, 485664813056);
    expect(storage.kvstoreInlineKeys, 0);
    expect(storage.kvstoreTotalBytes, 994662584320);
    expect(storage.kvstoreTotalNodes, 0);
    expect(storage.kvstoreTotalSize, 0);
    expect(storage.kvstoreUsedBytes, 108486656);
    expect(storage.localRate, 100);
    expect(storage.lowPriorityQueries.counter, 0);
    expect(storage.lowPriorityQueries.hz, 0);
    expect(storage.lowPriorityQueries.roughness, -1);
    expect(storage.mutationBytes.counter, 82);
    expect(storage.mutationBytes.hz, 0);
    expect(storage.mutationBytes.roughness, -1);
    expect(storage.mutations.counter, 2);
    expect(storage.mutations.hz, 0);
    expect(storage.mutations.roughness, -1);
    expect(storage.queryQueueMax, 0);
    expect(storage.readLatencyStatistics.count, 0);
    expect(storage.readLatencyStatistics.max, 0);
    expect(storage.readLatencyStatistics.mean, 0);
    expect(storage.readLatencyStatistics.median, 0);
    expect(storage.readLatencyStatistics.min, 0);
    expect(storage.readLatencyStatistics.p25, 0);
    expect(storage.readLatencyStatistics.p90, 0);
    expect(storage.readLatencyStatistics.p95, 0);
    expect(storage.readLatencyStatistics.p99, 0);
    expect(storage.readLatencyStatistics.p999, 0);
    expect(storage.role, 'storage');
    expect(storage.storageMetadata.createdTimeDatetime,
        '2024-03-18 12:59:36.000 +0000');
    expect(storage.storageMetadata.createdTimeTimestamp, 1710770000.0000002);
    expect(storage.storedBytes, 18542250);
    expect(storage.totalQueries.counter, 0);
    expect(storage.totalQueries.hz, 0);
    expect(storage.totalQueries.roughness, -1);
  });

  test('cluster.processes_role(grv_proxy)', () {
    final role = ProcessInfo(processJsonMap['164e2bfa10a839e3d22140458435cd13'])
        .roles[3];
    final grvProxy = role as GRVProxyRoleInfo;
    expect(grvProxy.grvLatencyStatistics.batch.count, 12);
    expect(grvProxy.grvLatencyStatistics.batch.max, 0.001472);
    expect(grvProxy.grvLatencyStatistics.batch.mean, 0.00060031800000000008);
    expect(grvProxy.grvLatencyStatistics.batch.median,
        0.00053596500000000001);
    expect(grvProxy.grvLatencyStatistics.batch.min, 0.00021290800000000002);
    expect(grvProxy.grvLatencyStatistics.batch.p25, 0.00030493700000000002);
    expect(grvProxy.grvLatencyStatistics.batch.p90, 0.00092101100000000001);
    expect(grvProxy.grvLatencyStatistics.batch.p95, 0.001472);
    expect(grvProxy.grvLatencyStatistics.batch.p99, 0.001472);
    expect(grvProxy.grvLatencyStatistics.batch.p999, 0.001472);
    expect(grvProxy.grvLatencyStatistics.defaultStats.count, 382);
    expect(
        grvProxy.grvLatencyStatistics.defaultStats.max, 0.0083129399999999996);
    expect(grvProxy.grvLatencyStatistics.defaultStats.mean, 0.0010091);
    expect(grvProxy.grvLatencyStatistics.defaultStats.median,
        0.00056910500000000009);
    expect(
        grvProxy.grvLatencyStatistics.defaultStats.min, 0.00018906600000000002);
    expect(grvProxy.grvLatencyStatistics.defaultStats.p25, 0.000388861);
    expect(
        grvProxy.grvLatencyStatistics.defaultStats.p90, 0.0022349399999999999);
    expect(
        grvProxy.grvLatencyStatistics.defaultStats.p95, 0.0037770300000000002);
    expect(
        grvProxy.grvLatencyStatistics.defaultStats.p99, 0.0070450299999999999);
    expect(
        grvProxy.grvLatencyStatistics.defaultStats.p999, 0.0083129399999999996);
    expect(grvProxy.name, 'grv_proxy');
  });

  test('cluster.process_role(commit_proxy)', () {
    final role = ProcessInfo(processJsonMap['5816904100ec5b26af0af4ed9ef16a4a'])
        .roles[1];
    final commitProxy = role as CommitProxyRoleInfo;
    expect(commitProxy.commitBatchingWindowSize.count, 37);
    expect(commitProxy.commitBatchingWindowSize.max, 0.0023109300000000001);
    expect(commitProxy.commitBatchingWindowSize.mean, 0.0020241400000000002);
    expect(commitProxy.commitBatchingWindowSize.median, 0.0020219700000000001);
    expect(commitProxy.commitBatchingWindowSize.min, 0.00181353);
    expect(commitProxy.commitBatchingWindowSize.p25, 0.00194086);
    expect(commitProxy.commitBatchingWindowSize.p90, 0.0021901999999999998);
    expect(commitProxy.commitBatchingWindowSize.p95, 0.0022217700000000001);
    expect(commitProxy.commitBatchingWindowSize.p99, 0.0023109300000000001);
    expect(commitProxy.commitBatchingWindowSize.p999, 0.0023109300000000001);
    expect(commitProxy.commitLatencyStatistics.count, 11);
    expect(commitProxy.commitLatencyStatistics.max, 0.034131999999999996);
    expect(commitProxy.commitLatencyStatistics.mean, 0.020412599999999999);
    expect(commitProxy.commitLatencyStatistics.median, 0.018566099999999999);
    expect(commitProxy.commitLatencyStatistics.min, 0.0085229899999999994);
    expect(commitProxy.commitLatencyStatistics.p25, 0.0116279);
    expect(commitProxy.commitLatencyStatistics.p90, 0.033093899999999996);
    expect(commitProxy.commitLatencyStatistics.p95, 0.034131999999999996);
    expect(commitProxy.commitLatencyStatistics.p99, 0.034131999999999996);
    expect(commitProxy.commitLatencyStatistics.p999, 0.034131999999999996);
    expect(commitProxy.name, 'commit_proxy');
  });

  test('cluster.process_role(log)', () {
    final role = ProcessInfo(processJsonMap['1d85aee0db863690abcec2a2fafa8e97'])
        .roles[0];
    final log = role as LogRoleInfo;
    expect(log.dataVersion, 58836936198671);
    expect(log.durableBytes.counter, 6821);
    expect(log.durableBytes.hz, 0);
    expect(log.durableBytes.roughness, -1);
    expect(log.inputBytes.counter, 6821);
    expect(log.inputBytes.hz, 0);
    expect(log.inputBytes.roughness, -1);
    expect(log.kvstoreAvailableBytes, 485664813056);
    expect(log.kvstoreFreeBytes, 485664813056);
    expect(log.kvstoreTotalBytes, 994662584320);
    expect(log.kvstoreUsedBytes, 104894464);
    expect(log.queueDiskAvailableBytes, 485664813056);
    expect(log.queueDiskFreeBytes, 485664813056);
    expect(log.queueDiskTotalBytes, 994662584320);
    expect(log.queueDiskUsedBytes, 2497703936);
    expect(log.name, 'log');
  });
}

final processJsonMap = {
  "164e2bfa10a839e3d22140458435cd13": {
    "address": "127.0.0.1:4690",
    "class_source": "command_line",
    "class_type": "unset",
    "command_line":
    "/usr/local/libexec/fdbserver --cluster_file=/usr/local/etc/foundationdb/fdb.cluster --datadir=/usr/local/foundationdb/data/4690 --listen_address=public --logdir=/usr/local/foundationdb/logs --public_address=auto:4690",
    "cpu": {"usage_cores": 0.0312015},
    "disk": {
      "busy": 0.050798599999999999,
      "free_bytes": 485664808960,
      "reads": {"counter": 4744343, "hz": 133.196, "sectors": 0},
      "total_bytes": 994662584320,
      "writes": {
        "counter": 19643911,
        "hz": 237.19300000000001,
        "sectors": 0
      }
    },
    "excluded": false,
    "fault_domain": "9c7af1a02294582cfa6158311c593879",
    "locality": {
      "machineid": "9c7af1a02294582cfa6158311c593879",
      "processid": "164e2bfa10a839e3d22140458435cd13",
      "zoneid": "9c7af1a02294582cfa6158311c593879"
    },
    "machine_id": "9c7af1a02294582cfa6158311c593879",
    "memory": {
      "available_bytes": 73883648,
      "limit_bytes": 8589934592,
      "rss_bytes": 51953664,
      "unused_allocated_memory": 0,
      "used_bytes": 422001360896
    },
    "messages": [],
    "network": {
      "connection_errors": {"hz": 0},
      "connections_closed": {"hz": 0},
      "connections_established": {"hz": 0},
      "current_connections": 4,
      "megabits_received": {"hz": 0.21074599999999999},
      "megabits_sent": {"hz": 0.170542},
      "tls_policy_failures": {"hz": 0}
    },
    "roles": [
      {"id": "6fe778ffb93bc1b9", "role": "master"},
      {"id": "5c8ac18f44cc8d76", "role": "data_distributor"},
      {"id": "9283bf1e74017e8f", "role": "ratekeeper"},
      {
        "grv_latency_statistics": {
          "batch": {
            "count": 12,
            "max": 0.001472,
            "mean": 0.00060031800000000008,
            "median": 0.00053596500000000001,
            "min": 0.00021290800000000002,
            "p25": 0.00030493700000000002,
            "p90": 0.00092101100000000001,
            "p95": 0.001472,
            "p99": 0.001472,
            "p99.9": 0.001472
          },
          "default": {
            "count": 382,
            "max": 0.0083129399999999996,
            "mean": 0.0010091,
            "median": 0.00056910500000000009,
            "min": 0.00018906600000000002,
            "p25": 0.000388861,
            "p90": 0.0022349399999999999,
            "p95": 0.0037770300000000002,
            "p99": 0.0070450299999999999,
            "p99.9": 0.0083129399999999996
          }
        },
        "id": "4a551c70b1f3a8d9",
        "role": "grv_proxy"
      },
      {
        "bytes_queried": {"counter": 0, "hz": 0, "roughness": -1},
        "data_lag": {"seconds": 1.6302099999999999, "versions": 1630211},
        "data_version": 58836935894911,
        "durability_lag": {"seconds": 5, "versions": 5000000},
        "durable_bytes": {"counter": 1934, "hz": 0, "roughness": -1},
        "durable_version": 58836930894911,
        "fetched_versions": {
          "counter": 10347169962,
          "hz": 999559,
          "roughness": 1323580
        },
        "fetches_from_logs": {
          "counter": 11931,
          "hz": 0.99956099999999992,
          "roughness": 0.32358399999999998
        },
        "finished_queries": {"counter": 0, "hz": 0, "roughness": -1},
        "id": "eb981526e74c6336",
        "input_bytes": {"counter": 1934, "hz": 0, "roughness": -1},
        "keys_queried": {"counter": 0, "hz": 0, "roughness": -1},
        "kvstore_available_bytes": 485664813056,
        "kvstore_free_bytes": 485664813056,
        "kvstore_inline_keys": 0,
        "kvstore_total_bytes": 994662584320,
        "kvstore_total_nodes": 0,
        "kvstore_total_size": 0,
        "kvstore_used_bytes": 108486656,
        "local_rate": 100,
        "low_priority_queries": {"counter": 0, "hz": 0, "roughness": -1},
        "mutation_bytes": {"counter": 82, "hz": 0, "roughness": -1},
        "mutations": {"counter": 2, "hz": 0, "roughness": -1},
        "query_queue_max": 0,
        "read_latency_statistics": {
          "count": 0,
          "max": 0,
          "mean": 0,
          "median": 0,
          "min": 0,
          "p25": 0,
          "p90": 0,
          "p95": 0,
          "p99": 0,
          "p99.9": 0
        },
        "role": "storage",
        "storage_metadata": {
          "created_time_datetime": "2024-03-18 12:59:36.000 +0000",
          "created_time_timestamp": 1710770000.0000002
        },
        "stored_bytes": 18542250,
        "total_queries": {"counter": 0, "hz": 0, "roughness": -1}
      }
    ],
    "run_loop_busy": 0.096625900000000001,
    "uptime_seconds": 10247.5,
    "version": "7.1.40"
  }
  , "1d85aee0db863690abcec2a2fafa8e97": {
    "address": "127.0.0.1:4692",
    "class_source": "command_line",
    "class_type": "unset",
    "command_line":
    "/usr/local/libexec/fdbserver --cluster_file=/usr/local/etc/foundationdb/fdb.cluster --datadir=/usr/local/foundationdb/data/4692 --listen_address=public --logdir=/usr/local/foundationdb/logs --public_address=auto:4692",
    "cpu": {"usage_cores": 0.013375399999999999},
    "disk": {
      "busy": 0.057770699999999994,
      "free_bytes": 485664808960,
      "reads": {"counter": 4744027, "hz": 263.666, "sectors": 0},
      "total_bytes": 994662584320,
      "writes": {
        "counter": 19642954,
        "hz": 405.99400000000003,
        "sectors": 0
      }
    },
    "excluded": false,
    "fault_domain": "9c7af1a02294582cfa6158311c593879",
    "locality": {
      "machineid": "9c7af1a02294582cfa6158311c593879",
      "processid": "1d85aee0db863690abcec2a2fafa8e97",
      "zoneid": "9c7af1a02294582cfa6158311c593879"
    },
    "machine_id": "9c7af1a02294582cfa6158311c593879",
    "memory": {
      "available_bytes": 71081984,
      "limit_bytes": 8589934592,
      "rss_bytes": 52396032,
      "unused_allocated_memory": 131072,
      "used_bytes": 422022938624
    },
    "messages": [],
    "network": {
      "connection_errors": {"hz": 0},
      "connections_closed": {"hz": 0},
      "connections_established": {"hz": 0},
      "current_connections": 3,
      "megabits_received": {"hz": 0.076997599999999999},
      "megabits_sent": {"hz": 0.14727199999999999},
      "tls_policy_failures": {"hz": 0}
    },
    "roles": [
      {
        "data_version": 58836936198671,
        "durable_bytes": {"counter": 6821, "hz": 0, "roughness": -1},
        "id": "90ca4eed5846876e",
        "input_bytes": {"counter": 6821, "hz": 0, "roughness": -1},
        "kvstore_available_bytes": 485664813056,
        "kvstore_free_bytes": 485664813056,
        "kvstore_total_bytes": 994662584320,
        "kvstore_used_bytes": 104894464,
        "queue_disk_available_bytes": 485664813056,
        "queue_disk_free_bytes": 485664813056,
        "queue_disk_total_bytes": 994662584320,
        "queue_disk_used_bytes": 2497703936,
        "role": "log"
      },
      {
        "bytes_queried": {
          "counter": 65110512,
          "hz": 6384.1099999999997,
          "roughness": 5804.2700000000004
        },
        "data_lag": {"seconds": 0.30376000000000003, "versions": 303760},
        "data_version": 58836936198671,
        "durability_lag": {
          "seconds": 5.3037600000000005,
          "versions": 5303760
        },
        "durable_bytes": {"counter": 1185776, "hz": 0, "roughness": -1},
        "durable_version": 58836930894911,
        "fetched_versions": {
          "counter": 10347473722,
          "hz": 1059610,
          "roughness": 1266810
        },
        "fetches_from_logs": {
          "counter": 11933,
          "hz": 1.1987099999999999,
          "roughness": 0.43310799999999999
        },
        "finished_queries": {
          "counter": 92687,
          "hz": 8.7905099999999994,
          "roughness": 6.9930200000000005
        },
        "id": "9a28adf8f0b092b8",
        "input_bytes": {
          "counter": 1186900,
          "hz": 224.55799999999999,
          "roughness": 1123
        },
        "keys_queried": {
          "counter": 206274,
          "hz": 20.1782,
          "roughness": 17.348700000000001
        },
        "kvstore_available_bytes": 485664813056,
        "kvstore_free_bytes": 485664813056,
        "kvstore_inline_keys": 0,
        "kvstore_total_bytes": 994662584320,
        "kvstore_total_nodes": 0,
        "kvstore_total_size": 0,
        "kvstore_used_bytes": 213381120,
        "local_rate": 100,
        "low_priority_queries": {"counter": 0, "hz": 0, "roughness": -1},
        "mutation_bytes": {
          "counter": 49332,
          "hz": 8.3909400000000005,
          "roughness": 41
        },
        "mutations": {
          "counter": 1049,
          "hz": 0.19978399999999999,
          "roughness": 0
        },
        "query_queue_max": 3,
        "read_latency_statistics": {
          "count": 543,
          "max": 0.00877905,
          "mean": 0.00018859000000000001,
          "median": 0.000119925,
          "min": 0.0000090599100000000001,
          "p25": 0.000065088300000000005,
          "p90": 0.000266075,
          "p95": 0.00037884700000000003,
          "p99": 0.0026538400000000002,
          "p99.9": 0.00877905
        },
        "role": "storage",
        "storage_metadata": {
          "created_time_datetime": "2024-02-22 12:39:18.000 +0000",
          "created_time_timestamp": 1708610000.0000002
        },
        "stored_bytes": 77274750,
        "total_queries": {
          "counter": 92687,
          "hz": 8.7905099999999994,
          "roughness": 6.9930200000000005
        }
      },
      {"id": "3b0a26cf26bc2617", "role": "resolver"}
    ],
    "run_loop_busy": 0.049186399999999998,
    "uptime_seconds": 10243.6,
    "version": "7.1.40"
  },
  "5816904100ec5b26af0af4ed9ef16a4a": {
    "address": "127.0.0.1:4691",
    "class_source": "command_line",
    "class_type": "unset",
    "command_line":
    "/usr/local/libexec/fdbserver --cluster_file=/usr/local/etc/foundationdb/fdb.cluster --datadir=/usr/local/foundationdb/data/4691 --listen_address=public --logdir=/usr/local/foundationdb/logs --public_address=auto:4691",
    "cpu": {"usage_cores": 0.0124259},
    "disk": {
      "busy": 0.058591899999999995,
      "free_bytes": 485664808960,
      "reads": {"counter": 4744023, "hz": 262.964, "sectors": 0},
      "total_bytes": 994662584320,
      "writes": {
        "counter": 19642954,
        "hz": 441.53899999999999,
        "sectors": 0
      }
    },
    "excluded": false,
    "fault_domain": "9c7af1a02294582cfa6158311c593879",
    "locality": {
      "machineid": "9c7af1a02294582cfa6158311c593879",
      "processid": "5816904100ec5b26af0af4ed9ef16a4a",
      "zoneid": "9c7af1a02294582cfa6158311c593879"
    },
    "machine_id": "9c7af1a02294582cfa6158311c593879",
    "memory": {
      "available_bytes": 71987200,
      "limit_bytes": 8589934592,
      "rss_bytes": 60915712,
      "unused_allocated_memory": 131072,
      "used_bytes": 422003294208
    },
    "messages": [],
    "network": {
      "connection_errors": {"hz": 0},
      "connections_closed": {"hz": 0},
      "connections_established": {"hz": 0},
      "current_connections": 5,
      "megabits_received": {"hz": 0.17705099999999999},
      "megabits_sent": {"hz": 0.14203499999999999},
      "tls_policy_failures": {"hz": 0}
    },
    "roles": [
      {"id": "d611ed2a7d3974a3", "role": "cluster_controller"},
      {
        "commit_batching_window_size": {
          "count": 37,
          "max": 0.0023109300000000001,
          "mean": 0.0020241400000000002,
          "median": 0.0020219700000000001,
          "min": 0.00181353,
          "p25": 0.00194086,
          "p90": 0.0021901999999999998,
          "p95": 0.0022217700000000001,
          "p99": 0.0023109300000000001,
          "p99.9": 0.0023109300000000001
        },
        "commit_latency_statistics": {
          "count": 11,
          "max": 0.034131999999999996,
          "mean": 0.020412599999999999,
          "median": 0.018566099999999999,
          "min": 0.0085229899999999994,
          "p25": 0.0116279,
          "p90": 0.033093899999999996,
          "p95": 0.034131999999999996,
          "p99": 0.034131999999999996,
          "p99.9": 0.034131999999999996
        },
        "id": "c8eafa7e69fe7423",
        "role": "commit_proxy"
      },
      {
        "bytes_queried": {
          "counter": 2420906,
          "hz": 201.958,
          "roughness": 1009
        },
        "data_lag": {"seconds": 0.30376000000000003, "versions": 303760},
        "data_version": 58836936198671,
        "durability_lag": {
          "seconds": 5.3037600000000005,
          "versions": 5303760
        },
        "durable_bytes": {"counter": 1918580, "hz": 0, "roughness": -1},
        "durable_version": 58836930894911,
        "fetched_versions": {
          "counter": 10347473722,
          "hz": 1060530,
          "roughness": 1266410
        },
        "fetches_from_logs": {
          "counter": 11933,
          "hz": 1.1997500000000001,
          "roughness": 0.43265299999999995
        },
        "finished_queries": {
          "counter": 122426,
          "hz": 11.197699999999999,
          "roughness": 4.8499400000000001
        },
        "id": "80cf48dbeeb817b6",
        "input_bytes": {
          "counter": 1919728,
          "hz": 229.55199999999999,
          "roughness": 1147
        },
        "keys_queried": {
          "counter": 6456,
          "hz": 0.59987400000000002,
          "roughness": 2
        },
        "kvstore_available_bytes": 485664813056,
        "kvstore_free_bytes": 485664813056,
        "kvstore_inline_keys": 0,
        "kvstore_total_bytes": 994662584320,
        "kvstore_total_nodes": 0,
        "kvstore_total_size": 0,
        "kvstore_used_bytes": 122384384,
        "local_rate": 100,
        "low_priority_queries": {"counter": 0, "hz": 0, "roughness": -1},
        "mutation_bytes": {
          "counter": 292976,
          "hz": 10.797700000000001,
          "roughness": 53
        },
        "mutations": {"counter": 1283, "hz": 0.199958, "roughness": 0},
        "query_queue_max": 4,
        "read_latency_statistics": {
          "count": 730,
          "max": 0.0045399699999999999,
          "mean": 0.00015565800000000001,
          "median": 0.000072956100000000004,
          "min": 0.000012159300000000001,
          "p25": 0.000026941300000000002,
          "p90": 0.00024700200000000002,
          "p95": 0.00047707600000000005,
          "p99": 0.0017909999999999998,
          "p99.9": 0.0045399699999999999
        },
        "role": "storage",
        "storage_metadata": {
          "created_time_datetime": "2024-02-10 05:51:28.000 +0000",
          "created_time_timestamp": 1707540000
        },
        "stored_bytes": 45694500,
        "total_queries": {
          "counter": 122426,
          "hz": 11.197699999999999,
          "roughness": 4.8499400000000001
        }
      }
    ],
    "run_loop_busy": 0.064099199999999995,
    "uptime_seconds": 10243,
    "version": "7.1.40"
  },
  "fec1d44658890fb0141475b662fb2d71": {
    "address": "127.0.0.1:4689",
    "class_source": "command_line",
    "class_type": "unset",
    "command_line":
    "/usr/local/libexec/fdbserver --cluster_file=/usr/local/etc/foundationdb/fdb.cluster --datadir=/usr/local/foundationdb/data/4689 --listen_address=public --logdir=/usr/local/foundationdb/logs --public_address=auto:4689",
    "cpu": {"usage_cores": 0.015908800000000001},
    "disk": {
      "busy": 0.058598399999999995,
      "free_bytes": 485664808960,
      "reads": {"counter": 4744023, "hz": 262.99299999999999, "sectors": 0},
      "total_bytes": 994662584320,
      "writes": {
        "counter": 19642954,
        "hz": 441.58800000000002,
        "sectors": 0
      }
    },
    "excluded": false,
    "fault_domain": "9c7af1a02294582cfa6158311c593879",
    "locality": {
      "machineid": "9c7af1a02294582cfa6158311c593879",
      "processid": "fec1d44658890fb0141475b662fb2d71",
      "zoneid": "9c7af1a02294582cfa6158311c593879"
    },
    "machine_id": "9c7af1a02294582cfa6158311c593879",
    "memory": {
      "available_bytes": 71987200,
      "limit_bytes": 8589934592,
      "rss_bytes": 52232192,
      "unused_allocated_memory": 131072,
      "used_bytes": 422012665856
    },
    "messages": [],
    "network": {
      "connection_errors": {"hz": 0},
      "connections_closed": {"hz": 0},
      "connections_established": {"hz": 0},
      "current_connections": 6,
      "megabits_received": {"hz": 0.099325299999999991},
      "megabits_sent": {"hz": 0.11719399999999999},
      "tls_policy_failures": {"hz": 0}
    },
    "roles": [
      {"role": "coordinator"},
      {
        "commit_batching_window_size": {
          "count": 36,
          "max": 0.0031206900000000002,
          "mean": 0.00244349,
          "median": 0.0023910099999999998,
          "min": 0.0020490199999999999,
          "p25": 0.00225998,
          "p90": 0.00292334,
          "p95": 0.0030370100000000001,
          "p99": 0.0031206900000000002,
          "p99.9": 0.0031206900000000002
        },
        "commit_latency_statistics": {
          "count": 9,
          "max": 0.060891899999999999,
          "mean": 0.025550199999999999,
          "median": 0.018393,
          "min": 0.013140000000000001,
          "p25": 0.018042099999999998,
          "p90": 0.060891899999999999,
          "p95": 0.060891899999999999,
          "p99": 0.060891899999999999,
          "p99.9": 0.060891899999999999
        },
        "id": "cead1e3487080b71",
        "role": "commit_proxy"
      },
      {
        "data_version": 58836936198671,
        "durable_bytes": {"counter": 478121, "hz": 0, "roughness": -1},
        "id": "a9eeda4eda306176",
        "input_bytes": {
          "counter": 478319,
          "hz": 39.598199999999999,
          "roughness": 197
        },
        "kvstore_available_bytes": 485664813056,
        "kvstore_free_bytes": 485664813056,
        "kvstore_total_bytes": 994662584320,
        "kvstore_used_bytes": 104882352,
        "queue_disk_available_bytes": 485664813056,
        "queue_disk_free_bytes": 485664813056,
        "queue_disk_total_bytes": 994662584320,
        "queue_disk_used_bytes": 258048,
        "role": "log"
      },
      {
        "bytes_queried": {"counter": 0, "hz": 0, "roughness": -1},
        "data_lag": {"seconds": 0.30376000000000003, "versions": 303760},
        "data_version": 58836936198671,
        "durability_lag": {
          "seconds": 5.3037600000000005,
          "versions": 5303760
        },
        "durable_bytes": {"counter": 1934, "hz": 0, "roughness": -1},
        "durable_version": 58836930894911,
        "fetched_versions": {
          "counter": 10347473722,
          "hz": 1060700,
          "roughness": 1264930
        },
        "fetches_from_logs": {
          "counter": 11935,
          "hz": 1.1999500000000001,
          "roughness": 0.43098000000000003
        },
        "finished_queries": {"counter": 0, "hz": 0, "roughness": -1},
        "id": "f5a70ac0c477abd7",
        "input_bytes": {"counter": 1934, "hz": 0, "roughness": -1},
        "keys_queried": {"counter": 0, "hz": 0, "roughness": -1},
        "kvstore_available_bytes": 485664813056,
        "kvstore_free_bytes": 485664813056,
        "kvstore_inline_keys": 0,
        "kvstore_total_bytes": 994662584320,
        "kvstore_total_nodes": 0,
        "kvstore_total_size": 0,
        "kvstore_used_bytes": 107900928,
        "local_rate": 100,
        "low_priority_queries": {"counter": 0, "hz": 0, "roughness": -1},
        "mutation_bytes": {"counter": 82, "hz": 0, "roughness": -1},
        "mutations": {"counter": 2, "hz": 0, "roughness": -1},
        "query_queue_max": 0,
        "read_latency_statistics": {
          "count": 0,
          "max": 0,
          "mean": 0,
          "median": 0,
          "min": 0,
          "p25": 0,
          "p90": 0,
          "p95": 0,
          "p99": 0,
          "p99.9": 0
        },
        "role": "storage",
        "storage_metadata": {
          "created_time_datetime": "2024-03-18 12:59:36.000 +0000",
          "created_time_timestamp": 1710770000.0000002
        },
        "stored_bytes": 16389750,
        "total_queries": {"counter": 0, "hz": 0, "roughness": -1}
      }
    ],
    "run_loop_busy": 0.065580199999999991,
    "uptime_seconds": 10243,
    "version": "7.1.40"
  }
};
