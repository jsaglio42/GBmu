// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:03:41 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/hardware.dart" as Hardware;

import "package:emulator/src/mixins/instructionsdecoder.dart" as Instdecoder;
import "package:emulator/src/mixins/z80.dart" as Z80;
import "package:emulator/src/mixins/interrupts.dart" as Interrupts;
import "package:emulator/src/mixins/joypad.dart" as Joypad;
import "package:emulator/src/mixins/timers.dart" as Timers;
import "package:emulator/src/mixins/mmu.dart" as Mmu;
import "package:emulator/src/mixins/videorammanager.dart" as Videoram;
import "package:emulator/src/mixins/tailrammanager.dart" as Tailram;
import "package:emulator/src/mixins/graphicstatemachine.dart" as GStateMachine;
import "package:emulator/src/mixins/graphicdisplay.dart" as GDisplay;

/* Gameboy ********************************************************************/

class GameBoy extends Object
  with Hardware.Hardware
  , Instdecoder.InstructionsDecoder
  , Z80.Z80 
  , Interrupts.Interrupts
  , Joypad.Joypad
  , Timers.Timers
  , Mmu.Mmu
  , Videoram.VideoRamManager
  , Tailram.TailRamManager
  , GStateMachine.GraphicStateMachine
  , GDisplay.GraphicDisplay
{

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
      instructionDuration = this.executeInstruction();
      this.updateTimers(instructionDuration);
      _updateGraphics(instructionDuration);
      executedClocks += instructionDuration;
      this.handleInterrupts();

      if (this.hardbreak)
        break ;
    }
    return (executedClocks);
  }

  int _updateGraphics(int instructionDuration) {
    if (this.memr.rLCDC.isLCDEnabled)
    {
      this.lcd.resetDrawingInfo();
      this.updateGraphicMode(instructionDuration);
      this.updateDisplay();
    }
  }

}
