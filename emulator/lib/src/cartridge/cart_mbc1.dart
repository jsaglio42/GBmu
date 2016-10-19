// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_mbc1.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:34:11 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";

import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartMBC1 extends Cartridge.ACartridge  {

  int _mode = 0;
  int _bankno_ROM = 1;
  int _bankno_RAM = 0;
  bool _enableRAM = false;

  CartMBC1.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    if (0x0000 <= memAddr && memAddr <= 0x3FFF)
      return this.rom.pull8(memAddr);
    else
    {
      final int bankno = _bankno_ROM | (1 - _mode) * (_bankno_RAM << 6);
      final int bankOffset = 0x4000 * (bankno - 1);
      return this.rom.pull8(bankOffset + memAddr);
    }
  }

  @override void push8_Rom(int memAddr, int v) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    if (0x0000 <= memAddr && memAddr <= 0x1FFF)
      _setAccessRAM(v);
    else if (0x2000 <= memAddr && memAddr <= 0x3FFF)
      _setBankNoROM(v);
    else if (0x4000 <= memAddr && memAddr <= 0x5FFF)
      _setBankNoRAM(v);
    else if (0x6000 <= memAddr && memAddr <= 0x7FFF)
      _setMode(v);
    else
      throw new Exception('MBC1: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override int pull8_Ram(int memAddr) {
    if (!_enableRAM)
      throw new Exception('pull8_Ram: RAM not enabled');
    memAddr -= CARTRIDGE_RAM_FIRST;
    final int bankOffset = 0x2000 * _bankno_RAM * _mode;
    return this.ram.pull8(bankOffset + memAddr);
  }

  @override void push8_Ram(int memAddr, int v) {
    if (!_enableRAM)
      return ;
    memAddr -= CARTRIDGE_RAM_FIRST;
    final int bankOffset = 0x2000 * _bankno_RAM * _mode;
    this.ram.push8(bankOffset + memAddr, v);
    return ;
  }

  /* Private */
  void _setAccessRAM(int v) {
    _enableRAM = (v & 0xF == 0xA);
  }

  void _setMode(int v) {
    _mode = v & 0x1;
  }

  void _setBankNoROM(int v) {
    v = v & 0x1F;
    if (v == 0x00 || v == 0x20 || v == 0x40 || v == 0x60)
      _bankno_ROM = v + 1;
    else
      _bankno_ROM = v;
  }

  void _setBankNoRAM(int v) {
    assert (v & ~0x3 == 0, '_setBankNoRAM: bankno $v is not valid');
    _bankno_RAM = v;
  }

}
