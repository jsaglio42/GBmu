// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   filedb.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/14 13:00:45 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/14 19:22:49 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/memory/rom.dart';
import 'package:emulator/src/memory/ram.dart';

import 'package:emulator/enums.dart';

// http://dartdoc.takyam.com/docs/tutorials/indexeddb/

const String _DBNAME = 'GBmu_db';

enum IdbStore {
  Rom, Ram, Ss, Cart,
}

// Conversions

typedef DatabaseEntry proxyOfMap_t(int index, Map<String, dynamic> map);

final Map<IdbStore, proxyOfMap_t> _proxyOfMap = {
  IdbStore.Rom: (int i, Map<String, dynamic> map) {
    final Rom r = new Rom(map['data']);
    return new _RomProxy(i, r.pullHeaderValue(RomHeaderField.RAM_Size),
        r.pullHeaderValue(RomHeaderField.Global_Checksum));
  },
  IdbStore.Ram: (int i, Map<String, dynamic> map) {
    return new _RamProxy(i, map['data'].size);
  },
  IdbStore.Cart: (int i, Map<String, dynamic> map) {
    return new _CartProxy(
        i, map['rom'], ram: map['ram'], ssList: map['ssList']);
  },
    // Ss: (int i, r) => new _SsProxy(i, ) // TODO: save states
};

typedef Map<String, dynamic> mapOfProxy_t(DatabaseEntry e);

final Map<IdbStore, mapOfProxy_t> _mapOfProxy = {
  IdbStore.Cart: (_CartProxy e) => {
    'rom': e.rom,
    'ram': e.ramOpt,
    'ssList': e.ssOptList,
  },
};

// Template method pattern
abstract class _IdbStoreIterator {

  final Idb.Transaction _tra;
  final Async.Stream<Idb.CursorWithValue> _cur;

  _IdbStoreIterator.transaction(Idb.Transaction tra, IdbStore v)
    : _tra = tra
    , _cur = tra
    .objectStore(v.toString())
    .openCursor(autoAdvance: true);

  _IdbStoreIterator(Idb.Database db, IdbStore v, String type)
    : this.transaction(db.transaction(v.toString(), type), v);

}

// Callable class
class _IdbForeach extends _IdbStoreIterator {

  _IdbForeach(Idb.Database db, IdbStore v)
    : super(db, v, 'readonly');

  Async.Future call(dynamic fun) {
    _cur.forEach((Idb.CursorWithValue cur) {
      print('salutlol ca va thtow');
      fun(cur.key, cur.value);
    });
    return _tra.completed;
  }

}

// Callable class
class _IdbFold<T> extends _IdbStoreIterator {

  _IdbFold(Idb.Database db, IdbStore v)
    : super(db, v, 'readonly');

  Async.Future<T> call(T v, dynamic fun) {
    _cur.forEach((Idb.CursorWithValue cur) {
      v = fun(v, cur.key, cur.value);
    });
    return _tra.completed.then((_) => v);
  }

}

abstract class DatabaseEntry {
  int get id;
}

class _RomProxy implements DatabaseEntry {
  final int id;
  final int ramSize;
  final int globalChecksum;

  _RomProxy(this.id, this.ramSize, this.globalChecksum);
}

class _SsProxy implements DatabaseEntry {
  final int id;
  final int romGlobalChecksum;

  _SsProxy(this.id, this.romGlobalChecksum);
}

class _RamProxy implements DatabaseEntry {
  final int id;
  final int size;

  _RamProxy(this.id, this.size);
}

// _CartProxy is also what is stored in iDB
class _CartProxy implements DatabaseEntry {
  final int id;
  final int rom;
  final int ramOpt;
  final List<int> ssOptList;

  _CartProxy(this.id, this.rom, {int ram, List<int> ssList})
    : ramOpt = ram
    , ssOptList = new List<int>.generate(4, (int i) =>
        i >= ssList.length ? null : ssList[i], growable: false);

  _CartProxy.copyTouchRam(_CartProxy src, int ram)
    : id = src.id
    , rom = src.rom
    , ram = ram
    , ssOptList = new List<int>.from(src.ssOptList);

  _CartProxy.copyTouchSs(_CartProxy src, int ss, int index)
    : id = src.id
    , rom = src.rom
    , ram = src.ramOpt
    , ssOptList = new List<int>.generate(4, (int i) =>
        i == index ? ss : src.ssOptList[i], growable: false);
}

class DatabaseProxy {

  final Idb.Database _db;
  final Map<int, _RomProxy> _roms;
  final Map<int, _RamProxy> _rams;
  final Map<int, _SsProxy> _sss;
  final Map<int, _CartProxy> _carts;

  DatabaseProxy(this._db, this._roms, this._rams, this._sss, this._carts);

  bool joinable(DatabaseEntry src, _CartProxy target) {
    switch (src.runtimeType) {
      case (_RamProxy):
        return (src as _RamProxy).size == target.ramSize;
      case (_SsProxy):
        return (src as _SsProxy).romGlobalChecksum == target.globalChecksum;
      default:
        assert(false, 'DatabaseProxy#joinable($src, $target)');
        break ;
    }
  }

  Async.Future join(DatabaseEntry src, _CartProxy target, int slot) {
    Idb.Transaction tra;
    _CartProxy newCart;

    Ft.log('DatabaseProxy', 'join', [src, target, slot]);
    switch (src.runtimeType) {
      case (_RamProxy):
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
      // case (_SsProxy):
      //   assert(slot >= 0 && slot < 4, 'DatabaseProxy#join($src, $target, $slot)');
      //   break ;
      default:
        assert(false, 'DatabaseProxy#join($src, $target, $slot)');
        break ;
    }
  }

  Async.Future<Map<String, dynamic>> info(DatabaseEntry component) {

  }

  Async.Future addRom(String filename, Uint8List data) {
    Idb.Transaction tra;
    int romIndex, cartIndex;
    final romMap = {'filename': filename, 'data': data};
    var cartMap;

    Ft.log('DatabaseProxy', 'addRom', [filename, data]);
    tra = _db.transaction(
        [IdbStore.Cart.toString(), IdbStore.Rom.toString()], 'readwrite');
    tra.objectStore(IdbStore.Rom.toString())
      .add(romMap)
      ..then((int j){
        print('romAdded');
        romIndex = j;
        cartMap = {
          'rom': j,
          'ram': null,
          'ssList': [null, null, null, null],
        };
        tra.objectStore(IdbStore.Cart.toString())
          .add(cartMap)
          ..then((int j){
            print('cartAdded');
            cartIndex = j;
          });

      });
    return tra.completed.then((_){
          print('tra done');
          _roms[romIndex] = _proxyOfMap[IdbStore.Rom](romIndex, romMap);
          _carts[cartIndex] = _proxyOfMap[IdbStore.Cart](cartIndex, cartMap);
        });
  }

  String toString() =>
    'roms: $_roms\nrams: $_rams\nsss: $_sss\ncarts: $_carts';


}

Async.Future<DatabaseProxy> _makeFromExistant(Idb.Database db) async {

  Ft.log('filedb.dart', '_makeFromExistant#', [db]);

  if (db.objectStoreNames.length != IdbStore.values.length) {
    Ft.log('filedb.dart', '_makeFromExistant#wrong-number-of-store');
    throw new Exception('wrong-number-of-store');
  }
  if (db.objectStoreNames.toSet().containsAll(IdbStore.values)) {
    Ft.log('filedb.dart', '_makeFromExistant#store-with-bad-name');
    throw new Exception('store-with-bad-name');
  }

  Async.Future<Map> proxyMapOfStore(IdbStore store, toProxyFunc) async
  {
    return new _IdbFold(db, store)({}, (Map acc, int k, var v) {
      // if (!v.invariants) //TODO: implement `invariants` method on all 4 containers
        // throw new Exception('corrupted $v');
      acc[k] = toProxyFunc(k, v);
      return acc;
    });
  }
  final List<Map> maps = await Async.Future.wait([
    proxyMapOfStore(IdbStore.Rom, _proxyOfMap[IdbStore.Rom]),
    proxyMapOfStore(IdbStore.Ram, _proxyOfMap[IdbStore.Ram]),
    // proxyMapOfStore(IdbStore.Rom, _proxyOfMap[Ss]),     //TODO: save states
  ]);
  final Map<int, _RomProxy> roms = maps[0];
  final Map<int, _RamProxy> rams = maps[1];
  // final Map<int, _SsProxy> sss = maps[2];
  final Map<int, _SsProxy> sss = {};
  final Map<int, _CartProxy> carts = {};

  await new _IdbForeach(db, IdbStore.Cart)((int k, Map<String, dynamic> v) {
    carts[k] = _proxyOfMap[IdbStore.Cart](k, v);
    // TODO: check that all fields of `_CartProxy` are valid
    return ;
  });

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

  return new DatabaseProxy(db, <int, _RomProxy>{}, <int, _RamProxy>{},
      <int, _SsProxy>{}, <int, _CartProxy>{});

}

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
