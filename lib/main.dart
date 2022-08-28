import 'dart:developer';
import 'dart:ui';

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
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'controllers/database.dart';
import 'screens/connect/connect_screen.dart';
import 'util/init_app.dart' if (dart.library.js) 'util/init_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseManager db = await initDB();
  runApp(AppMain(db));
}

class AppMain extends StatefulWidget {
  const AppMain(this._db, {Key? key}) : super(key: key);
  final DatabaseManager _db;

  @override
  State<AppMain> createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  _AppMainState({Key? key}) : super();
  ClusterManager? _cm;

  @override
  void initState() {
    super.initState();
    final cm = ClusterManager(widget._db);
    Future(() async {
      await cm.load();
      setState(() {
        _cm = cm;
      });
    }).onError((error, stackTrace) {
      log('load error: $error $stackTrace');
    }).then((value) => (value) {
          log('load done');
        });
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey, backgroundColor: Colors.white),
    );
    final cm = _cm;
    if (cm == null) {
      return const Center(
          child: Text('Waiting for database...',
              textDirection: TextDirection.ltr));
    }
    final cc = cm.currentCluster();
    final api = cc == null
        ? NotInitializedAgentApi()
        : AgentApi(cc.baseUrl, http.Client());
    final initialRoute = cc == null ? '/connect' : '/processes';
    final isp = InstantStatusProvider(api);
    cm.clusterChanged = (ci) => isp.switchCluster(ci == null
        ? NotInitializedAgentApi()
        : AgentApi(ci.baseUrl, http.Client()));

    final Map<String, WidgetBuilder> routes = {
      '/overview': (context) => const MainScreen(ClusterOverview()),
      '/processes': (context) => const MainScreen(ProcessesScreen()),
      '/process/details': (context) => const MainScreen(ProcessDetailsScreen()),
      '/roles': (context) => const MainScreen(RolesScreen()),
    };

    if (widget._db.isSupportSwitching()) {
      routes['/connect'] = (context) => const ConnectScreen();
    }

    // final baseTheme = ThemeData.light();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => cm),
          ChangeNotifierProvider(create: (context) => MenuController()),
          ChangeNotifierProvider(create: (context) => isp),
          ChangeNotifierProvider(create: (context) => widget._db),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // restorationScopeId: 'app',
          title: 'fdb_manager',
          theme: baseTheme.copyWith(
            appBarTheme: baseTheme.appBarTheme.copyWith(
              color: baseTheme.primaryColor,
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: kIsWeb
                  ? {
                      // Disable transitions in browser regardless of the platforms.
                      for (final platform in TargetPlatform.values)
                        platform: const NoTransitionsBuilder(),
                    }
                  : const {
                      TargetPlatform.macOS: NoTransitionsBuilder(),
                    },
            ),
          ),
          // scrollBehavior: AppScrollBehavior(),
          initialRoute: initialRoute,
          routes: routes,
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

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
