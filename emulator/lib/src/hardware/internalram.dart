// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalram.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/28 17:25:54 by ngoguey          ###   ########.fr       //
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

  int pull8(int addr, int bankID) {
    assert(addr & ~0xFFF == 0, 'pull8: invalid addr $addr');
    return _data[(bankID * IRAM_BANK_SIZE) + addr];
  }

  void push8(int addr, int bankID, int v) {
    assert(addr & ~0xFFF == 0, 'pull8: invalid addr $addr');
    _data[(bankID * IRAM_BANK_SIZE) + addr] = v;
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
