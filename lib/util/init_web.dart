import 'dart:js' as js;
import '../controllers/database.dart';

Future<DatabaseManager> initDB() async {
  return StaticDatabaseManager(js.context['fdbManagerAgentURL']);
}
