import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Home",
            svgSrc: "assets/icons/menu_dashbord.svg",
            press: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          DrawerListTile(
            title: "Processes",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushNamed(context, '/processes');
            },
          ),
          DrawerListTile(
            title: "Roles",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              Navigator.pushNamed(context, '/roles');
            },
          ),
          // DrawerListTile(
          //   title: "Documents",
          //   svgSrc: "assets/icons/menu_doc.svg",
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: "Store",
          //   svgSrc: "assets/icons/menu_store.svg",
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: "Notification",
          //   svgSrc: "assets/icons/menu_notification.svg",
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: "Profile",
          //   svgSrc: "assets/icons/menu_profile.svg",
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: "Settings",
          //   svgSrc: "assets/icons/menu_setting.svg",
          //   press: () {},
          // ),
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
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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