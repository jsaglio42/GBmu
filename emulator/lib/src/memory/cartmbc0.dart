// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/24 11:01:36 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/24 17:02:00 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "ram.dart";
import "rom.dart";
import "cartridge.dart";
import "imbc.dart";

class CartMbc0 extends Cartridge  {

  CartMbc0(Rom rom, Ram ram)
    : super(rom, ram);

  @override int pullMem(int memAddr)
  {
    if (true)
      this.rom.pull(memAddr + 0x42);
    return 0;
  }

  @override void pushMem(int memAddr, int v)
  {

   }
}
