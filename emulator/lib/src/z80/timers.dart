// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   z80.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 10:19:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";

import "package:emulator/src/gameboy.dart" as GameBoy;

abstract class Timers
  implements GameBoy.GameBoyMemory {

  int _clockTotal = 0;
  int _counterTIMA = 0;
  int _counterDIV = 0;

  /*
  ** API ***********************************************************************
  */

  int get clockCount => _clockTotal;

  void initTimers() {
    _clockTotal = 0;
    _counterTIMA = 0;
    _counterDIV = 0;
    return ;
  }

  void updateTimers(int nbClock) {
    _clockTotal += nbClock;
    _updateDIV(nbClock);
    _updateTIMA(nbClock);
    return ;
  }

  /*
  ** Private *******************************************************************
  */

  void _updateDIV(int nbClock) {
    _counterDIV -= nbClock;
    if (_counterDIV < 0)
    {
      _counterDIV = 256;
      final int div = this.mmu.pullMemReg(MemReg.DIV);
      // this.mmu.setDIV((div + 1) & 0xFF);
    }
    return ;
  }

  void _updateTIMA(int nbClock) {
    final int TAC = this.mmu.pullMemReg(MemReg.TAC);
    if (TAC & (0x1 << 2) != 0) {
      _counterTIMA -= nbClock;
      if (_counterTIMA < 0)
      {
        switch(TAC & 0x3)
        {
          case (0): _counterTIMA = 1024; break;
          case (1): _counterTIMA = 16; break;
          case (2): _counterTIMA = 64; break;
          case (3): _counterTIMA = 256; break;
          default : assert(false, '_updateTIMA: switch failure');
        }
        final int TMA = this.mmu.pullMemReg(MemReg.TIMA);
        this.mmu.pushMemReg(MemReg.TIMA, TMA);
        // Request INTERRUPT
      }

    }
    return ;
  }

}