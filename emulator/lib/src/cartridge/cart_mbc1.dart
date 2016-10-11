// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_mbc1.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/11 16:08:47 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";

import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartMBC1 extends Cartridge.ACartridge  {

  int _mode = 0;
  int _bankno_ROM = 0;
  int _bankno_RAM = 0;
  bool _enableRAM = false;

  CartMBC1.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    return this.rom.pull8_unsafe(memAddr);
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
