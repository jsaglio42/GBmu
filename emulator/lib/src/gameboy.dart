// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 13:06:31 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';

import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

import "package:emulator/src/z80/instructionsdecoder.dart" as Instdecoder;
import "package:emulator/src/z80/z80.dart" as Z80;
import "package:emulator/src/z80/timers.dart" as Timers;

abstract class GameBoyMemory {
  
  /* API */
  Mmu.Mmu get mmu => _mmu;

  void initMemory(Cartridge.ACartridge c) {
    assert(_mmu == null, 'GameBoyMemory: initMMU: MMU already initialised');
    _mmu = new Mmu.Mmu(c);
  }

  /* Private */
  Mmu.Mmu _mmu;

}

class GameBoy extends Object
  with GameBoyMemory, Instdecoder.InstructionsDecoder, Z80.Z80, Timers.Timers {

  GameBoy(Cartridge.ACartridge c) {
    this.initMemory(c);
  }

  int exec(int nbClock) {
    int instructionDuration;
    int executedClocks = 0;
    while(executedClocks < nbClock)
    {
      instructionDuration = this.executeInstruction();
      this.updateTimers(instructionDuration);
      executedClocks += instructionDuration;
    }
    return (executedClocks);
  }

}
