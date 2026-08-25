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
      version: 9,
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
            is_deleted INTEGER DEFAULT 0,
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

        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date TEXT NOT NULL,            -- Format: YYYY-MM-DD
            time TEXT,                      -- Format: HH:MM
            location TEXT,
            reminder_time TEXT,            -- Fallback/String description
            is_completed INTEGER DEFAULT 0, -- 0 = Upcoming, 1 = Completed
            icon TEXT,                      -- Stores icon identifier string/code point
            color INTEGER,                  -- Stores hex color integer value
            reminder_date TEXT,            -- Format: YYYY-MM-DD
            reminder_timer TEXT            -- Format: HH:MM
          )
        ''');

        // 2. Revision Main Topics (e.g., Algebra, Calculus)
        await db.execute('''
          CREATE TABLE revision_topics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            notes TEXT,
            priority TEXT DEFAULT 'Medium',
            due_date TEXT,
            is_completed INTEGER DEFAULT 0, -- Added the missing comma here!
            FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
          )
        ''');

        // 3. Revision Subtopics / Checklist items (e.g., Linear Equations)
        await db.execute('''
          CREATE TABLE revision_subtopics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            is_completed INTEGER DEFAULT 0, -- 0 = Pending, 1 = Completed
            FOREIGN KEY (topic_id) REFERENCES revision_topics (id) ON DELETE CASCADE
          )
        ''');
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
        if (oldVersion < 6) {
          await _addColumnIfNotExists(db, 'notes', 'is_deleted', "INTEGER DEFAULT 0");
        }
        // Handle migration to version 7 seamlessly for existing users
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date TEXT NOT NULL,
              time TEXT,
              location TEXT,
              reminder_time TEXT,
              is_completed INTEGER DEFAULT 0
            )
          ''');

          // Check and add new schema fields to existing deployments safely
          await _addColumnIfNotExists(db, 'events', 'icon', "TEXT");
          await _addColumnIfNotExists(db, 'events', 'color', "INTEGER");
          await _addColumnIfNotExists(db, 'events', 'reminder_date', "TEXT");
          await _addColumnIfNotExists(db, 'events', 'reminder_timer', "TEXT");

          await db.execute('''
            CREATE TABLE IF NOT EXISTS revision_topics (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              notes TEXT,
              priority TEXT DEFAULT 'Medium',
              due_date TEXT,
              FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS revision_subtopics (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              topic_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              is_completed INTEGER DEFAULT 0,
              FOREIGN KEY (topic_id) REFERENCES revision_topics (id) ON DELETE CASCADE
            )
          ''');
        }
        // Dynamic Migration step to cleanly handle the conversion from Version 7 to Version 8
        if (oldVersion < 8) {
          await _addColumnIfNotExists(
            db,
            'revision_topics',
            'is_completed',
            'INTEGER DEFAULT 0',
          );
        }

        // Catch-all structural upgrade path for version 9 testing environments
        if (oldVersion < 9) {
          await _addColumnIfNotExists(
            db,
            'revision_topics',
            'is_completed',
            'INTEGER DEFAULT 0',
          );
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
