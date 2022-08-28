import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/database.dart';

class ConnectNew extends StatefulWidget {
  final Function(bool) showConnectNew;

  const ConnectNew(this.showConnectNew, {Key? key}) : super(key: key);

  @override
  State<ConnectNew> createState() => _ConnectNewState();
}

class _ConnectNewState extends State<ConnectNew> {
  late TextEditingController _baseUrl;
  late TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _baseUrl = TextEditingController();
    _name = TextEditingController();
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cm = context.read<ClusterManager>();
    void onSubmitted(String value) async {
      cm.updateCluster(_name.text, ClusterInfo(_name.text, _baseUrl.text));
      widget.showConnectNew(false);
    }

    return Column(
      children: [
        TextField(
          controller: _name,
          onSubmitted: onSubmitted,
        ),
        TextField(
          controller: _baseUrl,
          onSubmitted: onSubmitted,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          MaterialButton(
              child: const Text('OK'),
              onPressed: () {
                onSubmitted('');
              }),
          MaterialButton(
              child: const Text('Cancel'),
              onPressed: () {
                widget.showConnectNew(false);
              }),
        ]),
      ],
    );
  }
}
