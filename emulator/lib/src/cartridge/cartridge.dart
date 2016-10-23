// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartridge.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:30:40 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 12:07:28 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cart_romonly.dart" as C_RO;
import "package:emulator/src/cartridge/cart_mbc1.dart" as C_MBC1;
import "package:emulator/src/cartridge/cart_mbc2.dart" as C_MBC2;
import "package:emulator/src/cartridge/cart_mbc5.dart" as C_MBC5;


/* Cartridge Implementation ****************************************************
**
** Abstract that only offers a factory method:
**  - Checks are done on the rom/ram size
**  - Checks that the logo is valid (bios sequence)
**  - Instantiate the correct Cartridge type
**  - TODO: Control the checksums
*/

abstract class ACartridge implements Ser.RecursivelySerializable {

  final Data.Rom rom;
  final Data.Ram ram;

  ACartridge.internal(this.rom, this.ram);

  factory ACartridge(Data.Rom rom, {Data.Ram optionalRam : null})
  {
    final expectedRomSize = rom.pullHeaderValue(RomHeaderField.ROM_Size);
    final expectedRamSize = rom.pullHeaderValue(RomHeaderField.RAM_Size);
    final isLogoValid = rom.pullHeaderValue(RomHeaderField.Nintendo_Logo);
    final Data.Ram ram = (optionalRam == null)
      ? new Data.Ram.empty(rom)
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
      case (CartridgeType.MBC1_RAM) :
      case (CartridgeType.MBC1_RAM_BATTERY) :
        return new C_MBC1.CartMBC1.internal(rom, ram);

      case (CartridgeType.MBC2) :
      case (CartridgeType.MBC2_BATTERY) :
        return new C_MBC2.CartMBC2.internal(rom, ram);

      case (CartridgeType.MBC5) :
      case (CartridgeType.MBC5_RAM) :
      case (CartridgeType.MBC5_RAM_BATTERY) :
      case (CartridgeType.MBC5_RUMBLE) :
      case (CartridgeType.MBC5_RUMBLE_RAM) :
      case (CartridgeType.MBC5_RUMBLE_RAM_BATTERY) :
        return new C_MBC5.CartMBC5.internal(rom, ram);

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
