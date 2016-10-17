// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   hardware.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/17 21:58:00 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/hardware/mem_registers.dart" as Memregs;
import "package:emulator/src/hardware/oam.dart" as Oam;
import "package:emulator/src/hardware/data.dart" as Data;

abstract class Hardware {

  Cartridge.ACartridge _c;
  Cartridge.ACartridge get c => _c;

  List<int> lcdScreen = new List<int>(LCD_SIZE);

  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  final Memregs.MemRegs memr = new Memregs.MemRegs();

  final Oam.OAM oam = new Oam.OAM();

  final internalRam = new Data.GbRam(INTERNAL_RAM_FIRST, INTERNAL_RAM_SIZE);
  final videoRam = new Data.GbRam(VIDEO_RAM_FIRST, VIDEO_RAM_SIZE);

  /* Debuging tools */
  int lastInstPC = 0x00;
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
    lcdScreen.fillRange(0, lcdScreen.length, 0x00);
    this.cpur.reset();
    this.memr.reset();
    return ;
  }

}
