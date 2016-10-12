// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   local_storage_components.dart                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 14:36:16 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 16:10:05 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library local_storage_components;

import 'dart:convert';

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;
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

  // CONTRUCTION ************************************************************ **
  LsRom._unsafe(int uid, Life life, Map<String, dynamic> data)
    : super._unsafe(uid, Rom.v, life, data);

  factory LsRom.json_exn(int uid, String valueJson) {
    final Map<String, dynamic> value = JSON.decode(valueJson);

    if (new _EntryInvalid<int>()(value, 'idbid') ||
        new _EntryInvalid<String>()(value, 'fileName') ||
        !value['fileName'].endsWith(ROM_EXTENSION) ||
        new _EntryInvalid<int>()(value, 'ramSize') ||
        new _EntryInvalid<int>()(value, 'globalChecksum')
        )
      throw new Exception('Bad JSON $value');

    return new LsRom._unsafe(uid, Alive.v, value);
  }

  LsRom.ofRom(int uid, int idbid, Emulator.Rom rom)
    : super._unsafe(uid, Rom.v, Alive.v, <String, dynamic>{
      'idbid': idbid,
      'fileName': rom.fileName,
      'ramSize': rom.pullHeaderValue(RomHeaderField.RAM_Size),
      'globalChecksum': rom.pullHeaderValue(RomHeaderField.Global_Checksum),
    });

  // PUBLIC ***************************************************************** **
  int get ramSize => _data['ramSize'];
  int get globalChecksum => _data['globalChecksum'];

  bool isCompatible(LsChip c) {
    if (c.type is Ram)
      return (c as LsRam).size == this.ramSize;
    else
      return (c as LsSs).romGlobalChecksum == this.globalChecksum;
  }

  String toString() =>
    '${super.toString()} rs:$ramSize gc:$globalChecksum';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsRam extends LsChip {

  // CONTRUCTION ************************************************************ **
  LsRam._unsafe(int uid, Life life, Map<String, dynamic> data)
    : super._unsafe(uid, Ram.v, life, data);

  factory LsRam.json_exn(int uid, String valueJson) {
    final Map<String, dynamic> value = JSON.decode(valueJson);

    if (new _EntryInvalid<int>()(value, 'idbid') ||
        new _EntryInvalid<String>()(value, 'fileName') ||
        !value['fileName'].endsWith(RAM_EXTENSION) ||
        new _EntryInvalid<int>()(value, 'size')
        )
      throw new Exception('Bad JSON $value');
    return new LsRam._unsafe(uid, Alive.v, value);
  }

  LsRam.ofRam(int uid, int idbid, Emulator.Ram ram)
    : super._unsafe(uid, Ram.v, Alive.v, <String, dynamic>{
      'idbid': idbid,
      'fileName': ram.fileName,
      'size': ram.size,
    });

  // PUBLIC ***************************************************************** **
  int get size => _data['size'];

  String toString() =>
    '${super.toString()} sz:$size';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **

class LsSs extends LsChip {

  // CONTRUCTION ************************************************************ **
  LsSs._unsafe(int uid, Life life, Map<String, dynamic> data)
    : super._unsafe(uid, Ss.v, life, data);

  factory LsSs.json_exn(int uid, String valueJson) {
    final Map<String, dynamic> value = JSON.decode(valueJson);

    if (new _EntryInvalid<int>()(value, 'idbid') ||
        new _EntryInvalid<String>()(value, 'fileName') ||
        !value['fileName'].endsWith(RAM_EXTENSION) ||
        new _EntryInvalid<int>()(value, 'romGlobalChecksum')
        )
      throw new Exception('Bad JSON $value');
    return new LsSs._unsafe(uid, Alive.v, value);
  }

  LsSs.ofSs(int uid, int idbid, Emulator.Ss ss)
    : super._unsafe(uid, Ram.v, Alive.v, <String, dynamic>{
      'idbid': idbid,
      'fileName': ss.fileName,
      'romGlobalChecksum': ss.romGlobalChecksum,
    });

  // PUBLIC ***************************************************************** **
  int get romGlobalChecksum => _data['romGlobalChecksum'];

  String toString() =>
    '${super.toString()} rgcs:$romGlobalChecksum';

}

// ************************************************************************** **
// ************************************************************************** **
// ************************************************************************** **
