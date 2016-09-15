// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   filedb_chunks.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/15 10:25:02 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 12:11:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/enums.dart';
// import 'package:emulator/src/memory/ram.dart' as Ram;

enum IdbStore {
  Rom, Ram, Ss, Cart,
}

/* DatabaseProxy
 *
 * DatabaseProxyEntry {RomProxy, RamProxy, SsProxy, CartProxy}
 * StoreProxies<T> {Map<int, T>} (T from DatabaseProxyEntry)
 * DbProxies {Map<IdbStore, dynamic>}
 *
 * DbMap {Map<String, dynamic>}
 * StoreMaps {Map<int, DbMap>}
 * DbMaps {Map<IdbStore, StoreMaps>}
 *
 * Where is the `using` or the `typedef`? Abstraction gets impossible.
 */

Async.Future<Map<int, Map<String, dynamic>>> storeDbMapOfDb(
    Idb.Database db, IdbStore s) {
  final Map<int, Map<String, dynamic>> store = <int, Map<String, dynamic>>{};
  final it =
    new Ft.IdbStoreForeach<int, Map<String, dynamic>>(db, s.toString());

  return it((int k, Map<String, dynamic> v) {
    store[k] = v;
  }).then((_) => store);
}

Async.Future<Map<IdbStore, Map<int, Map<String, dynamic>>>>
  dbMapsOfDb(Idb.Database db) async {
    final futList = [
      storeDbMapOfDb(db, IdbStore.Rom),
      storeDbMapOfDb(db, IdbStore.Ram),
      storeDbMapOfDb(db, IdbStore.Ss),
      storeDbMapOfDb(db, IdbStore.Cart),
    ];
    final mapList = await Async.Future.wait(futList);
    return new Map.fromIterables(IdbStore.values, mapList);
  }

typedef DatabaseProxyEntry _entryOfMap_t(Map<String, dynamic> map, int index);

abstract class DatabaseProxyEntry {
  int get id;
  IdbStore get type;

  static Map<IdbStore, _entryOfMap_t> ofDbMap = <IdbStore, _entryOfMap_t>{
    IdbStore.Rom: RomProxy.ofDbMap,
    IdbStore.Ss: SsProxy.ofDbMap,
    IdbStore.Ram: RamProxy.ofDbMap,
    IdbStore.Cart: CartProxy.ofDbMap,
  };

  static Map<int, dynamic> ofDbMaps(
      Map<int, Map<String, dynamic>> store, IdbStore type) {
    final Map<int, dynamic> result = <int, dynamic>{};
    final _entryOfMap_t mapFun = ofDbMap[type];

    store.forEach((int k, Map<String, dynamic> v) {
      result[k] = mapFun(v, k);
    });
    return result;
  }

}

class RomProxy implements DatabaseProxyEntry {
  final int id;
  IdbStore get type => IdbStore.Rom;
  final int ramSize;
  final int globalChecksum;

  RomProxy(this.id, this.ramSize, this.globalChecksum);

  static RomProxy ofDbMap(Map<String, dynamic> map, int index) {
    final Rom.Rom r = new Rom.Rom(map['data']);

    return new RomProxy(index,
        r.pullHeaderValue(RomHeaderField.RAM_Size),
        r.pullHeaderValue(RomHeaderField.Global_Checksum));
  }


}

class RamProxy implements DatabaseProxyEntry {
  final int id;
  IdbStore get type => IdbStore.Ram;
  final int size;

  RamProxy(this.id, this.size);

  static RamProxy ofDbMap(Map<String, dynamic> map, int index) =>
    new RamProxy(index, map['data'].size);

}

class SsProxy implements DatabaseProxyEntry {
  final int id;
  IdbStore get type => IdbStore.Ss;
  final int romGlobalChecksum;

  SsProxy(this.id, this.romGlobalChecksum);

  static SsProxy ofDbMap(Map<String, dynamic> map, int index) {
    assert(false, 'TODO: Implement SsProxy.ofDbMap');
    return new SsProxy(index, 42);
  }

}

class CartProxy implements DatabaseProxyEntry {
  final int id;
  IdbStore get type => IdbStore.Cart;
  final int rom;
  final int ramOpt;
  final List<int> ssOptList;

  static List<int> _normalizeSsList(List<int> l)
  {
    if (l == null)
      return new List<int>.filled(4, null, growable: false);
    else
      return new List<int>.generate(4, (int i) =>
          i >= l.length ? null : l[i], growable: false);
  }

  CartProxy(this.id, this.rom, {int ram, List<int> ssList})
    : ramOpt = ram
    , ssOptList = _normalizeSsList(ssList);

  CartProxy.copyTouchRam(CartProxy src, int ramOpt)
    : id = src.id
    , rom = src.rom
    , ramOpt = ramOpt
    , ssOptList = new List<int>.from(src.ssOptList, growable: false);

  CartProxy.copyTouchSs(CartProxy src, int ssOpt, int index)
    : id = src.id
    , rom = src.rom
    , ramOpt = src.ramOpt
    , ssOptList = new List<int>.from(src.ssOptList, growable: false)
    ..setAll(index, [ssOpt]);

  Map<String, dynamic> toDbMap() =>
    <String, dynamic>{
      'rom': this.rom,
      'ram': this.ramOpt,
      'ssList': this.ssOptList,
    };

  static CartProxy ofDbMap(Map<String, dynamic> map, int index) =>
    new CartProxy(index, map['rom'], ram: map['ram'], ssList: map['ssList']);
}
