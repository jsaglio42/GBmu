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

import 'package:ft/src/misc.dart' as Ft;

import 'package:emulator/enums.dart';
import "package:emulator/src/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

// OLD ** Only for debug

// import 'dart:math' as Math;
// var rng = new Math.Random();
// Map _generateRandomMapFromIterable(Iterable l, int value_range)
// {
//   final size = Math.max(1, rng.nextInt(l.length));
//   final m = {};
//   var v;
//   for (int i = 0; i < size; i++) {
//     v = l.elementAt(rng.nextInt(l.length));
//     m[v] = rng.nextInt(value_range);
//   }
//   return m;
// }

class GameBoy {

  final Mmu.Mmu mmu;
  final Cartridge.ACartridge cartridge;
  final Cpuregs.CpuRegs cpuRegs = new Cpuregs.CpuRegs();

  // final LCDScreen lcd;
  // final Headset sound;

  int         _clockCount = 0;
  int         _clockWait = 0;

  GameBoy(Cartridge.ACartridge c) //TODO: pass LCDScreen and eadset <- DONT AGREE
    : this.cartridge = c
    , this.mmu = new Mmu.Mmu(c)
  {
    cpuRegs.init();
    mmu.init();
  }

  int get clockCount => _clockCount;

  void exec(int nbClock) {
    // print('exec($numInst)');
    int inst;
    
    _clockCount += nbClock;
    while (nbClock-- > 0)
    {
      if (_clockWait-- > 0)
        continue ;
      inst = mmu.pullMem8(cpuRegs.value16(Reg16.PC));
      switch(inst)
      {
        default :
          throw new Exception('CPU: Opcode ${Ft.toHexaString(inst, 2)} not supported');
      }
    }

    // OLD ** Only for debug
    // _generateRandomMapFromIterable(Reg16.values, 256 * 256).forEach((r, v) {
    //   this.cpuRegs.update16(r, v);
    // });
    // _generateRandomMapFromIterable(MemReg.values, 256).forEach((r, v) {
    //   this.mmu.pushMemReg(r, v);
    // });
    return ;
  }

}
