import 'package:fdb_manager/controllers/MenuController.dart';
import 'package:fdb_manager/responsive.dart';
import 'package:fdb_manager/screens/dashboard/dashboard_screen.dart';
import 'package:fdb_manager/screens/main/components/headline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen(this.content, {Key? key}) : super(key: key);
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return Scaffold(
      // key: context.read<MenuController>().scaffoldKey,
      drawer: const SideMenu(),
      appBar: AppBar(
        elevation: 0,
        leading: Builder(builder: (BuildContext context) {
          return Row(children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: nav.canPop()
                  ? () {
                      nav.pop();
                    }
                  : null,
            ),
          ]);
        }),
        leadingWidth: 100,
        actions: const [
          Headline(),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            // if (Responsive.isDesktop(context))
            //   const Expanded(
            //     // default flex = 1
            //     // and it takes 1/6 part of the screen
            //     child: SideMenu(),
            //   ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
