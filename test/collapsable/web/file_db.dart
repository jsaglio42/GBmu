// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   file_db.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/11 10:47:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/11 18:24:09 by ngoguey          ###   ########.fr       //
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

// http://dartdoc.takyam.com/docs/tutorials/indexeddb/

const String _DBNAME = 'GBmu_db';

enum IdbStore {
  Rom, Ram, Ss, Cart,
}

// Template method pattern
abstract class IdbStoreIterator {

  final Idb.Transaction tra;

  IdbStoreIterator.transaction(Idb.Transaction tra, IdbStore v)
    : tra = tra
  {
    tra
    .objectStore(v.toString())
    .openCursor(autoAdvance: true)
    .forEach((Idb.CursorWithValue cur){
      this.forEach(cur.key, cur.value);
    });
  }

  IdbStoreIterator(Idb.Database db, IdbStore v, String type)
    : this.transaction(db.transaction(v.toString(), type), v);

  void forEach(dynamic k, dynamic v);

}

typedef dynamic folder_t(dynamic acc, dynamic key, dynamic v);

class _StoreFold<T> extends IdbStoreIterator {

  final folder_t _f;
  T _value;
  Async.Future<T> get value =>
    this.tra.completed.then((_) => _value);

  _StoreFold(Idb.Database db, IdbStore v, this._value, this._f)
    : super(db, v, 'readonly');

  void forEach(k, v)
  {
    _value = _f(_value, k, v);
  }

}

// Functor
class _DbValidator
{
  final Idb.Database _db;

  _DbValidator(this._db);

  bool _storesPresence()
  {
    if (_db.objectStoreNames.length != IdbStore.values.length) {
      Ft.log('file_db.dart', '_dbValid', ['missing store']);
      return false;
    }
    if (_db.objectStoreNames.toSet().containsAll(IdbStore.values)) {
      Ft.log('file_db.dart', '_dbValid', ['bad store name']);
      return false;
    }
    return true;
  }

  static bool _mapValid(Map map, Type keyType) {
    bool valid = true;
    map.forEach((k, v){
      if (k.runtimeType != int)
        valid = false;
      if (v.runtimeType != keyType)
        valid = false;
      //TODO: Implement `invariants` memfun on all 4 stored classes
      // if (!v.invariants())
      // error();
    });
    if (!valid)
      Ft.log('_DbValidator', '_mapValid', [map, keyType]);
    return valid;
  }

  bool _cartsContent(Map<int, DbCart> carts,
      Set<int> roms, Set<int> rams, Set<int> sss) {

    for (DbCart cart in carts.values) {
      if (cart.romKey == null || !roms.contains(cart.romKey))
        return false;
      roms.remove(cart.romKey);
      if (cart.ramKeyOpt != null) {
        if (!rams.contains(cart.ramKeyOpt))
          return false;
        rams.remove(cart.ramKeyOpt);
      }
      for (int ssIdOpt in cart.ssKeysOpt) {
        if (ssIdOpt != null) {
          if (!sss.contains(ssIdOpt))
            return false;
          sss.remove(ssIdOpt);
        }
      }
    }
    return true;
  }

  static Map _accFun(Map acc, int k, v) {
    acc[k] = v;
    return acc;
  }

  Async.Future<bool> _content() async
  {
    final List<Async.Future<Map>> futs = [
      new _StoreFold(_db, IdbStore.Rom, {}, _accFun).value,
      new _StoreFold(_db, IdbStore.Ram, {}, _accFun).value,
      new _StoreFold(_db, IdbStore.Ss, {}, _accFun).value,
      new _StoreFold(_db, IdbStore.Cart, {}, _accFun).value,
    ];
    final List<Map> maps = await Async.Future.wait(futs);
    final Map roms = maps[0];
    final Map rams = maps[1];
    final Map sss = maps[2];
    final Map carts = maps[3];
    bool valid = true;

    if (!_mapValid(roms, int)
        || !_mapValid(rams, int)
        || !_mapValid(sss, int)
        || !_mapValid(carts, DbCart))
      return false;
    if (roms.length != carts.length)
      return false;
    return _cartsContent(carts, new Set.from(roms.keys),
        new Set.from(rams.keys), new Set.from(sss.keys));
  }

  Async.Future<bool> valid() async =>
    _storesPresence() && await _content();
}

class DbCart {

  final int romKey;
  int ramKeyOpt = null;
  final ssKeysOpt = new List<int>.filled(4, null, growable: false);

  DbCart(this.romKey);

  bool invariants()
    => true;

}

void _dbBuild(Idb.VersionChangeEvent ev) async
{
  Ft.log('file_db.dart', '_dbBuild', [ev]);

  final Idb.Database db = (ev.target as Idb.Request).result;

  IdbStore.values.forEach((v) {
        db.createObjectStore(v.toString(), autoIncrement: true);
      });
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
    if (!await new _DbValidator(db).valid()) {
      Ft.log('file_db.dart', '_dbMake#db_exists#invalid');
      db.close();
      dbf.deleteDatabase(_DBNAME);
      return dbf.open(_DBNAME, version: 1, onUpgradeNeeded: _dbBuild);
    }
    else {
      Ft.log('file_db.dart', '_dbMake#db_exists#valid');
      return db;
    }
  }
  else {
    Ft.log('file_db.dart', '_dbMake#db_noexists');
    return dbf.open(_DBNAME, version: 1, onUpgradeNeeded: _dbBuild);
  }
}

Async.Future init(Emulator.Emulator emu) async
{
  Ft.log('file_db.dart', 'init#make_db', [emu]);
  final Idb.Database db = await _dbMake();
  Idb.Transaction tra;
  Ft.log('file_db.dart', 'init#make_db#DONE');

  Ft.log('file_db.dart', 'init#add_debug_entries');
  tra = db.transaction(IdbStore.Rom.toString(), 'readwrite');
  tra.objectStore(IdbStore.Rom.toString())
  ..add(41)
  ..add(42)
  ..add(43);
  await tra.completed;
  Ft.log('file_db.dart', 'init#add_debug_entries#DONE');


  // Ft.log('file_db.dart', 'init#add_debug_entries');
  // tra = db.transaction(IdbStore.Cart.toString(), 'readwrite');
  // tra.objectStore(IdbStore.Cart.toString())
  // ..add(41)
  // ..add(42)
  // ..add(43);
  // await tra.completed;
  // Ft.log('file_db.dart', 'init#add_debug_entries#DONE');

  Ft.log('file_db.dart', 'init#cursor');
  tra = db.transaction(IdbStore.Rom.toString(), 'readonly');

  tra.objectStore(IdbStore.Rom.toString())
  .openCursor(autoAdvance: true)
  .forEach((Idb.CursorWithValue cur){
        Ft.log('file_db.dart', 'init#cursor_iteration', [cur]);
  });


  await tra.completed;
  Ft.log('file_db.dart', 'init#cursor#DONE');

  return db;

  // ..then((p){
  //       Ft.log('hello', 'lol', p);
  //     })
  // ..catchError((e){
  //       print(e);
  // });

}