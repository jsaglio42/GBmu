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
import "package:emulator/src/memory/ram.dart" as Ram;
import "package:emulator/src/memory/rom.dart" as Rom;
import "package:emulator/src/memory/rom_headerdecoder.dart" as Romhd;
import "package:emulator/src/memory/imbc.dart" as Imbc;
import "package:emulator/src/memory/cartromonly.dart" as Cartromonly;

abstract class Cartridge implements Imbc.IMbc {

  final Rom.Rom rom;
  final Ram.Ram ram;

// Not working ... should be working : http://stackoverflow.com/questions/13272035/how-do-i-call-a-super-constructor-in-dart
// Cartridge._private(this.rom, this.ram);

  Cartridge.internal(this.rom, this.ram);

  factory Cartridge(Rom.Rom rom, {Ram.Ram optionalRam : null})
  {
  	print('Cartridge Constructor');
  	final expectedRomSize = rom.pullHeaderValue(Romhd.RomHeaderField.ROM_Size);
  	final expectedRamSize = rom.pullHeaderValue(Romhd.RomHeaderField.RAM_Size);
  	final isLogoValid = rom.pullHeaderValue(Romhd.RomHeaderField.Nintendo_Logo);
    final Ram.Ram ram = (optionalRam == null) ?
    	new Ram.Ram(new Uint8List(expectedRamSize)):
      optionalRam;
  	if (expectedRomSize != rom.size)
      throw new Exception('Cartridge: ROM Size is not matching header info');
    else if (expectedRamSize != ram.size)
      throw new Exception('Cartridge: RAM Size is not matching header info');
  	else if (isLogoValid == false)
  		throw new Exception('Cartridge: Logo is not valid');
  	final ctype = rom.pullHeaderValue(Romhd.RomHeaderField.Cartridge_Type);
  	switch (ctype)
  	{
  		case (Romhd.CartridgeType.ROM_ONLY) :
  			return new Cartromonly.CartRomOnly.internal(rom, ram);
  		default : break ;
  	}
    throw new Exception('Cartridge: ' + ctype.toString() + ' not supported');
  }

}