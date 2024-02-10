import 'package:flutter/material.dart';

class RoleTag extends StatelessWidget {
  const RoleTag(
    this.roles, {
    Key? key,
    this.grouped = true,
    this.darkened = false,
    this.clusterManagerWidth = tagBaseWidth * 8 + tagPadWidth * 2,
    this.transactionAuthorityWidth = tagBaseWidth * 4 + tagPadWidth * 2,
    this.storageWidth = tagBaseWidth * 3 + tagPadWidth * 2,
  }) : super(key: key);
  final List<String> roles;
  final bool grouped;
  final bool darkened;
  final int clusterManagerWidth;
  final int transactionAuthorityWidth;
  final int storageWidth;
  static const int tagBaseWidth = 20;
  static const int tagPadWidth = 7;

  static final roleCategory = {
    'master': 1,
    'coordinator': 0,
    'cluster_controller': 0,
    'ratekeeper': 0,
    'data_distributor': 0,
    'proxy': 1, // < 7.0
    'commit_proxy': 1, // >= 7.0
    'grv_proxy': 1, // >= 7.0
    'resolver': 1,
    'log': 2,
    'storage': 2,
  };

  static final borderColorMap = {
    'coordinator': const Color.fromRGBO(175, 144, 76, 1.0),
    'cluster_controller': const Color.fromRGBO(204, 99, 54, 1.0),
    'ratekeeper': const Color.fromRGBO(161, 107, 118, 1.0),
    'data_distributor': const Color.fromRGBO(143, 97, 154, 1.0),
    'master': const Color.fromRGBO(255, 182, 165, 1.0),
    'proxy': const Color.fromRGBO(195, 243, 144, 1.0),
    'commit_proxy': const Color.fromRGBO(166, 217, 149, 1.0),
    'grv_proxy': const Color.fromRGBO(231, 250, 144, 1.0),
    'resolver': const Color.fromRGBO(182, 234, 208, 1.0),
    'log': const Color.fromRGBO(214, 235, 250, 1.0),
    'storage': const Color.fromRGBO(220, 212, 253, 1.0),
  };

  static const darkenRatio = 0.7;

  static final rolesSymbolMap = {
    'coordinator': 'Co',
    'master': 'M',
    'cluster_controller': 'CC',
    'ratekeeper': 'RK',
    'data_distributor': 'DD',
    'proxy': 'P',
    'commit_proxy': 'Pc',
    'grv_proxy': 'Pg',
    'log': 'L',
    'storage': 'S',
    'resolver': 'Rs',
  };

  Widget buildTag(BuildContext context, String name) {
    final textColorBase = roleCategory[name] == 0
        ? const Color.fromRGBO(255, 255, 255, 1)
        : const Color.fromRGBO(0, 0, 0, 1);
    final hsvTextColor = HSVColor.fromColor(textColorBase);
    final textColor = darkened
        ? hsvTextColor.withValue(hsvTextColor.value * darkenRatio).toColor()
        : textColorBase;
    final baseColor =
        HSVColor.fromColor(borderColorMap[name] ?? const Color.fromRGBO(100, 100, 100, 1));
    final color =
        darkened ? baseColor.withValue(baseColor.value * .5) : baseColor;
    final symbol = rolesSymbolMap[name] ?? name;
    final borderColor =
        color.withValue(color.value * darkenRatio).toColor();
    return Tooltip(
      message: name,
      waitDuration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          color: color.toColor(),
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(3.0)),
        ),
        child: Text(symbol, style: TextStyle(color: textColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category2 = roles
        .where((e) => roleCategory[e] == 2)
        .map((e) => buildTag(context, e))
        .toList();
    final category1 = roles
        .where((e) => roleCategory[e] == 1)
        .map((e) => buildTag(context, e))
        .toList();
    final category0 = roles
        .where((e) => roleCategory[e] == 0)
        .map((e) => buildTag(context, e))
        .toList();
    if (grouped) {
      return Row(children: [
        Expanded(flex: storageWidth, child: Row(children: category2)),
        Expanded(
            flex: transactionAuthorityWidth, child: Row(children: category1)),
        Expanded(flex: clusterManagerWidth, child: Row(children: category0)),
      ]);
    } else {
      return Row(children: [...category2, ...category1, ...category0]);
    }
  }
}
