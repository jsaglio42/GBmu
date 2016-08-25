// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:43:20 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

class GameBoy {

  final Cpuregs.CpuRegs cpuRegs = new Cpuregs.CpuRegs();
  final Mmu.Mmu mmu;
  final Cartridge.Cartridge cartridge;
  // final LCDScreen lcd;
  // final Headset sound;

  int         _instrCount = 0;

  GameBoy(Cartridge.Cartridge c) //TODO: pass LCDScreen and eadset
    : this.cartridge = c
    , this.mmu = new Mmu.Mmu(c);

  int get instrCount => _instrCount;

  void exec(int numIntr) {
    _instrCount += numIntr;
    return ;
  }

}
