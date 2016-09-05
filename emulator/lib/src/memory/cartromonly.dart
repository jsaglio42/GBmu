// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartmbc0.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 16:23:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/memory/ram.dart" as Ram;
import "package:emulator/src/memory/rom.dart" as Rom;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;
import "package:emulator/src/memory/imbc.dart" as Imbc;

class CartRomOnly extends Cartridge.Cartridge  {

  // Not working ... should be working : http://stackoverflow.com/questions/13272035/how-do-i-call-a-super-constructor-in-dart
  // CartMbc0(Rom.Rom rom, Ram.Ram ram)
  //   : super._private(rom, ram);

  CartRomOnly.internal(Rom.Rom rom, Ram.Ram ram) : super.internal(rom, ram);

  @override int pullMem8(int memAddr) { 
    assert(memAddr >= 0 && memAddr < this.rom.size);
    return this.rom.pull8(memAddr);
  }
  
  @override int pullMem16(int memAddr){ return 0x42;
    assert(memAddr >= 0 && memAddr < this.rom.size);
    return this.rom.pull16(memAddr);
  }

  // Should we throw?
  @override void pushMem8(int memAddr, int byte) {}
  @override void pushMem16(int memAddr, int word) {}

}
