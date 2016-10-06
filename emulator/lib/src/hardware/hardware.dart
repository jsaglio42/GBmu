// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   hardware.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/05 14:18:03 by jsaglio          ###   ########.fr       //
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
  final internalRam = new Data.Ram(INTERNAL_RAM_FIRST, INTERNAL_RAM_SIZE);
  final videoRam = new Data.Ram(VIDEO_RAM_FIRST, VIDEO_RAM_SIZE);
  final tailRam = new Data.Ram(TAIL_RAM_FIRST, TAIL_RAM_SIZE);

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
    /* Init Memory */
    this.tailRam.push8_unsafe(0xFF05, 0x00); // TIMA
    this.tailRam.push8_unsafe(0xFF06, 0x00); // TMA
    this.tailRam.push8_unsafe(0xFF07, 0x00); // TAC
    this.tailRam.push8_unsafe(0xFF10, 0x80); //
    this.tailRam.push8_unsafe(0xFF11, 0xBF); //
    this.tailRam.push8_unsafe(0xFF12, 0xF3); //
    this.tailRam.push8_unsafe(0xFF14, 0xBF); //
    this.tailRam.push8_unsafe(0xFF16, 0x3F); //
    this.tailRam.push8_unsafe(0xFF17, 0x00); //
    this.tailRam.push8_unsafe(0xFF19, 0xBF); //
    this.tailRam.push8_unsafe(0xFF1A, 0x7F); //
    this.tailRam.push8_unsafe(0xFF1B, 0xFF); //
    this.tailRam.push8_unsafe(0xFF1C, 0x9F); //
    this.tailRam.push8_unsafe(0xFF1E, 0xBF); //
    this.tailRam.push8_unsafe(0xFF20, 0xFF); //
    this.tailRam.push8_unsafe(0xFF21, 0x00); //
    this.tailRam.push8_unsafe(0xFF22, 0x00); //
    this.tailRam.push8_unsafe(0xFF23, 0xBF); //
    this.tailRam.push8_unsafe(0xFF24, 0x77); //
    this.tailRam.push8_unsafe(0xFF25, 0xF3); //
    this.tailRam.push8_unsafe(0xFF26, 0xF1); //
    this.tailRam.push8_unsafe(0xFF40, 0x91); // LCDC
    this.tailRam.push8_unsafe(0xFF42, 0x00); // SCY
    this.tailRam.push8_unsafe(0xFF43, 0x00); // SCX
    this.tailRam.push8_unsafe(0xFF45, 0x00); // LYC
    this.tailRam.push8_unsafe(0xFF47, 0xFC); // BGP
    this.tailRam.push8_unsafe(0xFF48, 0xFF); // OBP0
    this.tailRam.push8_unsafe(0xFF49, 0xFF); // OBP1
    this.tailRam.push8_unsafe(0xFF4A, 0x00); // WY
    this.tailRam.push8_unsafe(0xFF4B, 0x00); // WX
    this.tailRam.push8_unsafe(0xFFFF, 0x00); // IE
    return ;
  }

}
