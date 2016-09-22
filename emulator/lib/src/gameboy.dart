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
import "package:emulator/src/z80/cpu_registers.dart" as Cpuregs;

import "package:emulator/src/z80/instructionsdecoder.dart" as Instdecoder;
import "package:emulator/src/z80/z80.dart" as Z80;
import "package:emulator/src/z80/timers.dart" as Timers;
import "package:emulator/src/z80/interruptmanager.dart" as Interrupt;

/* Shared Interface ***********************************************************/

abstract class Hardware {

  Mmu.Mmu _mmu;
  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();

  /* API */

  Mmu.Mmu get mmu => _mmu;

  bool ime = true;
  bool halt = false;
  bool stop = false;

  void initMemory(Cartridge.ACartridge c) {
    assert(_mmu == null, 'Hardware: initMMU: MMU already initialised');
    _mmu = new Mmu.Mmu(c);
  }

  void pushOnStack16(int val) {
    assert(val & 0xFFFF == 0);
    this.mmu.push16(this.cpur.SP - 2, val);
    this.cpur.SP -= 2;
    return ;
  }

}

/* Gameboy ********************************************************************/

class GameBoy extends Object
  with Hardware
  , Instdecoder.InstructionsDecoder
  , Z80.Z80
  , Timers.Timers
  , Interrupt.InterruptManager {

  /* Constructor */
  GameBoy(Cartridge.ACartridge c) {
    this.initMemory(c);
  }

  /* API */
  int exec(int nbClock) {
    int instructionDuration;
    int executedClocks = 0;
    while(executedClocks < nbClock)
    {
      instructionDuration = this.executeInstruction();
      this.updateTimers(instructionDuration);
      executedClocks += instructionDuration;
      this.handleInterrupts();
    }
    return (executedClocks);
  }

}
