# Initial design

fdb_manager is basically re-implementation of [fdbtop](https://github.com/Doxense/foundationdb-dotnet-client) tool 
with more visibility and detailed information.

## Agent

fdb_manager includes an agent which monitors FoundationDB status and record for a period of time.
It also provides a proxy to execute some FoundationDB commands.

Agent basically reads FoundationDB system keys and simply returns it as a JSON.

## Design / Coloring

We don't aim to make it easy to learn. 
The goal is to create tools that increast efficiency through familiarization with their use.

The design don't need to be too simplified.
We organize information by importance and pack a good amount of it onto the single screen.

We will use colors to see what happens to the cluster more intuitively.
So, we must concern about color vision variation. We should also indicate by shape as well if it is appropriate.


## Pages

### / (root page)

Root page shows overview of the cluster. Users can:

* Notice alerts, errors and important warnings
* Overall status
  - Coordinator status
  - Cluster availability
  - Primary DC / Region replication status
  - Backup status
  - ...
* See major metrics such as:
  - Overall storage capacity
  - Incoming workload (throughput, ops/s)
  - ...
  - (CPU/RAM might not need because it should be notified by alerts)
* Operational notes

### /processes

Processes page shows list of every processes. Users can:

* Notice resource shortage at every machine

### /roles

Shows overview of the cluster by role-wise. Users can:


### /role/storage
### /role/log

### /role/proxy (before 7.0)


### /role/grv_proxy (after 7.0)
TBD

### /role/commit_proxy
TBD

### /region
### /workload
### /clients
### /backup
### /qos
