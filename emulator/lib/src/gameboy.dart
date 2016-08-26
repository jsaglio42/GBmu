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

import 'dart:math' as Math;

import 'package:emulator/enums.dart';
import "package:emulator/src/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;

var rng = new Math.Random();
Map _generateRandomMapFromIterable(Iterable l, int value_range)
{
  final size = Math.max(1, rng.nextInt(l.length));
  final m = {};
  var v;

  for (int i = 0; i < size; i++) {
    v = l.elementAt(rng.nextInt(l.length));
    m[v] = rng.nextInt(value_range);
  }
  return m;
}


class GameBoy {

  final Cpuregs.CpuRegs cpuRegs = new Cpuregs.CpuRegs();
  final Mmu.Mmu mmu;
  final Cartridge.Cartridge cartridge;
  // final LCDScreen lcd;
  // final Headset sound;

  int         _clockCount = 0;

  GameBoy(Cartridge.Cartridge c) //TODO: pass LCDScreen and eadset
    : this.cartridge = c
    , this.mmu = new Mmu.Mmu(c);

  int get clockCount => _clockCount;

  void exec(int numIntr) {
    // print('exec($numIntr)');
    _clockCount += numIntr;

    _generateRandomMapFromIterable(Reg16.values, 256 * 256).forEach((r, v) {
      this.cpuRegs.update16(r, v);
    }); //debug

    _generateRandomMapFromIterable(MemReg.values, 256).forEach((r, v) {
      this.mmu.pushMemReg(r, v);
    }); //debug

    return ;
  }

}
