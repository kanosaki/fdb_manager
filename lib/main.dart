import 'package:fdb_manager/agent_api.dart';
import 'package:fdb_manager/constants.dart';
import 'package:fdb_manager/controllers/MenuController.dart';
import 'package:fdb_manager/screens/cluster_overview/cluster_overview_screen.dart';
import 'package:fdb_manager/screens/dashboard/dashboard_screen.dart';
import 'package:fdb_manager/screens/main/main_screen.dart';
import 'package:fdb_manager/screens/process_detail/process_details_screen.dart';
import 'package:fdb_manager/screens/processes/processes_screen.dart';
import 'package:fdb_manager/screens/roles/roles_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

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
    final baseTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey, backgroundColor: Colors.white),
    );
    // final baseTheme = ThemeData.light();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MenuController()),
          ChangeNotifierProvider(
              create: (context) => InstantStatusProvider(api)),
        ],
        child: MaterialApp(
          // debugShowCheckedModeBanner: false,
          title: 'Flutter Admin Panel',
          theme: baseTheme.copyWith(
            appBarTheme: baseTheme.appBarTheme.copyWith(
              color: baseTheme.primaryColor,
            ),
            // pageTransitionsTheme: PageTransitionsTheme(
            //   builders: kIsWeb
            //       ? {
            //           // Disable transitions in browser regardless of the platforms.
            //           for (final platform in TargetPlatform.values)
            //             platform: const NoTransitionsBuilder(),
            //         }
            //       : const {
            //           TargetPlatform.macOS: NoTransitionsBuilder(),
            //         },
            // ),
          ),
          initialRoute: '/processes',
          routes: {
            '/overview': (context) => const MainScreen(ClusterOverview()),
            '/processes': (context) => const MainScreen(ProcessesScreen()),
            '/process/details': (context) =>
                const MainScreen(ProcessDetailsScreen()),
            '/roles': (context) => const MainScreen(RolesScreen()),
            // '/': (context) => const MainScreen(DashboardScreen()),
          },
        ));
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}
