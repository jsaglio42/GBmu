// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   filedb.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/14 13:00:45 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 17:13:10 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/src/filedb/filedb_chunks.dart';

// http://dartdoc.takyam.com/docs/tutorials/indexeddb/

const String _DBNAME = 'GBmu_db';

class DatabaseProxy {

  // PRIVATE **************************************************************** **

  final Idb.Database _db;
  final Map<int, RomProxy> _roms;
  final Map<int, RamProxy> _rams;
  final Map<int, SsProxy> _sss;
  final Map<int, CartProxy> _carts;
  Async.StreamController<ProxyEntry> _entryMoved;

  // PUBLIC ***************************************************************** **

  // Call at startup
  // Call by `Cart` to retrieve child chips
  Map<int, ProxyEntry> get roms => _roms;
  Map<int, ProxyEntry> get rams => _rams;
  Map<int, ProxyEntry> get sss => _sss;
  Map<int, ProxyEntry> get carts => _carts;

  // Listen from banks
  // Trigger soon after drop
  Async.Stream<ProxyEntry> get entryMoved => _entryMoved.stream;

  DatabaseProxy(this._db, this._roms, this._rams, this._sss, this._carts);

  // Call from banks, on drag start
  bool joinable(ProxyEntry src, CartProxy target) {
    switch (src.type) {
      case (IdbStore.Ram):
        return (src as RamProxy).size == target.ramSize;
      case (IdbStore.SsProxy):
        return (src as SsProxy).romGlobalChecksum == target.globalChecksum;
      default:
        assert(false, 'DatabaseProxy#joinable($src, $target)');
        break ;
    }
  }

  // Call from ??, on drop
  Async.Future join(ProxyEntry src, CartProxy target, int slot) {
    Idb.Transaction tra;
    CartProxy newCart;

    Ft.log('DatabaseProxy', 'join', [src, target, slot]);
    switch (src.type) {
      case (IdbStore.Ram):
        tra = _db.transaction(IdbStore.Cart.toString(), 'readwrite');
        newCart = new _Cart.copyTouchRam(target, src.id);
        tra.objectStore(IdbStore.Cart.toString())
          .openCursor(key: src.id)
          .first((Idb.Cursor cur) {
            cur.update(newCart);
          });
        return tra.completed.then((_) {
          _carts[target.id] = newCart;
          return ;
        });
      // case (IdbStore.Ss):
      //   assert(slot >= 0 && slot < 4, 'DatabaseProxy#join($src, $target, $slot)');
      //   break ;
      default:
        assert(false, 'DatabaseProxy#join($src, $target, $slot)');
        break ;
    }
  }

  Async.Future<Map<String, dynamic>> info(ProxyEntry prox) async {
    switch (prox.type) {
      case (IdbStore.Cart):
        return (prox as CartProxy).toDbMap();
      default:
        assert(false, 'TODO: implement data retrieval');
        break ;
    }
  }

  // Call from `CartBank` on new file loaded
  Async.Future addRom(String filename, Uint8List data) async {
    Idb.Transaction tra;
    int romIndex, cartIndex;
    final Map<String, dynamic> romMap =
    <String, dynamic>{'filename': filename, 'data': data};
    Map<String, dynamic> cartMap;

    Ft.log('DatabaseProxy', 'addRom', [filename]);
    tra = _db.transaction(
        [IdbStore.Cart.toString(), IdbStore.Rom.toString()], 'readwrite');
    romIndex = await tra.objectStore(IdbStore.Rom.toString()).add(romMap);
    cartMap = <String, dynamic>{
      'rom': romIndex,
      'ram': null,
      'ssList': [null, null, null, null],
    };
    cartIndex = await tra.objectStore(IdbStore.Cart.toString()).add(cartMap);
    return tra.completed.then((_){
          _roms[romIndex] = RomProxy.ofDbMap(romMap, romIndex);
          _carts[cartIndex] = CartProxy.ofDbMap(cartMap, cartIndex);
        });
  }

  Async.Future addRam(String filename, Uint8List data) async {
    Idb.Transaction tra;
    int ramIndex;
    final Map<String, dynamic> ramMap =
    <String, dynamic>{'filename': filename, 'data': data};

    Ft.log('DatabaseProxy', 'addRam', [filename]);
    tra = _db.transaction(IdbStore.Ram.toString(), 'readwrite');
    ramIndex = await tra.objectStore(IdbStore.Ram.toString()).add(ramMap);
    return tra.completed.then((_){
          _rams[ramIndex] = RamProxy.ofDbMap(ramMap, ramIndex);
        });
  }

  String toString() =>
    'roms: $_roms\nrams: $_rams\nsss: $_sss\ncarts: $_carts';

}

Async.Future<DatabaseProxy> _makeFromExistant(Idb.Database db) async {

  Ft.log('filedb.dart', '_makeFromExistant#', [db]);

  throw new Exception('debug');

  if (db.objectStoreNames.length != IdbStore.values.length) {
    Ft.log('filedb.dart', '_makeFromExistant#wrong-number-of-store');
    throw new Exception('wrong-number-of-store');
  }
  if (db.objectStoreNames.toSet().containsAll(IdbStore.values)) {
    Ft.log('filedb.dart', '_makeFromExistant#store-with-bad-name');
    throw new Exception('store-with-bad-name');
  }

  final List<Async.Future> futList = [
    factories[IdbStore.Rom].storablesFromDb(db),
    factories[IdbStore.Ram].storablesFromDb(db),
    factories[IdbStore.Ss].storablesFromDb(db),
    factories[IdbStore.Cart].storablesFromDb(db),
  ];
  final List<Map<int, Map<String, dynamic>>> storableList =
  await Async.Future.wait(futList);
  //TODO: Check invariants on maps

  final Map<int, RomProxy> roms =
  factories[IdbStore.Rom].proxiesOfStorables(storableList[0]);
  final Map<int, RamProxy> rams =
  factories[IdbStore.Ram].proxiesOfStorables(storableList[1]);
  final Map<int, SsProxy> sss =
  factories[IdbStore.Ss].proxiesOfStorables(storableList[2]);
  final Map<int, CartProxy> carts =
  factories[IdbStore.Cart].proxiesOfStorables(storableList[3]);

  if (carts.length != roms.length)
    throw new Exception('missing-rom-or-cart-field');
  return new DatabaseProxy(db, roms, rams, sss, carts);

}

Async.Future<DatabaseProxy> _makeFromScratch(Idb.IdbFactory dbf) async {
  Ft.log('filedb.dart', '_makeFromScratch', [dbf]);

  void upgrade(Idb.VersionChangeEvent ev) async
  {
    Ft.log('filedb.dart', '_makeFromScratch#upgrade', [ev]);

    final Idb.Database db = (ev.target as Idb.Request).result;

    IdbStore.values.forEach((v) {
          db.createObjectStore(v.toString(), autoIncrement: true);
        });
  }

  final Idb.Database db = await dbf.open(
      _DBNAME, version: 1, onUpgradeNeeded:upgrade);

  return new DatabaseProxy(db, <int, RomProxy>{}, <int, RamProxy>{},
      <int, SsProxy>{}, <int, CartProxy>{});

}

// PUBLIC ******************************************************************* **

Async.Future<DatabaseProxy> make(Idb.IdbFactory dbf) async {
  Idb.Database db;

  Ft.log('filedb.dart', 'dp#make');
  assert(Idb.IdbFactory.supported);
  if ((await dbf.getDatabaseNames()).any((String s) => s == _DBNAME)) {
    Ft.log('filedb.dart', 'make#db_exists');
    db = await dbf.open(_DBNAME, version: 1, onUpgradeNeeded:(_){
          assert(false, "diledb.dart#make not readchable");
        });
    try {
      return await _makeFromExistant(db);
    } catch (e) {
      Ft.log('filedb.dart', 'make#db_not_retrievable', [e]);
      db.close();
      dbf.deleteDatabase(_DBNAME);
      return _makeFromScratch(dbf);
    }
  }
  else {
    Ft.log('filedb.dart', 'make#db_noexists');
    return _makeFromScratch(dbf);
  }
}
