// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   file_db.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/11 10:47:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/11 16:26:35 by ngoguey          ###   ########.fr       //
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

// Some kind on `asynchronous functor`, mixed with the above `Template method`
class _StoreInvariantsIterator<T> extends IdbStoreIterator {

  bool _valid = true;
  bool get valid => _valid;

  _StoreInvariantsIterator(Idb.Database db, IdbStore v)
    : super(db, v, 'readonly');

  void forEach(k, v)
  {
    void err() {
      if (_valid)
        Ft.log('_StoreInvariantsIterator<$T>', 'forEach', [
          '<${k.runtimeType}>$k', '<${v.runtimeType}>$v)']);
      _valid = false;
    };
    if (!(k is int))
      err();
    if (!(v is T))
      err();
    //TODO: Implement `invariants` memfun on all 4 stored classes
    // if (!v.invariants())
      // error();
    return ;
  }

}

Async.Future<bool> _dbValid(Idb.Database db) async
{
  List<_StoreInvariantsIterator> iterators;

  if (db.objectStoreNames.length != IdbStore.values.length) {
    Ft.log('file_db.dart', '_dbValid', ['missing store']);
    return false;
  }
  if (db.objectStoreNames.toSet().containsAll(IdbStore.values)) {
    Ft.log('file_db.dart', '_dbValid', ['bad store name']);
    return false;
  }
  iterators = [
    new _StoreInvariantsIterator<int>(db, IdbStore.Rom), //TODO: put real types here
    new _StoreInvariantsIterator<int>(db, IdbStore.Ram),
    new _StoreInvariantsIterator<int>(db, IdbStore.Ss),
    new _StoreInvariantsIterator<int>(db, IdbStore.Cart),
  ];
  await Async.Future.wait(
      iterators.map((_StoreInvariantsIterator it) => it.tra.completed));
  return iterators.fold(
      true, (bool prev, _StoreInvariantsIterator it) => prev && it.valid);
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
    if (!await _dbValid(db)) {
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


  Ft.log('file_db.dart', 'init#add_debug_entries');
  tra = db.transaction(IdbStore.Ss.toString(), 'readwrite');
  tra.objectStore(IdbStore.Ss.toString())
  ..add(41)
  ..add(42)
  ..add(43);
  await tra.completed;
  Ft.log('file_db.dart', 'init#add_debug_entries#DONE');

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