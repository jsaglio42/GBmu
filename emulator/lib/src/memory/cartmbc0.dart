// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartmbc0.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 16:23:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/memory/ram.dart" as Ram;
import "package:emulator/src/memory/rom.dart" as Rom;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;
import "package:emulator/src/memory/imbc.dart" as Imbc;

class CartMbc0 extends Cartridge.Cartridge  {

  CartMbc0(Rom.Rom rom, Ram.Ram ram)
    : super(rom, ram);

  @override int pullMem8(int memAddr)
  { return 0x42;}
  @override void pushMem8(int memAddr, int byte)
  {}
  @override int pullMem16(int memAddr)
  { return 0x42;}
  @override void pushMem16(int memAddr, int word)
  {}
}
