import 'package:fdb_manager/controllers/database.dart';
import 'package:fdb_manager/models/connection.dart';
import 'package:fdb_manager/screens/connect/components/connect_new_screen.dart';
import 'package:fdb_manager/screens/connect/components/select_cluster.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main/components/side_menu.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  bool creatingNew = false;


  @override
  Widget build(BuildContext context) {
    final cm = context.read<ClusterManager>();
    if (cm.currentCluster() == null && !creatingNew) {
      setState(() {
        creatingNew = true;
      });
    }

    void scn(bool s) {
      setState(() {
        creatingNew = s;
      });
    }

    return Scaffold(
      appBar: AppBar(elevation: 0),
      drawer: const SideMenu(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: creatingNew ? ConnectNew(scn) : SelectCluster(scn),
        ),
      ),
    );
  }
}
