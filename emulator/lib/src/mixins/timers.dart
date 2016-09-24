// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   timers.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 12:56:50 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";

import "package:emulator/src/gameboy.dart" as GameBoy;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/mem_mmu.dart" as Mmu;
import "package:emulator/src/mixins/mem_registermapping.dart" as Memregmapping;

abstract class Timers
  implements GameBoy.Hardware
  , Interrupt.InterruptManager
  , Memregmapping.MemRegisterMapping
  , Mmu.Mmu {

  int _clockTotal = 0;
  int _counterTIMA = 0;
  int _counterDIV = 0;

  /* API **********************************************************************/

  int get clockCount => _clockTotal;

  void updateTimers(int nbClock) {
    _clockTotal += nbClock;
    _updateDIV(nbClock);
    _updateTIMA(nbClock);
    return ;
  }

  /* Private ******************************************************************/

  void _updateDIV(int nbClock) {
    _counterDIV -= nbClock;
    if (_counterDIV <= 0)
    {
      _counterDIV = 0xFF;
      final DIV_old = this.pullMemReg_unsafe(MemReg.DIV);
      final DIV_new = (DIV_old + 1) & 0xFF;
      this.pushMemReg_unsafe(MemReg.DIV, DIV_new);
    }
    return ;
  }

  void _updateTIMA(int nbClock) {
    final int TAC = this.pullMemReg_unsafe(MemReg.TAC);
    if (TAC & (0x1 << 2) != 0) {
      _counterTIMA -= nbClock;
      if (_counterTIMA <= 0)
      {
        switch(TAC & 0x3)
        {
          case (0): _counterTIMA = 1024; break;
          case (1): _counterTIMA = 16; break;
          case (2): _counterTIMA = 64; break;
          case (3): _counterTIMA = 256; break;
          default : assert(false, '_updateTIMA: switch failure');
        }
        final int TMA = this.pullMemReg_unsafe(MemReg.TIMA);
        this.pushMemReg_unsafe(MemReg.TIMA, TMA);
        this.requestInterrupt(InterruptType.Timer);
      }

    }
    return ;
  }

}