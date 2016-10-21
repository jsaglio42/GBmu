// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalram.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 18:16:21 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

const int _BANK_SIZE = 0x1000;
const int _BANK_NO = 8;

class InternalRam {

  final Uint8List _data = new Uint8List(_BANK_NO * _BANK_SIZE);

  /* API **********************************************************************/
  void reset() {
    _data.fillRange(0, _data.length, 0);
    return ;
  }

  int pull8(int memAddr, int bankID) {
    assert(memAddr >= INTERNAL_RAM_FIRST && memAddr <= INTERNAL_RAM_LAST, 'pull8: invalid memAddr $memAddr');
    memAddr -= INTERNAL_RAM_FIRST;
    if (memAddr < _BANK_SIZE)
      return _data[memAddr];
    else
      return _data[(bankID - 1) * _BANK_SIZE + memAddr];
  }

  void push8(int memAddr, int bankID, int v) {
    assert(memAddr >= INTERNAL_RAM_FIRST && memAddr <= INTERNAL_RAM_LAST, 'pull8: invalid memAddr $memAddr');
    memAddr -= INTERNAL_RAM_FIRST;
    if (memAddr < _BANK_SIZE)
      _data[memAddr] = v;
    else
      _data[(bankID - 1) * _BANK_SIZE + memAddr] = v;
  }

}
