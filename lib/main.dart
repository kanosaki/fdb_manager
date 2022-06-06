import 'package:fdb_manager/agent_api.dart';
import 'package:fdb_manager/constants.dart';
import 'package:fdb_manager/controllers/MenuController.dart';
import 'package:fdb_manager/screens/dashboard/dashboard_screen.dart';
import 'package:fdb_manager/screens/main/main_screen.dart';
import 'package:fdb_manager/screens/process_detail/process_details_screen.dart';
import 'package:fdb_manager/screens/processes/processes_screen.dart';
import 'package:fdb_manager/screens/roles/roles_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  final api = AgentApi("http://localhost:8080", http.Client());
  runApp(MyApp(api));
}

class MyApp extends StatelessWidget {
  final AgentApi api;

  const MyApp(this.api, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MenuController()),
          ChangeNotifierProvider(create: (context) => InstantStatusProvider(api)),
        ],
        child: MaterialApp(
          // debugShowCheckedModeBanner: false,
          title: 'Flutter Admin Panel',
          // theme: ThemeData.dark().copyWith(
          //   scaffoldBackgroundColor: bgColor,
          //   textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          //       .apply(bodyColor: Colors.white),
          //   canvasColor: secondaryColor,
          // ),
          initialRoute: '/processes',
          routes: {
            '/processes': (context) => const MainScreen(ProcessesScreen()),
            '/process/details': (context) => const MainScreen(ProcessDetailsScreen()),
            '/roles': (context) => const MainScreen(RolesScreen()),
            '/': (context) => const MainScreen(DashboardScreen()),
          },
        ));
  }
}
