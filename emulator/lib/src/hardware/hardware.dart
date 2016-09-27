// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   hardware.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/09/26 20:47:02 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/constants.dart";

import "package:emulator/src/cartridge/cartridge.dart" as Cartridge;
import "package:emulator/src/hardware/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/hardware/data.dart" as Data;

abstract class Hardware {

  Cartridge.ACartridge _c;
  Cartridge.ACartridge get c => _c;

  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  final internalRam = new Data.Ram(INTERNAL_RAM_FIRST, INTERNAL_RAM_SIZE);
  final videoRam = new Data.Ram(VIDEO_RAM_FIRST, VIDEO_RAM_SIZE);
  final tailRam = new Data.Ram(TAIL_RAM_FIRST, TAIL_RAM_SIZE);

  bool ime = true;
  bool halt = false;
  bool stop = false;
  int joypadState = 0x0;

  void initHardware(Cartridge.ACartridge c) {
    assert(_c == null, "Hardware: Cartridge already initialised");
    _c = c;
    this.tailRam.push8_unsafe(0xFF05, 0x00);
    this.tailRam.push8_unsafe(0xFF06, 0x00);
    this.tailRam.push8_unsafe(0xFF07, 0x00);
    this.tailRam.push8_unsafe(0xFF10, 0x80);
    this.tailRam.push8_unsafe(0xFF11, 0xBF);
    this.tailRam.push8_unsafe(0xFF12, 0xF3);
    this.tailRam.push8_unsafe(0xFF14, 0xBF);
    this.tailRam.push8_unsafe(0xFF16, 0x3F);
    this.tailRam.push8_unsafe(0xFF17, 0x00);
    this.tailRam.push8_unsafe(0xFF19, 0xBF);
    this.tailRam.push8_unsafe(0xFF1A, 0x7F);
    this.tailRam.push8_unsafe(0xFF1B, 0xFF);
    this.tailRam.push8_unsafe(0xFF1C, 0x9F);
    this.tailRam.push8_unsafe(0xFF1E, 0xBF);
    this.tailRam.push8_unsafe(0xFF20, 0xFF);
    this.tailRam.push8_unsafe(0xFF21, 0x00);
    this.tailRam.push8_unsafe(0xFF22, 0x00);
    this.tailRam.push8_unsafe(0xFF23, 0xBF);
    this.tailRam.push8_unsafe(0xFF24, 0x77);
    this.tailRam.push8_unsafe(0xFF25, 0xF3);
    this.tailRam.push8_unsafe(0xFF26, 0xF1);
    this.tailRam.push8_unsafe(0xFF40, 0x91);
    this.tailRam.push8_unsafe(0xFF42, 0x00);
    this.tailRam.push8_unsafe(0xFF43, 0x00);
    this.tailRam.push8_unsafe(0xFF45, 0x00);
    this.tailRam.push8_unsafe(0xFF47, 0xFC);
    this.tailRam.push8_unsafe(0xFF48, 0xFF);
    this.tailRam.push8_unsafe(0xFF49, 0xFF);
    this.tailRam.push8_unsafe(0xFF4A, 0x00);
    this.tailRam.push8_unsafe(0xFF4B, 0x00);
    this.tailRam.push8_unsafe(0xFFFF, 0x00);
    return ;
  }

}
