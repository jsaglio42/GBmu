// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalram.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 23:50:17 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

class InternalRam extends Ser.RecursivelySerializable {

  Uint8List _data = new Uint8List(IRAM_BANK_COUNT * IRAM_BANK_SIZE);

  /* API **********************************************************************/
  void reset() {
    _data.fillRange(0, _data.length, 0);
    return ;
  }

  int pull8(int memAddr, int bankID) {
    assert(memAddr >= INTERNAL_RAM_FIRST && memAddr <= INTERNAL_RAM_LAST
      , 'pull8: invalid memAddr $memAddr');
    memAddr -= INTERNAL_RAM_FIRST;
    if (memAddr < IRAM_BANK_SIZE)
      return _data[memAddr];
    else
      return _data[_getOffsetIRAM(memAddr, bankID)];
  }

  void push8(int memAddr, int bankID, int v) {
    assert(memAddr >= INTERNAL_RAM_FIRST && memAddr <= INTERNAL_RAM_LAST
      , 'pull8: invalid memAddr $memAddr');
    memAddr -= INTERNAL_RAM_FIRST;
    if (memAddr < IRAM_BANK_SIZE)
      _data[memAddr] = v;
    else
      _data[_getOffsetIRAM(memAddr, bankID)] = v;
  }

  int _getOffsetIRAM(int memAddr, int bankID) {
    return ((bankID * IRAM_BANK_SIZE) + (memAddr % IRAM_BANK_SIZE));
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_data', () => new Uint8List.fromList(_data), (v) {
            _data = new Uint8List.fromList(v);
          }),
    ];
  }

}
