// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_romonly.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 12:43:18 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartRomOnly extends Cartridge.ACartridge  {

  CartRomOnly.internal(Cartridge.CartridgeRom rom, Cartridge.CartridgeRam ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    assert (memAddr >= CARTRIDGE_ROM_FIRST && memAddr <= CARTRIDGE_ROM_LAST);
    return this.rom.pull8(memAddr - CARTRIDGE_ROM_FIRST);
  }

  @override int pull8_Ram(int memAddr) {
    throw new Exception('ROM_ONLY: RAM Operation not supported');
  }

  @override void push8_Rom(int memAddr, int v) {
    throw new Exception('ROM_ONLY: MBC Operations not supported');
  }

  @override void push8_Ram(int memAddr, int v) {
    throw new Exception('ROM_ONLY: RAM Operation not supported');
  }

}
