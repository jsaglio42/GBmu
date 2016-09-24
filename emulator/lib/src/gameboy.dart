// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 12:39:23 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/hardware/internalram.dart" as Internalram;
import "package:emulator/src/hardware/tailram.dart" as Tailram;
import "package:emulator/src/hardware/videoram.dart" as Videoram;

import "package:emulator/src/mixins/mem_mmu.dart" as Mmu;
import "package:emulator/src/mixins/mem_registermapping.dart" as Memregisters;
import "package:emulator/src/mixins/instructionsdecoder.dart" as Instdecoder;
import "package:emulator/src/mixins/z80.dart" as Z80;
import "package:emulator/src/mixins/timers.dart" as Timers;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;

/* Shared Interface ***********************************************************/

abstract class Hardware {

  Cartridge.ACartridge _c;
  Cartridge.ACartridge get c => _c;

  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  final internalRam = new Internalram.InternalRam(
    INTERNAL_RAM_FIRST
    , new Uint8List(INTERNAL_RAM_SIZE));
  final tailRam = new Tailram.TailRam(
    TAIL_RAM_FIRST
    , new Uint8List(TAIL_RAM_SIZE));
  final videoRam = new Videoram.VideoRam(
    VIDEO_RAM_FIRST
    , new Uint8List(VIDEO_RAM_SIZE));

  bool ime = true;
  bool halt = false;
  bool stop = false;

  void initCartridge(Cartridge.ACartridge c) {
    assert(_c == null, "Hardware: Cartridge already initialised");
    _c = c;
    return ;
  }

}

/* Gameboy ********************************************************************/

class GameBoy extends Object
  with Hardware
  , Instdecoder.InstructionsDecoder
  , Interrupt.InterruptManager
  , Memregisters.MemRegisterMapping
  , Mmu.Mmu
  , Timers.Timers
  , Z80.Z80 
  {
  //, Joypad.Joypad

  /* Constructor */
  GameBoy(Cartridge.ACartridge c) {
    this.initCartridge(c);
    return ;
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
