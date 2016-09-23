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

  final Cartridge.ACartridge c;
  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  final internalRam = new Data.internalRam(INTERNAL_RAM_FIRST, new Uint8List(INTERNAL_RAM_SIZE));
  final videoRam = new Data.VideoRam(VIDEO_RAM_FIRST, VIDEO_RAM_SIZE);
  final tailRam = new Data.TailRam(TAIL_RAM_FIRST, TAIL_RAM_SIZE);

  bool ime = true;
  bool halt = false;
  bool stop = false;

}

/* Gameboy ********************************************************************/

class GameBoy extends Object
  with Hardware
  , Instdecoder.InstructionsDecoder
  , Z80.Z80
  , Timers.Timers
  , Interrupt.InterruptManager {

  /* Constructor */
  GameBoy(Cartridge.ACartridge c) : this.c = c;

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
