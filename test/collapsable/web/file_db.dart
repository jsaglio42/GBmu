// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   file_db.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/11 10:47:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/11 11:57:56 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;

import 'package:ft/ft.dart' as Ft;

// import 'package:emulator/constants.dart';
// import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

const String _DBNAME = 'GBmu_db';
const String _ROMSTORE = 'romStore';
const String _IDK = 'idk';

bool _dbValid(Idb.Database db)
{

  return true;
}

void _dbBuild(Idb.VersionChangeEvent ev) async
{
  Ft.log('file_db.dart', '_dbBuild', [ev]);

  final Idb.Database db = (ev.target as Idb.Request).result;
  final Idb.ObjectStore romStore = db.createObjectStore(_ROMSTORE);

  print(romStore.indexNames);
  print(romStore.name);
  print(romStore.transaction);

  final Idb.Index ind = romStore.createIndex(_IDK, 'fieldlol', unique: true);

}

Async.Future<Idb.Database> _dbMake() async
{
  Ft.log('file_db.dart', '_dbMake');
  assert(Idb.IdbFactory.supported);

  final Idb.IdbFactory dbf = Html.window.indexedDB;
  Idb.Database db;

  if ((await dbf.getDatabaseNames()).any((String s) => s == _DBNAME)) {
    Ft.log('file_db.dart', '_dbMake#db_exists');
    db = await dbf.open(_DBNAME, version: 1, onUpgradeNeeded:(_){
          assert(false, "oups");
        });
    if (!_dbValid(db)) {
      Ft.log('file_db.dart', '_dbMake#db_exists#invalid');
      db.close();
      dbf.deleteDatabase(_DBNAME);
      return dbf.open(_DBNAME, version: 1, onUpgradeNeeded: _dbBuild);
    }
    Ft.log('file_db.dart', '_dbMake#db_exists#valid');
    return db;
  }
  else {
    Ft.log('file_db.dart', '_dbMake#db_noexists');
    return dbf.open(_DBNAME, version: 1, onUpgradeNeeded: _dbBuild);
  }
}


Async.Future init(Emulator.Emulator emu) async
{
  try {
  Html.window.indexedDB.deleteDatabase(_DBNAME); //debug
  } catch (_) {

  }
  Ft.log('file_db.dart', 'init', [emu]);

  // print((await idb.getDatabaseNames()));

  // final Idb.Database db = await idb.open(_DBNAME);

  // print('db: ${db}');
  // print('name: ${db.name}');
  // print('objectStoreNames: ${db.objectStoreNames}');
  // print('version: ${db.version}');

  await _dbMake();
  // db.createObjectStore("ram");


}