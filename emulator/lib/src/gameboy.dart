// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 17:47:22 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/hardware.dart" as Hardware;

import "package:emulator/src/mixins/graphics.dart" as Graphics;
import "package:emulator/src/mixins/instructionsdecoder.dart" as Instdecoder;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/joypad.dart" as Joypad;
import "package:emulator/src/mixins/mmu.dart" as Mmu;
import "package:emulator/src/mixins/timers.dart" as Timers;
import "package:emulator/src/mixins/z80.dart" as Z80;

/* Gameboy ********************************************************************/

class GameBoy extends Object
  with Hardware.Hardware
  , Graphics.Graphics
  , Instdecoder.InstructionsDecoder
  , Interrupt.InterruptManager
  , Joypad.Joypad
  , Mmu.Mmu
  , Timers.Timers
  , Z80.Z80 {

  /* Constructor */
  GameBoy(Cartridge.ACartridge c) {
    this.initHardware(c);
    return ;
  }

  /* API */
  int exec(int nbClock) {
    int instructionDuration;
    int executedClocks = 0;
    while(executedClocks < nbClock)
    {
      this.lastInstPC = this.cpur.PC;

      // if (this.clockTotal > 9501428) // Clock of VBLANK no 123
      //   print(Ft.toAddressString(this.lastInstPC & 0xFF00, 4));

      // if (this.clockTotal > 9571652) // Clock of VBLANK no 124
      //   print(Ft.toAddressString(this.lastInstPC, 4));

      instructionDuration = this.executeInstruction();
      this.updateTimers(instructionDuration);
      this.updateGraphics(instructionDuration);
      executedClocks += instructionDuration;
      this.handleInterrupts();

      // requestHB(this.cpur.PC == 0x0040); // VBREAK START
      // requestHB(this.cpur.PC == 0x028A); // VBREAK END

      // requestHB(this.cpur.PC == 0x036C); // Something happens here <- CHECK IF 0xFF85 is zero

      // requestHB(this.cpur.PC == 0x040D);
      // requestHB(this.pull8(0xFFE1) == 0x25);
      // requestHB(this.cpur.HL == 0xFFFE); // debug
      // requestHB(this.cpur.PC == 0x287C); // debug

      if (this.hardbreak)
        break ;
    }
    return (executedClocks);
  }

}
