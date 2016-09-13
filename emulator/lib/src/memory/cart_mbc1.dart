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

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";

import "package:emulator/src/memory/data.dart" as Data;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

class CartMBC1 extends Cartridge.ACartridge  {

  CartMBC1.internal(Data.Rom rom, Data.Ram ram) : super.internal(rom, ram);

  @override int pullRom(int memAddr, DataType t) {
    assert (memAddr >= CARTRIDGE_ROM_FIRST && memAddr <= CARTRIDGE_ROM_LAST);
    return this.rom.pull(memAddr, t);
  }

  @override int pullRam(int memAddr, DataType t) {
    throw new Exception('ROM_ONLY: RAM Operation not supported');
  }

  @override void pushRom(int memAddr, int v, DataType t) {
    throw new Exception('ROM_ONLY: MBC Operations not supported');
  }

  @override void pushRam(int memAddr, int v, DataType t) {
    throw new Exception('ROM_ONLY: RAM Operation not supported');
  }

}
