// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   hardware.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/23 18:29:02 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/hardware/data.dart" as Data;
import "package:emulator/src/hardware/lcd.dart" as Lcd;
import "package:emulator/src/hardware/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/hardware/mem_registers.dart" as Memregs;

import "package:emulator/src/hardware/internalram.dart" as Iram;
import "package:emulator/src/hardware/videoram.dart" as Vram;
import "package:emulator/src/hardware/oam.dart" as Oam;
import "package:emulator/src/hardware/tailram.dart" as Tram;

abstract class Hardware implements Ser.RecursivelySerializable {

  Cartridge.ACartridge _c;
  Cartridge.ACartridge get c => _c;

  int clockTotal = 0;

  final Lcd.LCD lcd = new Lcd.LCD();

  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  final Memregs.MemRegs memr = new Memregs.MemRegs();

  final Vram.VideoRam videoram = new Vram.VideoRam();
  final Iram.InternalRam internalram = new Iram.InternalRam();
  final Oam.OAM oam = new Oam.OAM();
  final Tram.TailRam tailram = new Tram.TailRam();

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
    this.lcd.reset();
    this.cpur.reset();
    this.memr.reset();
    this.tailram.reset();
    this.videoram.reset();
    this.internalram.reset();
    return ;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[
      this.cpur,
      this.memr,
      // this.lcd,
    ];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('clockTotal', () => clockTotal, (v) => clockTotal = v),
      new Ser.Field('lastInstPC', () => lastInstPC, (v) => lastInstPC = v),
      new Ser.Field('_hardbreak', () => _hardbreak, (v) => _hardbreak = v),
    ];
  }

}
