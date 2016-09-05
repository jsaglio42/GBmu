// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   rom.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:56:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/02 15:33:48 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/memory/rom_headerdecoder.dart" as Romhdecoder;

/* Rom Interface **************************************************************/

abstract class IRom {

  int   get size;

  int pull8(int romAddr);
  int pull16(int romAddr);
  Uint8List pull8List(int romAddr, int len);

}

/* Rom Implementation *********************************************************/

class Rom extends IRom with Romhdecoder.RomHeaderDecoder {

  final Uint8List data;
  final Uint16List view16;

  Rom(Uint8List d)
    : data = d
    , view16 = d.buffer.asUint16List();

  int pull8(int romAddr)
  {
    assert(romAddr >= 0 && romAddr < data.length);
    return this.data[romAddr];
  }

  int pull16(int romAddr)
  {
    assert(romAddr % 2 == 0);
    assert(romAddr >= 0 && romAddr < data.length);
    final int addrView16 = romAddr ~/ 2;
    return view16[addrView16];
  }

  Uint8List pull8List(int romAddr, int len)
  {
    assert(romAddr >= 0 && romAddr + len < data.length);
    return new Uint8List.view(data.buffer, romAddr, len);
  }

  int get size => data.length;

}
