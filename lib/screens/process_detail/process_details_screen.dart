
import 'package:flutter/material.dart';

class ProcessDetailsScreen extends StatefulWidget {
  const ProcessDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProcessDetailsScreenState();
}

class _ProcessDetailsScreenState extends State<ProcessDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final processId = ModalRoute.of(context)!.settings.arguments as String;
    return Text(processId);
  }
}
