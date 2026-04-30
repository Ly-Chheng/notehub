// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseService {
//   static Database? _db;

//   static Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   static Future<Database> initDB() async {
//     final path = join(await getDatabasesPath(), 'notes_app.db');
//     print("DATABASE PATH: $path");

//     return await openDatabase(
//       path,
//       version: 4, // ← Increased to 4
//       onConfigure: (db) async {
//         await db.execute('PRAGMA foreign_keys = ON');
//       },
//       onCreate: (db, version) async {
//         // Folders Table
//         await db.execute('''
//           CREATE TABLE folders (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT NOT NULL,
//             date TEXT,
//             isPinned INTEGER DEFAULT 0,
//             isLocked INTEGER DEFAULT 0
//           )
//         ''');

//         // Notes Table - with ALL columns
//         await db.execute('''
//           CREATE TABLE notes (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             folder_id INTEGER,
//             title TEXT,
//             content TEXT,
//             date TEXT,
//             is_locked INTEGER DEFAULT 0,
//             is_pinned INTEGER DEFAULT 0,
//             bg_color INTEGER DEFAULT 0,
//             image_paths TEXT DEFAULT '[]',
//             show_table INTEGER DEFAULT 0,
//             table_data TEXT DEFAULT '[]',
//             drawing_layers TEXT DEFAULT '[]',
//             FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
//           )
//         ''');
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         print(' Database upgrading: $oldVersion → $newVersion');

//         if (oldVersion < 2) {
//           await db.execute("ALTER TABLE folders ADD COLUMN isPinned INTEGER DEFAULT 0");
//         }
//         if (oldVersion < 3) {
//           await db.execute("ALTER TABLE folders ADD COLUMN isLocked INTEGER DEFAULT 0");
//         }
//         if (oldVersion < 4) {
//           // Add new columns to notes table
//           await _addColumnIfNotExists(db, 'notes', 'image_paths', "TEXT DEFAULT '[]'");
//           await _addColumnIfNotExists(db, 'notes', 'show_table', "INTEGER DEFAULT 0");
//           await _addColumnIfNotExists(db, 'notes', 'table_data', "TEXT DEFAULT '[]'");
//           await _addColumnIfNotExists(db, 'notes', 'drawing_layers', "TEXT DEFAULT '[]'");

//           print(" Added new columns to notes table (v4)");
//         }
//       },
//     );
//   }

//   // Helper method to safely add column
//   static Future<void> _addColumnIfNotExists(Database db, String table, String column, String definition) async {
//     final tableInfo = await db.rawQuery("PRAGMA table_info($table)");
//     final exists = tableInfo.any((col) => col['name'] == column);

//     if (!exists) {
//       await db.execute("ALTER TABLE $table ADD COLUMN $column $definition");
//       print("Added column: $column to table $table");
//     }
//   }
// }
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'notes_app.db');

    return await openDatabase(
      path,
      version: 5,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Folders Table
        await db.execute('''
          CREATE TABLE folders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date TEXT,
            isPinned INTEGER DEFAULT 0,
            isLocked INTEGER DEFAULT 0
          )
        ''');

        // Notes Table
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER,
            title TEXT,
            content TEXT,
            date TEXT,
            is_locked INTEGER DEFAULT 0,
            is_pinned INTEGER DEFAULT 0,
            bg_color INTEGER DEFAULT 0,
            image_paths TEXT DEFAULT '[]',
            show_table INTEGER DEFAULT 0,
            table_data TEXT DEFAULT '[]',
            drawing_layers TEXT DEFAULT '[]',
            FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
          )
        ''');

        // Security Table
        await db.execute('''
          CREATE TABLE security (
            id INTEGER PRIMARY KEY DEFAULT 1,
            master_password TEXT DEFAULT '',
            security_question TEXT DEFAULT '',
            security_answer TEXT DEFAULT '',
            password_hint TEXT DEFAULT ''
          )
        ''');

        await db.insert('security', {'id': 1, 'master_password': ''});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE folders ADD COLUMN isPinned INTEGER DEFAULT 0");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE folders ADD COLUMN isLocked INTEGER DEFAULT 0");
        }
        if (oldVersion < 4) {
          await _addColumnIfNotExists(db, 'notes', 'image_paths', "TEXT DEFAULT '[]'");
          await _addColumnIfNotExists(db, 'notes', 'show_table', "INTEGER DEFAULT 0");
          await _addColumnIfNotExists(db, 'notes', 'table_data', "TEXT DEFAULT '[]'");
          await _addColumnIfNotExists(db, 'notes', 'drawing_layers', "TEXT DEFAULT '[]'");
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS security (
              id INTEGER PRIMARY KEY DEFAULT 1,
              master_password TEXT DEFAULT '',
              security_question TEXT DEFAULT '',
              security_answer TEXT DEFAULT '',
              password_hint TEXT DEFAULT ''
            )
          ''');
          final List<Map<String, dynamic>> existing = await db.query('security', where: 'id = 1');
          if (existing.isEmpty) {
            await db.insert('security', {'id': 1, 'master_password': ''});
          }
        }
      },
    );
  }

  static Future<void> _addColumnIfNotExists(Database db, String table, String column, String definition) async {
    final tableInfo = await db.rawQuery("PRAGMA table_info($table)");
    final exists = tableInfo.any((col) => col['name'] == column);
    if (!exists) {
      await db.execute("ALTER TABLE $table ADD COLUMN $column $definition");
    }
  }
}
// import 'dart:io'; //  ADD THIS
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseService {
//   static Database? _db;

//   static Future<Database> get db async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   static Future<Database> initDB() async {
//     final path = join(await getDatabasesPath(), 'notes_app.db');
//     print("DATABASE PATH: $path");

//     return await openDatabase(
//       path,
//       version: 4,
//       onConfigure: (db) async {
//         await db.execute('PRAGMA foreign_keys = ON');
//       },
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE folders (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT NOT NULL,
//             date TEXT,
//             isPinned INTEGER DEFAULT 0,
//             isLocked INTEGER DEFAULT 0
//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE notes (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             folder_id INTEGER,
//             title TEXT,
//             content TEXT,
//             date TEXT,
//             is_locked INTEGER DEFAULT 0,
//             is_pinned INTEGER DEFAULT 0,
//             bg_color INTEGER DEFAULT 0,
//             image_paths TEXT DEFAULT '[]',
//             show_table INTEGER DEFAULT 0,
//             table_data TEXT DEFAULT '[]',
//             drawing_layers TEXT DEFAULT '[]',
//             FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
//           )
//         ''');
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         print(' Database upgrading: $oldVersion → $newVersion');

//         if (oldVersion < 2) {
//           await db.execute("ALTER TABLE folders ADD COLUMN isPinned INTEGER DEFAULT 0");
//         }
//         if (oldVersion < 3) {
//           await db.execute("ALTER TABLE folders ADD COLUMN isLocked INTEGER DEFAULT 0");
//         }
//         if (oldVersion < 4) {
//           await _addColumnIfNotExists(db, 'notes', 'image_paths', "TEXT DEFAULT '[]'");
//           await _addColumnIfNotExists(db, 'notes', 'show_table', "INTEGER DEFAULT 0");
//           await _addColumnIfNotExists(db, 'notes', 'table_data', "TEXT DEFAULT '[]'");
//           await _addColumnIfNotExists(db, 'notes', 'drawing_layers', "TEXT DEFAULT '[]'");
//         }
//       },
//     );
//   }

//   static Future<void> _addColumnIfNotExists(
//       Database db, String table, String column, String definition) async {
//     final tableInfo = await db.rawQuery("PRAGMA table_info($table)");
//     final exists = tableInfo.any((col) => col['name'] == column);

//     if (!exists) {
//       await db.execute("ALTER TABLE $table ADD COLUMN $column $definition");
//       print("Added column: $column to table $table");
//     }
//   }

//   // ADD THIS FUNCTION
//   static Future<void> exportDb() async {
//     final dbPath = join(await getDatabasesPath(), 'notes_app.db');
//     final file = File(dbPath);

//     final newPath = '/storage/emulated/0/Download/notes_app.db';

//     await file.copy(newPath);

//     print(" DB exported to: $newPath");
//   }
// }
