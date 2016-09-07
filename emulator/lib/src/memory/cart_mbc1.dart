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

import "package:emulator/src/memory/data.dart" as Data;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

class CartMBC1 extends Cartridge.ACartridge  {

  CartMBC1.internal(Data.Rom rom, Data.Ram ram) : super.internal(rom, ram);

  @override int pullMem8(int memAddr) { 
    assert(memAddr >= 0 && memAddr < this.rom.size);
    return 0x42;
  }
  
  @override int pullMem16(int memAddr){
    assert(memAddr >= 0 && memAddr < this.rom.size);
    return 0x42;
  }

  // Should we throw?
  @override void pushMem8(int memAddr, int byte) {}
  @override void pushMem16(int memAddr, int word) {}

}
