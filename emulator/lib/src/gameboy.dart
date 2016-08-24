// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   public_classes.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 11:27:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 17:34:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "cpu_registers.dart";
import "memory/mmu.dart";
import "memory/cartridge.dart";

class GameBoy {

  final CpuRegs 	_cpuRegs = new CpuRegs();
  final Mmu     	_mmu;
  final Cartridge	_cartridge;
  // final LCDScreen _lcd;
  // final Headset _sound;

  int 				_instrCount = 0;

  GameBoy(Cartridge c) //TODO: pass LCDScreen and Headset
    : _cartridge = c
    , _mmu = new Mmu(c);

  int get instrCount => _instrCount;

  void exec(int numIntr) {
    _instrCount += numIntr;
    return ;
  }

}
