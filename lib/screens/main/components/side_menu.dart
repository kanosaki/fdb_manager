import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../controllers/database.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cm = context.read<ClusterManager>();
    final noCluster = cm.currentCluster() == null;
    return Drawer(
      child: ListView(
        children: [
          // DrawerHeader(
          //   child: Image.asset("assets/images/logo.png"),
          // ),
          DrawerListTile(
            title: "Switch cluster",
            svgSrc: "assets/icons/menu_dashbord.svg",
            press: () {
              Navigator.pushNamed(context, '/connect');
              Scaffold.of(context).closeDrawer();
            },
          ),
          const Divider(),
          DrawerListTile(
            title: "Overview",
            svgSrc: "assets/icons/menu_task.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/overview');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
          DrawerListTile(
            title: "Processes",
            svgSrc: "assets/icons/menu_tran.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/processes');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
          DrawerListTile(
            title: "Roles",
            svgSrc: "assets/icons/menu_task.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/roles');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
          DrawerListSubTile(
            title: "Storage",
            svgSrc: "assets/icons/menu_task.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/roles');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
          DrawerListSubTile(
            title: "Logs",
            svgSrc: "assets/icons/menu_task.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/roles');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
          DrawerListSubTile(
            title: "Proxy",
            svgSrc: "assets/icons/menu_task.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/roles');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
          DrawerListTile(
            title: "Region",
            svgSrc: "assets/icons/menu_task.svg",
            press: noCluster
                ? null
                : () {
                    Navigator.pushNamed(context, '/locality');
                    Scaffold.of(context).closeDrawer();
                  },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final GestureTapCallback? press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity),
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        height: 16,
      ),
      title: Text(
        title,
      ),
    );
  }
}

class DrawerListSubTile extends StatelessWidget {
  const DrawerListSubTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final GestureTapCallback? press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      visualDensity: const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity),
      dense: true,
      title: Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Text(
            title,
          )),
    );
  }
}
