// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_indexeddb.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 15:05:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/08 13:52:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;
import 'package:component_system/src/tmp_emulator_enums.dart';
import 'package:component_system/src/tmp_emulator_types.dart' as Emulator;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';

const String _DBNAME = 'GBmu_db';

class PlatformIndexedDb {

  // ATTRIBUTES ************************************************************* **
  Idb.Database _db;

  // CONTRUCTION ************************************************************ **
  static PlatformIndexedDb _instance;

  factory PlatformIndexedDb() {
    if (_instance == null)
      _instance = new PlatformIndexedDb._();
    return _instance;
  }

  PlatformIndexedDb._() {
    Ft.log('PlatformIDB', 'contructor');
    assert(Idb.IdbFactory.supported);
  }

  Async.Future start(Idb.IdbFactory dbf) async {
    final Iterable<String> storeNames =
      Component.values.map((v) => v.toString());
    openDb() =>
      dbf.open(_DBNAME, version: 1, onUpgradeNeeded:_initialUpgrade);

    Ft.log('PlatformIDB', 'start', [dbf]);
    _db = await openDb();
    if (!_db.objectStoreNames.toSet().containsAll(storeNames)) {
      Ft.log('PlatformIDB', 'start#reset-db');
      _db.close();
      dbf.deleteDatabase(_DBNAME);
      _db = await openDb();
    }
  }

  void _initialUpgrade(Idb.VersionChangeEvent ev) {
    final Idb.Database db = (ev.target as Idb.Request).result;

    Ft.log('PlatformIDB', '_initialUpgrade', [db]);
    db.createObjectStore(Rom.v.toString(), autoIncrement: true);
    db.createObjectStore(Ram.v.toString(), autoIncrement: true);
    db.createObjectStore(Ss.v.toString(), autoIncrement: true);
  }

  // PUBLIC ***************************************************************** **
  Async.Future<int> add(Component c, Emulator.Serializable s) async {
    Idb.Transaction tra;
    int index;

    Ft.log('PlatformIDB', 'add', [c, s]);
    tra = _db.transaction(c.toString(), 'readwrite');
    index = await tra.objectStore(c.toString()).add(s.serialize());
    return tra.completed.then((_) => index);
  }

  Async.Future delete(Component c, int id) async {
    Idb.Transaction tra;

    Ft.log('PlatformIDB', 'delete', [c, id]);
    tra = _db.transaction(c.toString(), 'readwrite');
    await tra.objectStore(c.toString()).delete(id);
    return tra.completed;
  }

  // Can't open openKeyCursor because of dart lib implementation with webkit
  Async.Future<bool> contains(Component c, int id) async {
    Idb.Transaction tra;
    bool found = false;

    Ft.log('PlatformIDB', 'contains', [c, id]);
    tra = _db.transaction(c.toString(), 'readonly');

    await tra.objectStore(c.toString())
    .openCursor(key: id)
    .take(1)
    .forEach((Idb.Cursor cur) {
      found = true;
    });
    return tra.completed.then((_) => found);
  }

  // PRIVATE **************************************************************** **

}