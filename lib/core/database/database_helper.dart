import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'visits_tracker.db';
  static const int _databaseVersion = 1;

  static Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Local database is not supported on the web. Use a web-compatible storage solution.');
    }
    if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) && databaseFactory != databaseFactoryFfi) {
      databaseFactory = databaseFactoryFfi;
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Visits table
    await db.execute('''
      CREATE TABLE visits (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER NOT NULL,
        visit_date TEXT NOT NULL,
        status TEXT NOT NULL,
        location TEXT NOT NULL,
        notes TEXT,
        activities_done TEXT,
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        local_id TEXT,
        gps_location TEXT
      )
    ''');

    // Customers cache table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Activities cache table
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
