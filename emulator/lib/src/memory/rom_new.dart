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
import "package:emulator/src/memory/rom_header_new.dart" as Romheader;

abstract class IRom {

  int   get size;

  int pull8(int romAddr);
  int pull16(int romAddr);
  Uint8List   pull8List(int romAddr, int len);

}

class Rom extends IRom with Romheader.RomHeader {

  final Uint8List data;
  final Uint16List view16;

  Rom(Uint8List d)
    : data = d
    , view16 = d.buffer.asUint16List();

  int		pull8(int romAddr)
  {
    assert(romAddr >= 0 && romAddr < data.length); //, "Rom.pull8($romAddr)\tout of range");
    return this.data[romAddr];
  }

  int		pull16(int romAddr)
  {
    // Implementation with `Uint16List view16` makes the assertion that
    //   words are memory aligned. TODO: verify it
    final int addrView16 = romAddr ~/ 2;

    assert(romAddr >= 0 && romAddr < data.length);//, "Rom.pull16($romAddr)\tout of range");
    return view16[addrView16];
  }

  Uint8List   pull8List(int romAddr, int len)
  {
    assert(romAddr >= 0 && romAddr + len < data.length); //, "Rom.pull8($romAddr)\tout of range");
    return new Uint8List.view(data.buffer, romAddr, len);
  }

  int		get size => data.length;

}

// main () {
//   print('hello world');
//   Romheader.debugRomHeader();
// }