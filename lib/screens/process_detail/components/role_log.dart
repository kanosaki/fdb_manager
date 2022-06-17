import 'package:fdb_manager/models/status.dart';
import 'package:flutter/material.dart';

class LogRole extends StatelessWidget {
  const LogRole(this.role, {Key? key}) : super(key: key);

  final ProcessRoleInfo role;

  @override
  Widget build(BuildContext context) {
    return const Text('log');
  }
}
