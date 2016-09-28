// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_indexeddb.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 15:05:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 19:22:52 by ngoguey          ###   ########.fr       //
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

import './variants.dart';
import './local_storage.dart';

import './tmp_emulator_enums.dart';
import './tmp_emulator_types.dart' as Emulator;

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
    Ft.log('PlatformIDB', 'start', [dbf]);
    // dbf.deleteDatabase(_DBNAME); //debug
    _db = await dbf.open(_DBNAME, version: 1, onUpgradeNeeded:_initialUpgrade);
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

  //TODO: openKeyCursor
  Async.Future<bool> contains(Component c, int id) async {
    Idb.Transaction tra;
    bool found = false;

    Ft.log('PlatformIDB', 'contains', [c, id]);
    tra = _db.transaction(c.toString(), 'readonly');
    await tra.objectStore(c.toString())
    .openCursor(key: id)
    .first
    .then((Idb.Cursor cur) {
      found = true;
    });
    return tra.completed.then((_) => found);
  }

  Async.Future<Emulator.Serializable> fetch(Component c, int id) async {
    Idb.Transaction tra;
    dynamic serialized;

    Ft.log('PlatformIDB', 'fetch', [c, id]);
    tra = _db.transaction(c.toString(), 'readonly');
    serialized = await tra.objectStore(c.toString())
    .getObject(id);
    return tra.completed.then((_) =>
        new Emulator.Serializable.unserialize(c, serialized));
  }

  // PRIVATE **************************************************************** **

}