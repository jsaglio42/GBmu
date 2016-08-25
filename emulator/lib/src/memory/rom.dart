// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   rom.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:56:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 17:08:40 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/enums.dart";
import "package:emulator/src/memory/rom_header.dart" as Romheader;

class Rom {

  final Uint8List _data;
  final Uint16List _view16;

  Rom(Uint8List d)
    : _data = d
    , _view16 = d.buffer.asUint16List();

  dynamic	pullHeader(RomHeaderField f)
  {
    //TODO: Fix info.valueConverter to take the full rom pointer.
    // return Romheader.headerFieldInfos[f.index].converter;
    return 0x42;
  }

  int		pull8(int romAddr)
  {
    assert(romAddr >= 0 && romAddr < _data.length,
        "Rom.pull8($romAddr)\tout of range");
    return _data[romAddr];
  }

  int		pull16(int romAddr)
  {
    final int addrView16 = romAddr / 2;

    assert(romAddr >= 0 && romAddr < _data.length,
        "Rom.pull16($romAddr)\tout of range");
    return _view16[addrView16];
  }
  int		get size => _data.length;

}
