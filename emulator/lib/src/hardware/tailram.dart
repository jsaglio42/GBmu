// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailram.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/28 17:26:04 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

class TailRam extends Ser.RecursivelySerializable {

  Uint8List _data = new Uint8List(TAIL_RAM_SIZE);

  /* API *********************************************************************/
  void reset() {
    _data.fillRange(0, _data.length, 0);
    this.push8(0xFF10, 0x80);
    this.push8(0xFF11, 0xBF);
    this.push8(0xFF12, 0xF3);
    this.push8(0xFF14, 0xBF);
    this.push8(0xFF16, 0x3F);
    this.push8(0xFF17, 0x00);
    this.push8(0xFF19, 0xBF);
    this.push8(0xFF1A, 0x7F);
    this.push8(0xFF1B, 0xFF);
    this.push8(0xFF1C, 0x9F);
    this.push8(0xFF1E, 0xBF);
    this.push8(0xFF20, 0xFF);
    this.push8(0xFF21, 0x00);
    this.push8(0xFF22, 0x00);
    this.push8(0xFF23, 0xBF);
    this.push8(0xFF24, 0x77);
    this.push8(0xFF25, 0xF3);
    this.push8(0xFF26, 0xF1);
  }

  void push8(int addr, int v) {
    assert(addr & ~0xFFFF == 0, 'push8: invalid addr $addr');
    assert(addr >= 0xFF00, 'push8: invalid addr $addr');
    _data[addr & 0xFF] = v;
  }

  int pull8(int addr) {
    assert(addr & ~0xFFFF == 0, 'pull8: invalid addr $addr');
    assert(addr >= 0xFF00, 'pull8: invalid addr $addr');
    return _data[addr & 0xFF];
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
