// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartmbc0.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:57:36 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/memory/data.dart" as Data;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

class CartRomOnly extends Cartridge.ACartridge  {

  CartRomOnly.internal(Data.Rom rom, Data.Ram ram) : super.internal(rom, ram);

  @override int pullMem8(int memAddr) {
    assert(memAddr >= 0 && memAddr < this.rom.size,
        Ft.loc2Str('CartRomOnly: $this', 'pullMem8', p:[memAddr]));
    return this.rom.pull8(memAddr);
  }

  @override int pullMem16(int memAddr){
    assert(memAddr % 2 == 0,
        Ft.loc2Str('CartRomOnly: $this', 'pullMem16', p:[memAddr]));
    assert(memAddr >= 0 && memAddr < this.rom.size,
        Ft.loc2Str('CartRomOnly: $this', 'pullMem16', p:[memAddr]));
    return this.rom.pull16(memAddr);
  }

  @override void pushMem8(int memAddr, int byte) {
    throw new Exception('ROM_ONLY: pushMem8 not supported');
  }
  @override void pushMem16(int memAddr, int word) {
    throw new Exception('ROM_ONLY: pushMem16 not supported');
  }

}
