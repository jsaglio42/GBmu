// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_romonly.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 18:39:35 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

class CartRomOnly extends Cartridge.ACartridge
  with Ser.RecursivelySerializable
{

  CartRomOnly.internal(Data.Rom rom, Data.Ram ram)
    : super.internal(rom, ram);

  @override int pull8_Rom(int memAddr) {
    memAddr -= CARTRIDGE_ROM_FIRST;
    return this.rom.pull8(memAddr);
  }

  @override void push8_Rom(int memAddr, int v) {
    // throw new Exception('ROM_ONLY: RAM Operation not supported');
    return ;
  }

  @override int pull8_Ram(int memAddr) {
    throw new Exception('ROM_ONLY: RAM Operation not supported');
  }

  @override void push8_Ram(int memAddr, int v) {
    throw new Exception('ROM_ONLY: RAM Operation not supported');
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[];
  }

}
