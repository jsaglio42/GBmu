// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   local_storage_components.dart                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 14:36:16 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 16:06:57 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library local_storage_components;

import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import './variants.dart';

part './local_storage_components_intf.dart';

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
    : super._unsafe(uid, Rom.v, life, idbid);

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

  // PUBLIC ***************************************************************** **
  String get valueJson =>
    JSON.encode({
      'idbid': idbid,
      '_ramSize': _ramSize,
      '_globalChecksum': _globalChecksum
    });

  int get ramSize => _ramSize;
  int get globalChecksum => _globalChecksum;

  bool isCompatible(LsChip c) {
    if (c.type is Ram)
      return (c as LsRam).size == _ramSize;
    else
      return (c as LsSs).romGlobalChecksum == _globalChecksum;
  }

  String toString() =>
    '${super.toString()} rs:$_ramSize gc:$_globalChecksum';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsRam extends _LsRomParent implements LsChip {

  // ATTRIBUTES ************************************************************* **
  final int _size;

  // CONTRUCTION ************************************************************ **
  LsRam.unsafe(int uid, Life life, int idbid, this._size, Ft.Option<int> romUid)
    : super._unsafe(uid, Ram.v, life, idbid, romUid);

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

  LsRam.unbind(LsRam src)
    : _size = src.size
    , super._unsafe(src.uid, Ram.v, src.life, src.idbid,
        new Ft.Option<int>.none());

  LsRam.bind(LsRam src, int romUid)
    : _size = src.size
    , super._unsafe(src.uid, Ram.v, src.life, src.idbid,
        new Ft.Option<int>.some(romUid));

  // PUBLIC ***************************************************************** **
  String get valueJson =>
    JSON.encode(!isBound
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

class LsSs extends _LsRomParentSlot implements LsChip {

  // ATTRIBUTES ************************************************************* **
  final int _romGlobalChecksum;

  // CONTRUCTION ************************************************************ **
  LsSs.unsafe(int uid, Life life, int idbid, this._romGlobalChecksum,
      Ft.Option<int> romUid, Ft.Option<int> slot)
    : super._unsafe(uid, Ss.v, life, idbid, romUid, slot);

  factory LsSs.json_exn(int uid, String valueJson) {

    final Map<String, dynamic> value = JSON.decode(valueJson);
    final Ft.Option<int> romUid = new _EntryInvalid<int>()(value, 'romUid')
      ? new Ft.Option<int>.none()
      : new Ft.Option<int>.some(value['romUid']);
    final Ft.Option<int> slot = new _EntryInvalid<int>()(value, 'slot')
      ? new Ft.Option<int>.none()
      : new Ft.Option<int>.some(value['slot']);

    if (new _EntryInvalid<int>()(value, 'idbid')
        || new _EntryInvalid<int>()(value, '_romGlobalChecksum'))
      throw new Exception('Bad JSON $value');

    return new LsSs.unsafe(uid, Alive.v, value['idbid'],
        value['_romGlobalChecksum'], romUid, slot);
  }

  LsSs.unbind(LsSs src)
    : _romGlobalChecksum = src.romGlobalChecksum
    , super._unsafe(src.uid, Ss.v, src.life, src.idbid,
        new Ft.Option<int>.none(), new Ft.Option<int>.none());

  LsSs.bind(LsSs src, int romUid, int slot)
    : _romGlobalChecksum = src.romGlobalChecksum
    , super._unsafe(src.uid, Ss.v, src.life, src.idbid,
        new Ft.Option<int>.some(romUid), new Ft.Option<int>.some(slot));

  // PUBLIC ***************************************************************** **
  String get valueJson =>
    JSON.encode(!isBound
        ? {
          'idbid': idbid,
          '_romGlobalChecksum': _romGlobalChecksum,
        }
        : {
          'idbid': idbid,
          '_romGlobalChecksum': _romGlobalChecksum,
          'romUid': romUid.v,
          'slot': slot.v,
        });

  int get romGlobalChecksum => _romGlobalChecksum;

  String toString() =>
    '${super.toString()} rgcs:$_romGlobalChecksum';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **
