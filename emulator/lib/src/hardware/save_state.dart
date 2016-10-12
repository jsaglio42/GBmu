// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   save_state.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/09 13:55:31 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 16:13:19 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/src/constants.dart';
import 'package:emulator/src/variants.dart' as V;
import 'package:emulator/src/gameboy.dart' as GameBoy;

// TODO: Implement save states

// Save State *************************************************************** **
class Ss extends Object
  implements Data.FileRepr {

  // ATTRIBUTES ************************************************************* **
  int _romGlobalChecksum;
  final String _fileName;

  // CONSTRUCTION *********************************************************** **
  // Only called once in DOM, when an external file is loaded
  Ss.ofFile(String fileName, Uint8List data)
    : _fileName = fileName {
    _romGlobalChecksum = 42;
    Ft.log('Ss', 'ctor.ofFile', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on emulation start request, with data from Idb
  Ss.unserialize(Map<String, dynamic> serialization)
    : serialization['fileName'] as String {
    _romGlobalChecksum = serialization['romGlobalChecksum'] as int;
    Ft.log('Ss', 'ctor.unserialize', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on gameboy snapshot required
  Ss.ofGameBoy(GameBoy.GameBoy gb)
    : _fileName = FileRepr.ssNameOfRomName(gb.c.rom.fileName) {
    _romGlobalChecksum =
      gb.c.rom.pullHeaderValue(RomHeaderField.Global_Checksum);
    Ft.log('Ss', 'ctor.ofGameBoy', [this.fileName, this.terseData]);
  }

  // FROM FILEREPR ********************************************************** **
  V.Component get type => V.Ss.v;
  Map<String, dynamic> get terseData => <String, dynamic>{
    'romGlobalChecksum': 42,
  };

  String get fileName => _fileName;
  dynamic serialize() =>
    <String, dynamic>{
      'romGlobalChecksum': _romGlobalChecksum,
      'fileName': _fileName,
    };

  // PUBLIC ***************************************************************** **
  int get romGlobalChecksum => _romGlobalChecksum;

}
