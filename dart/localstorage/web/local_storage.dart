// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   local_storage.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 10:56:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 17:42:15 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:convert';

import './variants.dart';

abstract class LsEntry {

  // CONTRUCTION ************************************************************ **
  factory LsEntry.json_exn(String keyJson, String valueJson) {

    final Map<String, dynamic> key = JSON.decode(keyJson);

    if (!key.containsKey('uid') || !(key['uid'] is int) || key['uid'] < 0)
      throw new Exception('Bad JSON $key');
    switch (key['type']) {
      case ('Rom') : return new LsRom.json_exn(key['uid'], valueJson);
      // case ('Ram') : return new LsRam.json_exn(key['uid'], valueJson);
      // case ('Ss') : return new LsSs.json_exn(key['uid'], valueJson);
      default: throw new Exception('Bad JSON $key');
    }
  }

  LsEntry.unsafe(this.uid, this.type, this.life, this.idbid);

  factory LsEntry.kill(LsEntry src) {
    assert(src.life is Alive, "LsEntry.kill dead parameter");
    if (src.type is Rom)
      return new LsRom.kill(src);
    // else if (src.type is Ram)
    //   return new RamEntry.kill(sc);
    // else if (src.type is Ss)
    //   return new SsEntry.kill(sc);
    else
      assert(false, 'unreachable');
  }

  // PUBLIC ***************************************************************** **
  String get keyJson => JSON.encode({'uid': this.uid, 'type': '$type'});
  final int uid;
  final Component type;

  String get valueJson;
  final Life life;
  final int idbid;

}

class _EntryInvalid<T> {
  bool call(Map<String, dynamic> map, String key) =>
    map[key] == null || !(map[key] is T);
}

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

    bool entryValid(String name, Type valType) =>
      value['name'] != null && valType == value['name'].runtimeType;

    if (new _EntryInvalid<int>()(value, 'idbid')
        || new _EntryInvalid<int>()(value, '_ramSize')
        || new _EntryInvalid<int>()(value, '_globalChecksum'))
      throw new Exception('Bad JSON $value');

    return new LsRom.unsafe(
        uid, Alive.v, value['idbid'], value['_ramSize'],
        value['_globalChecksum']);
  }

  LsRom.kill(LsRom src)
    : _ramSize = src.ramSize
    , _globalChecksum = src.globalChecksum
    , super.unsafe(src.uid, Rom.v, Dead.v, src.idbid);

  // PUBLIC ***************************************************************** **
  String get valueJson =>
    JSON.encode({
      'idbid': idbid,
      '_ramSize': _ramSize,
      '_globalChecksum': _globalChecksum
    });

  int get ramSize => _ramSize;
  int get globalChecksum => _globalChecksum;

}
