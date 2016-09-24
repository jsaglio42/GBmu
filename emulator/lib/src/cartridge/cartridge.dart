// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartridge.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:30:40 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 12:40:28 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/headerdecoder.dart" as Headerdecoder;
import "package:emulator/src/cartridge/cart_romonly.dart" as C_RO;
import "package:emulator/src/cartridge/cart_mbc1.dart" as C_MBC1;

/* Cartridge ROM/RAM **********************************************************/

class CartridgeRom extends Data.AData
  with Data.AReadOperation
  , Headerdecoder.HeaderDecoder {

  CartridgeRom(Uint8List d) : super(0, d);

  @override int pull8(int addr) => this.pull8_unsafe(addr);
  @override void push8(int addr, int v) {
    throw new Exception("CartridgeRom: Write Operation not supported");
  }

}

class CartridgeRam extends Data.AData
  with Data.AReadOperation
  , Data.AWriteOperation {

  CartridgeRam(Uint8List d) : super(0, d);

  @override int pull8(int addr) => this.pull8_unsafe(addr);
  @override void push8(int addr, int v) => this.push8_unsafe(addr, v);

}

/* Cartridge Implementation ****************************************************
**
** Abstract that only offers a factory method:
**  - Checks are done on the rom/ram size
**  - Checks that the logo is valid (bios sequence)
**  - Instantiate the correct Cartridge type
**  - TODO: Control the checksums
*/

abstract class ACartridge {

  final CartridgeRom rom;
  final CartridgeRam ram;

  ACartridge.internal(this.rom, this.ram);

  factory ACartridge(CartridgeRom rom, {CartridgeRam optionalRam : null})
  {
    final expectedRomSize = rom.pullHeaderValue(RomHeaderField.ROM_Size);
    final expectedRamSize = rom.pullHeaderValue(RomHeaderField.RAM_Size);
    final isLogoValid = rom.pullHeaderValue(RomHeaderField.Nintendo_Logo);
    final CartridgeRam ram = (optionalRam == null)
      ? new CartridgeRam(new Uint8List(expectedRamSize))
      : optionalRam;
    if (expectedRomSize != rom.size)
      throw new Exception('Cartridge: ROM Size is not matching header info');
    else if (expectedRamSize != ram.size)
      throw new Exception('Cartridge: RAM Size is not matching header info');
    else if (isLogoValid == false)
      throw new Exception('Cartridge: Logo is not valid');

    final ctype = rom.pullHeaderValue(RomHeaderField.Cartridge_Type);
    switch (ctype)
    {
      case (CartridgeType.ROM_ONLY) :
        return new C_RO.CartRomOnly.internal(rom, ram);

      case (CartridgeType.MBC1) :
        return new C_MBC1.CartMBC1.internal(rom, ram);
      case (CartridgeType.MBC1_RAM) :
        return new C_MBC1.CartMBC1.internal(rom, ram);
      case (CartridgeType.MBC1_RAM_BATTERY) :
        return new C_MBC1.CartMBC1.internal(rom, ram);

      default : break ;
    }
    throw new Exception('Cartridge: $ctype not supported');
  }

  int pull8_Ram(int memAddr);
  int pull8_Rom(int memAddr);
  void push8_Ram(int memAddr, int v);
  void push8_Rom(int memAddr, int v);

  String toString() => '\{rom: $rom, ram: $ram\}';

}
