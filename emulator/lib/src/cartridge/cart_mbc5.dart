// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_mbc5.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 17:20:32 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartMBC5 extends Cartridge.ACartridge
  with Ser.RecursivelySerializable
{

  int _bankno_ROM = 1;
  int _bankno_RAM = 0;
  bool _enableRAM = false;

  CartMBC5.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int addr) {
    assert(addr & ~0x7FFF == 0, 'pull8_Rom: invalid addr $addr');
    if (addr <= 0x3FFF)
      return this.rom.pull8(addr);
    else
      return this.rom.pull8(_getOffsetROM(addr & 0x3FFF));
  }

  @override void push8_Rom(int addr, int v) {
    assert(addr & ~0x7FFF == 0, 'push8_Rom: invalid addr $addr');
    if (addr <= 0x1FFF)
      _setAccessRAM(v);
    else if (addr <= 0x2FFF)
      _setBankNoROM_low(v);
    else if (addr <= 0x3FFF)
      _setBankNoROM_high(v);
    else if (addr <= 0x5FFF)
      _setBankNoRAM(v);
    // else
    //   throw new Exception('CartMBC5: cannot access address ${Ft.toAddressString(addr, 4)}');
  }

  @override int pull8_Ram(int addr) {
    assert(addr & ~0x1FFF == 0, '_getOffsetRAM: invalid addr $addr');
    if (!_enableRAM)
      throw new Exception('pull8_Ram: RAM not enabled');
    return this.ram.pull8(_getOffsetRAM(addr));
  }

  @override void push8_Ram(int addr, int v) {
    assert(addr & ~0x1FFF == 0, '_getOffsetRAM: invalid addr $addr');
    if (!_enableRAM)
      // throw new Exception('push8_Ram: RAM not enabled');
      return ;
    this.ram.push8(_getOffsetRAM(addr), v);
    return ;
  }

  /* Private */
  void _setAccessRAM(int v) {
    _enableRAM = (v & 0xFF == 0xA);
  }

  void _setBankNoROM_low(int v) {
    assert (v & ~0xFF == 0, '_setBankNoROM_low: $v is not valid');
    _bankno_ROM = (_bankno_ROM & 0x100) | v;
  }

  void _setBankNoROM_high(int v) {
    assert (v & ~0x1 == 0, '_setBankNoROM_high: $v is not valid');
    if (v == 0)
      _bankno_ROM &= 0xFF;
    else
      _bankno_ROM |= 0x100;
  }

  void _setBankNoRAM(int v) {
    assert (v & ~0xF == 0, '_setBankNoRAM: bankno $v is not valid');
    _bankno_RAM = v;
  }

  int _getOffsetROM(int addr) {
    return (_bankno_ROM * CROM_BANK_SIZE + addr);
  }

  int _getOffsetRAM(int addr) {
    return (_bankno_RAM * CRAM_BANK_SIZE + addr);
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
      return <Ser.RecursivelySerializable>[
        this.ram,
      ];
  }

  Iterable<Ser.Field> get serFields {
      return <Ser.Field>[
        new Ser.Field('_bankno_ROM', () => _bankno_ROM, (v) => _bankno_ROM = v),
        new Ser.Field('_bankno_RAM', () => _bankno_RAM, (v) => _bankno_RAM = v),
        new Ser.Field('_enableRAM', () => _enableRAM, (v) => _enableRAM = v),
      ];
  }

}
