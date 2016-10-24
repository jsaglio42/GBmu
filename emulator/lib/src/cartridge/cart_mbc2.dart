// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_mbc2.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 17:02:15 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";

import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartMBC2 extends Cartridge.ACartridge  {

  int _bankno_ROM = 1;
  bool _enableRAM = false;

  CartMBC2.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    assert(memAddr & ~0x7FFF == 0, 'pull8_Rom: invalid memAddr $memAddr');
    if (memAddr <= 0x3FFF)
      return this.rom.pull8(memAddr);
    else if (memAddr <= 0x7FFF)
      return this.rom.pull8(_getOffsetROM(memAddr));
    else
      throw new Exception('CartMBC2: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override void push8_Rom(int memAddr, int v) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    assert(memAddr & ~0x7FFF == 0, 'push8_Rom: invalid memAddr $memAddr');
    if (memAddr <= 0x1FFF)
      _setAccessRAM(memAddr);
    else if (memAddr <= 0x3FFF)
      _setBankNoROM(v);
    // else
    //   throw new Exception('CartMBC2: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override int pull8_Ram(int memAddr) {
    if (!_enableRAM)
      throw new Exception('pull8_Ram: RAM not enabled');
    memAddr -= CARTRIDGE_RAM_FIRST;
    return this.ram.pull8(memAddr);
  }

  @override void push8_Ram(int memAddr, int v) {
    if (!_enableRAM)
      // throw new Exception('push8_Ram: RAM not enabled');
      return ;
    memAddr -= CARTRIDGE_RAM_FIRST;
    this.ram.push8(memAddr, v & 0xF);
    return ;
  }

  /* Private */
  void _setAccessRAM(int memAddr) {
    _enableRAM = (memAddr & 0x0100 == 0);
  }

  void _setBankNoROM(int v) {
    _bankno_ROM = v & 0x0F;
  }

  int _getOffsetROM(int memAddr) {
    return ((_bankno_ROM * CROM_BANK_SIZE) + (memAddr % CROM_BANK_SIZE));
  }

}
