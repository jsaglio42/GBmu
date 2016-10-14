// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   hardware.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/15 15:14:36 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/hardware/data.dart" as Data;

import "package:emulator/src/mixins/instructions.dart" as Instructions;

abstract class Hardware {

  Cartridge.ACartridge _c;
  Cartridge.ACartridge get c => _c;

  /* Memory */
  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  final internalRam = new Data.GbRam(INTERNAL_RAM_FIRST, INTERNAL_RAM_SIZE);
  final videoRam = new Data.GbRam(VIDEO_RAM_FIRST, VIDEO_RAM_SIZE);
  // final tailRam = new Data.GbRam(TAIL_RAM_FIRST, TAIL_RAM_SIZE);

  /* Lcd screen, is polled by FrameScheduler */
  Uint8List lcdScreen = new Uint8List(LCD_DATA_SIZE);

  /* Shared ressources */
  int clockTotal = 0;
  int joypadState = 0x0;

  bool ime = true;
  bool halt = false;
  bool stop = false;

  /* Useful for debug */
  int lastInstPC = 0x00;
  /* Can be used to force breakpoint anywhere in code */
  bool _hardbreak = false;
  bool get hardbreak => _hardbreak;
  void clearHB() { this._hardbreak = false; }
  void requestHB(bool c) {
    if (c == true) {
      print('HARDBREAK [$clockTotal]');
      this._hardbreak = true;
    }
  }

  /* Init */
  void initHardware(Cartridge.ACartridge c) {
    assert(_c == null, "Hardware: Cartridge already initialised");
    _c = c;
    /* Clear Screen */
    for (int i = 0; i < LCD_DATA_SIZE; ++i) {
      this.lcdScreen[i] = 0xFF;
    }
    return ;
  }

}
