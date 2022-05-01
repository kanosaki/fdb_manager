import 'package:fdb_manager/constants.dart';
import 'package:fdb_manager/controllers/MenuController.dart';
import 'package:fdb_manager/screens/dashboard/dashboard_screen.dart';
import 'package:fdb_manager/screens/main/main_screen.dart';
import 'package:fdb_manager/screens/roles/roles_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MenuController(),
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'Flutter Admin Panel',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
        ),
        initialRoute: '/',
        routes: {
          // '/': (context) => const MainScreen(RolesScreen()),
          '/': (context) => const MainScreen(DashboardScreen()),
        },
      ),
    );
  }
}
