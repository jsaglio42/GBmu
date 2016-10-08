// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   filedb_chunks.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/15 10:25:02 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 17:24:32 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/enums.dart';

enum IdbStore {
  Rom, Ram, Ss, Cart,
}

// Factory method interface
abstract class Factory_intf {
  dynamic proxyOfStorable(Map<String, dynamic> s, int index);
  dynamic emuOfStorable(Map<String, dynamic> s);
  // Future<Map<String, dynamic>> storableFromDb(Idb.Database db, int index);
  Async.Future<Map<int, Map<String, dynamic>>> storablesFromDb(Idb.Database db);
  Map<int, dynamic> proxiesOfStorables(Map<int, Map<String, dynamic>> s);
}

// Factory method implementation
class Factory<EmuType, ProxType extends ProxyEntry> implements Factory_intf {

  final IdbStore _type;
  final _toProxy;
  final _toEmu;

  Factory(this._type,
      ProxType toProxy(Map<String, dynamic> s, int index),
      EmuType toEmu(Map<String, dynamic> s))
    : _toProxy = toProxy
    , _toEmu = toEmu;

  ProxType proxyOfStorable(Map<String, dynamic> s, int index) =>
    _toProxy(s, index);

  EmuType emuOfStorable(Map<String, dynamic> s) =>
    _toEmu(s);

  // Future<Map<String, dynamic>> storableFromDb(Idb.Database db, int index) {
  // }

  Async.Future<Map<int, Map<String, dynamic>>> storablesFromDb(
      Idb.Database db) {
    final Map<int, Map<String, dynamic>> store = <int, Map<String, dynamic>>{};
    final it = new Ft.IdbStoreForeach<int, Map<String, dynamic>>(
        db, _type.toString());

    return it((int k, Map<String, dynamic> v) {
      store[k] = v;
    }).then((_) => store);
  }

  Map<int, ProxType> proxiesOfStorables(Map<int, Map<String, dynamic>> s) {
    final Map<int, ProxType> result = <int, ProxType>{};

    s.forEach((int k, Map<String, dynamic> v){
      result[k] = _toProxy(v, k);
    });
    return result;
  }

}

// Factory method instanciation
final Map<IdbStore, Factory_intf> factories = <IdbStore, Factory_intf>{
  IdbStore.Rom: new Factory<Rom.Rom, RomProxy>(
      IdbStore.Rom, RomProxy.ofDbMap, null),
  IdbStore.Ram: new Factory<Ram.Ram, RamProxy>(
      IdbStore.Ram, RamProxy.ofDbMap, null),
  IdbStore.Ss: new Factory<double, SsProxy>(
      IdbStore.Ss, SsProxy.ofDbMap, null),
  IdbStore.Cart: new Factory<double, CartProxy>(
      IdbStore.Cart, CartProxy.ofDbMap, null),
};

abstract class ProxyEntry {
  int get id;
  IdbStore get type;
}

class RomProxy implements ProxyEntry {
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

  String toString() =>
    "${this.runtimeType}\{"
    "id:$id, ramSize:$ramSize, globalChecksum:$globalChecksum\}";

}

class RamProxy implements ProxyEntry {
  final int id;
  IdbStore get type => IdbStore.Ram;
  final int size;

  RamProxy(this.id, this.size);

  static RamProxy ofDbMap(Map<String, dynamic> map, int index) =>
    new RamProxy(index, map['data'].elementSizeInBytes);

  String toString() =>
    "${this.runtimeType}\{"
    "id:$id, size:$size\}";

}

class SsProxy implements ProxyEntry {
  final int id;
  IdbStore get type => IdbStore.Ss;
  final int romGlobalChecksum;

  SsProxy(this.id, this.romGlobalChecksum);

  static SsProxy ofDbMap(Map<String, dynamic> map, int index) {
    assert(false, 'TODO: Implement SsProxy.ofDbMap');
    return new SsProxy(index, 42);
  }

  String toString() =>
    "${this.runtimeType}\{"
    "id:$id, romGlobalChecksum:$romGlobalChecksum\}";

}

class CartProxy implements ProxyEntry {
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

  String toString() {
    String vToString(v) => v == null ? '' : v.toString();
    String lToString(List l) => l.map(vToString).join(',');

    return
      "${this.runtimeType}\{id:$id, "
      "rom:$rom, "
      "ram:${vToString(ramOpt)}, "
      "ss:[${lToString(ssOptList)}]"
      "\}";
  }

}
