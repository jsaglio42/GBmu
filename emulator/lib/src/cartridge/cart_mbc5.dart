// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_mbc5.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 12:06:36 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";

import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartMBC5 extends Cartridge.ACartridge  {

  int _bankno_ROM = 1;
  int _bankno_RAM = 0;
  bool _enableRAM = false;

  CartMBC5.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    assert(memAddr & ~0x7FFF == 0, 'pull8_Rom: invalid memAddr $memAddr');
    if (memAddr <= 0x3FFF)
      return this.rom.pull8(memAddr);
    else if (memAddr <= 0x7FFF)
    {
      final int bankOffset = 0x4000 * (_bankno_ROM - 1);
      return this.rom.pull8(bankOffset + memAddr);
    }
    else
      throw new Exception('CartMBC5: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override void push8_Rom(int memAddr, int v) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    assert(memAddr & ~0x7FFF == 0, 'push8_Rom: invalid memAddr $memAddr');
    if (memAddr <= 0x1FFF)
      _setAccessRAM(v);
    else if (memAddr <= 0x2FFF)
      _setBankNoROM_low(v);
    else if (memAddr <= 0x3FFF)
      _setBankNoROM_high(v);
    else if (memAddr <= 0x5FFF)
      _setBankNoRAM(v);
    // else
    //   throw new Exception('CartMBC5: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override int pull8_Ram(int memAddr) {
    if (!_enableRAM)
      throw new Exception('pull8_Ram: RAM not enabled');
    memAddr -= CARTRIDGE_RAM_FIRST;
    final int bankOffset = 0x2000 * _bankno_RAM;
    return this.ram.pull8(bankOffset + memAddr);
  }

  @override void push8_Ram(int memAddr, int v) {
    if (!_enableRAM)
      // throw new Exception('push8_Ram: RAM not enabled');
      return ;
    memAddr -= CARTRIDGE_RAM_FIRST;
    final int bankOffset = 0x2000 * _bankno_RAM;
    this.ram.push8(bankOffset + memAddr, v);
    return ;
  }

  /* Private */
  void _setAccessRAM(int v) {
    _enableRAM = (v & 0xFF == 0xA);
  }

  void _setBankNoROM_low(int v) {
      _bankno_ROM = _bankno_ROM & 0x100 | v;
  }

  void _setBankNoROM_high(int v) {
    if (v == 0)
      _bankno_ROM &= 0xFF;
    else
      _bankno_ROM |= 0x100;
  }

  void _setBankNoRAM(int v) {
    assert (v & ~0xF == 0, '_setBankNoRAM: bankno $v is not valid');
    _bankno_RAM = v;
  }

}
