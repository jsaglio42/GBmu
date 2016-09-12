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

import "package:emulator/src/z80/z80.dart" as Z80;
import "package:emulator/src/z80/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

class GameBoy {

  // final Cartridge.ACartridge cartridge; //<- Used ? can be accessed via mmu
  final Z80.Z80 z80;
  final Mmu.Mmu mmu;
  
  // final LCDScreen lcd;
  // final Headset sound;
  
  GameBoy._fromMMU(Mmu.Mmu mmu) :
    this.mmu = mmu,
    this.z80 = new Z80.Z80(mmu)
  {
    z80.reset();
    mmu.reset();
  }

  GameBoy(Cartridge.ACartridge c) :  
    this._fromMMU(new Mmu.Mmu(c));

  /* API */

  int get clockCount => this.z80.clockCount;
  Cpuregs.CpuRegs get cpur => this.z80.cpur;

  // Cartridge.Cartridge get cartridge => this.mmu.c;

  void exec(int nbClock) {
    this.z80.exec(nbClock);
    return ;
  }

}
