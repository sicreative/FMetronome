import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'common_helper.dart';



class Db {
  static int dbversion = 1;
  static const String db_file = 'pref_database.db';
  static const String db_preftable = "pref";
  static Db? _self;
  static String db_search = "";
  Future<Database>? database;



  Db() {}

  static Future<void> openDB() async {
    if (_self == null) _self = Db();

    if (_self!.database == null) await _self!._openDB();

    final Database db = (await _self!.database)!;

    if (!db.isOpen) await _self!._openDB();

    return;
  }

  Future<void> _openDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), db_file),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE pref(id INTEGER PRIMARY KEY,tempo INTEGER, beat1 INTEGER,beat2 INTEGER,rhythm INTEGER,pitch INTEGER,tone INTEGER)");

        return  db.insert(db_preftable, {
          'id': 0,
          'tempo': 30,
          'beat1': 1,
          'beat2': 0,
          'rhythm': 0,
          'pitch': 0,
          'tone': 1,

        });


      },
      onUpgrade: (db, oldversion, newversion) {
        // Work for latest upgrade
      },
      onDowngrade: (db, oldversion, newversion) {
        // Not possible downgrade
        assert(oldversion <= newversion);
      },

      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: dbversion,
    );

    assert(database != null);


  }

  static Future<void> closeDB() async {
    if (_self != null) _self!._closeDB();

    _self = null;
  }

  Future<void> _closeDB() async {
    if (database == null) return;
    final Database db = await database!;
    if (db.isOpen) db.close();

    assert(!db.isOpen);
  }






  static void setPref(String type, int value) async {
    if (_self == null) await openDB();
    _self!._setPref(type, value);
  }

  Future<int> _setPref(String type, int value) async {
    final Database db = await database!;
    return db.update(db_preftable, {'$type': '$value'});
  }



  static Future<int> getPref(String type) async {
    if (_self == null) await openDB();
    return _self!._getPref(type);
  }

  Future<int> _getPref(String type) async {
    if (database == null) return 0;
    final Database db = await database!;
    final List<Map<String, dynamic>> prefs = await db.query(db_preftable);
    return prefs[0][type];
  }



}

