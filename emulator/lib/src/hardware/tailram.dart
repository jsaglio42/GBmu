// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailram.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 23:07:47 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

class TailRam {

  final Uint8List _data = new Uint8List(TAIL_RAM_SIZE);

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

  void push8(int memAddr, int v) {
    memAddr -= TAIL_RAM_FIRST;
  	_data[memAddr] = v;
  }

  int pull8(int memAddr) {
    memAddr -= TAIL_RAM_FIRST;
  	return _data[memAddr];
  }

}
