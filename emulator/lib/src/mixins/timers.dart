// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   timers.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 17:25:21 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;

final int _addrDIV = g_memRegInfos[MemReg.DIV.index].address;
final int _addrTIMA = g_memRegInfos[MemReg.TIMA.index].address;
final int _addrTMA = g_memRegInfos[MemReg.TMA.index].address;
final int _addrTAC = g_memRegInfos[MemReg.TAC.index].address;

abstract class Timers
  implements Hardware.Hardware
  , Interrupt.InterruptManager {

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
      final DIV_old = this.tailRam.pull8_unsafe(_addrDIV);
      final DIV_new = (DIV_old + 1) & 0xFF;
      this.tailRam.push8_unsafe(_addrDIV, DIV_new);
    }
    return ;
  }

  void _updateTIMA(int nbClock) {
    final int TAC = this.tailRam.pull8_unsafe(_addrTAC);
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
        final int TMA = this.tailRam.pull8_unsafe(_addrTMA);
        this.tailRam.push8_unsafe(_addrTIMA, TMA);
        this.requestInterrupt(InterruptType.Timer);
      }
    }
    return ;
  }

}
