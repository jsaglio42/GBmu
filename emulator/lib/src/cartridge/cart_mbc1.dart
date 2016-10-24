// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_mbc1.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 12:11:40 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartMBC1 extends Cartridge.ACartridge
  with Ser.RecursivelySerializable
{

  int _mode = 0;
  int _bankno_ROM = 1;
  int _bankno_RAM = 0;
  bool _enableRAM = false;

  CartMBC1.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    assert(memAddr & ~0x7FFF == 0, 'pull8_Rom: invalid memAddr $memAddr');
    if (memAddr <= 0x3FFF)
      return this.rom.pull8(memAddr);
    else if (memAddr <= 0x7FFF)
      return this.rom.pull8(_getOffsetROM(memAddr));
    else
      throw new Exception('CartMBC1: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override void push8_Rom(int memAddr, int v) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    assert(memAddr & ~0x7FFF == 0, 'push8_Rom: invalid memAddr $memAddr');
    if (memAddr <= 0x1FFF)
      _setAccessRAM(v);
    else if (memAddr <= 0x3FFF)
      _setBankNoROM(v);
    else if (memAddr <= 0x5FFF)
      _setBankNoRAM(v);
    else if (memAddr <= 0x7FFF)
      _setMode(v);
    else
      throw new Exception('CartMBC1: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  @override int pull8_Ram(int memAddr) {
    if (!_enableRAM)
      throw new Exception('pull8_Ram: RAM not enabled');
    memAddr -= CARTRIDGE_RAM_FIRST;
    return this.ram.pull8(_getOffsetRAM(memAddr));
  }

  @override void push8_Ram(int memAddr, int v) {
    if (!_enableRAM)
      // throw new Exception('push8_Ram: RAM not enabled');
      return ;
    memAddr -= CARTRIDGE_RAM_FIRST;
    this.ram.push8(_getOffsetRAM(memAddr), v);
    return ;
  }

  /* Private ******************************************************************/
  void _setAccessRAM(int v) {
    _enableRAM = (v & 0xFF == 0xA);
  }

  void _setMode(int v) {
    assert (v & ~0x1 == 0, '_setMode: mode $v is not valid');
    _mode = v;
  }

  void _setBankNoROM(int v) {
    assert (v & ~0x1F == 0, '_setBankNoRAM: bankno $v is not valid');
    _bankno_ROM = v;
  }

  void _setBankNoRAM(int v) {
    assert (v & ~0x3 == 0, '_setBankNoRAM: bankno $v is not valid');
    _bankno_RAM = v;
  }

  int _getOffsetROM(int memAddr) {
    final int bankno = _bankno_ROM | (1 - _mode) * (_bankno_RAM << 5);
    if (bankno == 0x00 || bankno == 0x20 || bankno == 0x40 || bankno == 0x60)
      return (((bankno + 1) * CROM_BANK_SIZE) + (memAddr % CROM_BANK_SIZE));
    else
      return ((bankno * CROM_BANK_SIZE) + (memAddr % CROM_BANK_SIZE));
  }

  int _getOffsetRAM(int memAddr) {
    final int bankno = _bankno_RAM * _mode;
    return ((bankno * CRAM_BANK_SIZE) + (memAddr % CRAM_BANK_SIZE));
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[
      this.ram,
    ];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_mode', () => _mode, (v) => _mode = v),
      new Ser.Field('_bankno_ROM', () => _bankno_ROM, (v) => _bankno_ROM = v),
      new Ser.Field('_bankno_RAM', () => _bankno_RAM, (v) => _bankno_RAM = v),
      new Ser.Field('_enableRAM', () => _enableRAM, (v) => _enableRAM = v),
    ];
  }

}
