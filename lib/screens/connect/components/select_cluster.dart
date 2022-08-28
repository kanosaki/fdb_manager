import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/database.dart';

enum CardActions { delete }

class SelectCluster extends StatelessWidget {
  final Function(bool) showConnectNew;

  const SelectCluster(this.showConnectNew, {Key? key}) : super(key: key);

  Widget _otherActions(BuildContext context, ClusterManager cm, ClusterInfo e) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('Delete'), value: CardActions.delete),
      ],
      onSelected: (menuItem) async {
        switch (menuItem) {
          case CardActions.delete:
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Deleting cluster: "${e.name}"'),
                content: Text('Are you sure want to delete ${e.name}?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () async {
                        await cm.deleteCluster(e.name);
                        final snackBar = SnackBar(
                          content: Text('Cluster ${e.name} deleted'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm delete')),
                ],
              ),
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cm = context.read<ClusterManager>();
    VoidCallback onSelectCluster(ClusterInfo e) {
      return () async {
        final snackBar = SnackBar(
          content: Text('Cluster switched to ${e.name}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await cm.setActiveClusterName(e.name);
        Navigator.of(context).pushNamed('/overview');
      };
    }

    final clusters = cm.listClusters().map(
          (e) => Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onSelectCluster(e),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_outlined),
                    title: Text(e.name),
                    subtitle: Text(e.baseUrl),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: onSelectCluster(e),
                        child: const Text('Select')),
                    _otherActions(context, cm, e),
                  ],
                ),
              ],
            ),
          ),
        );
    return Center(
      child: Column(
        children: [
          Row(children: [
            MaterialButton(
                child: const Text('New...'),
                onPressed: () {
                  showConnectNew(true);
                }),
          ]),
          Column(children: clusters.toList())
        ],
      ),
    );
  }
}
