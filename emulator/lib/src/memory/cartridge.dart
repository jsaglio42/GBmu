// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartridge.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:30:40 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:44:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:emulator/src/enums.dart";

import "package:emulator/src/memory/data.dart" as Data;
import "package:emulator/src/memory/cart_romonly.dart" as C_RO;
import "package:emulator/src/memory/cart_mbc1.dart" as C_MBC1;

/* Cartridge Implementation ****************************************************
**
** Abstract that only offers a factory method:
**  - Checks are done on the rom/ram size
**  - Checks that the logo is valid (bios sequence)
**  - Instantiate the correct Cartridge type
**  - TODO: Control the checksums
*/

abstract class ACartridge {

  final Data.Rom rom;
  final Data.Ram ram;

  ACartridge.internal(this.rom, this.ram);

  factory ACartridge(Data.Rom rom, {Data.Ram optionalRam : null})
  {
    final expectedRomSize = rom.pullHeaderValue(RomHeaderField.ROM_Size);
    final expectedRamSize = rom.pullHeaderValue(RomHeaderField.RAM_Size);
    final isLogoValid = rom.pullHeaderValue(RomHeaderField.Nintendo_Logo);
    final Data.Ram ram = (optionalRam == null) ?
      new Data.Ram(new Uint8List(expectedRamSize)):
      optionalRam;
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
    throw new Exception('Cartridge: ' + ctype.toString() + ' not supported');
  }

  int pullMem8(int memAddr);
  void pushMem8(int memAddr, int byte);
  int pullMem16(int memAddr);
  void pushMem16(int memAddr, int word);

}
