// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 13:35:33 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import "package:emulator/src/GameBoyDMG/gameboydmg.dart" as GBDMG;
import "package:emulator/src/GameBoyColor/gameboycolor.dart" as GBC;

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;

import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/instructionsdecoder.dart" as Instdecoder;
import "package:emulator/src/mixins/z80.dart" as Z80;
import "package:emulator/src/mixins/interrupts.dart" as Interrupts;
import "package:emulator/src/mixins/joypad.dart" as Joypad;
import "package:emulator/src/mixins/timers.dart" as Timers;
import "package:emulator/src/mixins/mmu.dart" as Mmu;
import "package:emulator/src/mixins/graphicstatemachine.dart" as GStateMachine;
import "package:emulator/src/mixins/shared.dart" as Shared;


enum GameBoyType {
  DMG,
  Color,
  Auto
}

abstract class GameBoy extends Object
  with Ser.RecursivelySerializable
  , Hardware.Hardware
  , Instdecoder.InstructionsDecoder
  , Z80.Z80
  , Interrupts.Interrupts
  , Joypad.Joypad
  , Timers.Timers
  , Mmu.Mmu
  , GStateMachine.GraphicStateMachine
  , Shared.Interrupts
  , Shared.VideoRam
  , Shared.InternalRam
  , Shared.TailRam {

  GameBoy.internal(Cartridge.ACartridge c) {
    this.initHardware(c);
  }

  factory GameBoy(Cartridge.ACartridge c, GameBoyType type)
  {
    switch (type)
    {
      case (GameBoyType.DMG) : return new GBDMG.GameBoyDMG(c);
      case (GameBoyType.Color) : return new GBC.GameBoyColor(c);
      default : return null;
    }
  }

  int exec(int nbClock);

}
