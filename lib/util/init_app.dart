import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../controllers/database.dart';

Future<DatabaseManager> initDB() async {
  final appDir = await getApplicationSupportDirectory();
  final dbPath = path.join(appDir.path, 'fdb_manager.db');
  return await openSQLiteDatabaseManager(dbPath);
}
