// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   local_storage.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 10:56:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 17:26:10 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import './variants.dart';

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsEvent {
  final String key;
  final String oldValue;
  final String newValue;
  const LsEvent(this.key, {String oldValue, String newValue})
      : oldValue = oldValue
      , newValue = newValue;
}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

abstract class LsEntry {

  // ATTRIBUTES ************************************************************* **
  Life _life;

  // CONTRUCTION ************************************************************ **
  factory LsEntry.json_exn(String keyJson, String valueJson) {

    final Map<String, dynamic> key = JSON.decode(keyJson);

    if (!key.containsKey('uid') || !(key['uid'] is int) || key['uid'] < 0)
      throw new Exception('Bad JSON $key');
    switch (key['type']) {
      case ('Rom') : return new LsRom.json_exn(key['uid'], valueJson);
      case ('Ram') : return new LsRam.json_exn(key['uid'], valueJson);
      // case ('Ss') : return new LsSs.json_exn(key['uid'], valueJson);
      default: throw new Exception('Bad JSON $key');
    }
  }

  LsEntry.unsafe(this.uid, this.type, this._life, this.idbid);

  // factory LsEntry.kill(LsEntry src) {
  //   assert(src.life is Alive, "LsEntry.kill dead parameter");
  //   if (src.type is Rom)
  //     return new LsRom.kill(src);
  //   else if (src.type is Ram)
  //     return new LsRam.kill(src);
  //   // else if (src.type is Ss)
  //   //   return new LsSs.kill(src);
  //   else
  //     assert(false, 'unreachable');
  // }

  // PUBLIC ***************************************************************** **
  String get keyJson => JSON.encode({'uid': this.uid, 'type': '$type'});
  final int uid;
  final Component type;

  String get valueJson;
  Life get life => _life;
  final int idbid;

  void kill() {
    assert(_life is Alive, "$runtimeType.kill()");
    _life = Dead.v;
  }

  String toString() =>
    '$life $type uid#$uid idb#$idbid';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class _EntryInvalid<T> {

  bool call(Map<String, dynamic> map, String key) =>
    map[key] == null || !(map[key] is T);

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsRom extends LsEntry {

  // ATTRIBUTES ************************************************************* **
  final int _ramSize;
  final int _globalChecksum;

  // CONTRUCTION ************************************************************ **
  LsRom.unsafe(
      int uid, Life life, int idbid, this._ramSize, this._globalChecksum)
    : super.unsafe(uid, Rom.v, life, idbid);

  // A Json entry is alive
  factory LsRom.json_exn(int uid, String valueJson) {

    final Map<String, dynamic> value = JSON.decode(valueJson);

    if (new _EntryInvalid<int>()(value, 'idbid')
        || new _EntryInvalid<int>()(value, '_ramSize')
        || new _EntryInvalid<int>()(value, '_globalChecksum'))
      throw new Exception('Bad JSON $value');

    return new LsRom.unsafe(
        uid, Alive.v, value['idbid'], value['_ramSize'],
        value['_globalChecksum']);
  }

  // LsRom.kill(LsRom src)
  //   : _ramSize = src.ramSize
  //   , _globalChecksum = src.globalChecksum
  //   , super.unsafe(src.uid, Rom.v, Dead.v, src.idbid);

  // PUBLIC ***************************************************************** **
  String get valueJson =>
    JSON.encode({
      'idbid': idbid,
      '_ramSize': _ramSize,
      '_globalChecksum': _globalChecksum
    });

  int get ramSize => _ramSize;
  int get globalChecksum => _globalChecksum;

  String toString() =>
    '${super.toString()} rs:$_ramSize gc:$_globalChecksum';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

abstract class LsChip extends LsEntry {

  // ATTRIBUTES ************************************************************* **

  // CONTRUCTION ************************************************************ **
  // LsChip.kill(int uid, Chip type, Life life, int idbid, this.romUid)
  //   : super.kill(uid, type, life, idbid);

  LsChip.unsafe(int uid, Chip type, Life life, int idbid, this.romUid)
    : super.unsafe(uid, type, life, idbid);

  factory LsChip.unbind(LsChip c) {
    assert(c.romUid.isSome, "LsChip.unbind($c)");
    assert(c.life is Alive, "LsChip.unbind($c)");

    if (c.type is Ram)
      return new LsRam.unbind(c);
    // else if (c.type is Ss)
    // return new LsSs.unbind(c);
  }

  factory LsChip.bind(LsChip c, int romUid) {
    assert(c.romUid.isNone, "LsChip.bind($c)");
    assert(c.life is Alive, "LsChip.bind($c)");

    if (c.type is Ram)
      return new LsRam.bind(c, romUid);
    // else if (c.type is Ss)
      // return new LsSs.bind(c);
  }

  // PUBLIC ***************************************************************** **
  final Ft.Option<int> romUid;

  String toString() =>
    '${super.toString()} (rom ${romUid.isSome ? "#${romUid.v}" : "none"})';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsRam extends LsChip {

  // ATTRIBUTES ************************************************************* **
  final int _size;

  // CONTRUCTION ************************************************************ **
  LsRam.unsafe(int uid, Life life, int idbid, this._size, Ft.Option<int> romUid)
    : super.unsafe(uid, Ram.v, life, idbid, romUid);

  // A Json entry is always alive
  factory LsRam.json_exn(int uid, String valueJson) {

    final Map<String, dynamic> value = JSON.decode(valueJson);
    final Ft.Option<int> romUid = new _EntryInvalid<int>()(value, 'romUid')
      ? new Ft.Option<int>.none()
      : new Ft.Option<int>.some(value['romUid']);

    if (new _EntryInvalid<int>()(value, 'idbid')
        || new _EntryInvalid<int>()(value, '_size'))
      throw new Exception('Bad JSON $value');

    return new LsRam.unsafe(uid, Alive.v, value['idbid'], value['_size'], romUid);
  }

  // LsRam.kill(LsRam src)
  //   : _size = src.size
  //   , super.unsafe(src.uid, Ram.v, Dead.v, src.idbid, src.romUid);

  LsRam.unbind(LsRam src)
    : _size = src.size
    , super.unsafe(src.uid, Ram.v, src.life, src.idbid,
        new Ft.Option<int>.none());

  LsRam.bind(LsRam src, int romUid)
    : _size = src.size
    , super.unsafe(src.uid, Ram.v, src.life, src.idbid,
        new Ft.Option<int>.some(romUid));

  // PUBLIC ***************************************************************** **
  String get valueJson =>
    JSON.encode(romUid.isNone
        ? {
          'idbid': idbid,
          '_size': _size,
        }
        : {
          'idbid': idbid,
          '_size': _size,
          'romUid': romUid.v,
        });

  int get size => _size;

  String toString() =>
    '${super.toString()} sz:$_size';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **
