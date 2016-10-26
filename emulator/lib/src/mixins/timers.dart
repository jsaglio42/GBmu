// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   timers.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/26 09:41:55 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/shared.dart" as Shared;

abstract class Timers
  implements Hardware.Hardware
  , Shared.Interrupts {

  /* API **********************************************************************/
  void updateTimers(int nbClock) {
    this.clockTotal += nbClock;
    _updateDIV(nbClock);
    _updateTIMA(nbClock);
    return ;
  }

  /* Private ******************************************************************/
  void _updateDIV(int nbClock) {
    this.memr.rDIV.counter += nbClock;
    if (this.memr.rDIV.counter >= 256)
    {
      this.memr.rDIV.counter -= 256;
      this.memr.DIV = (this.memr.DIV + 1) & 0xFF;
    }
    return ;
  }

  void _updateTIMA(int nbClock) {
    if (this.memr.TAC & (0x1 << 2) == 0)
      return ;
    this.memr.rTIMA.counter += nbClock;
    if (this.memr.rTIMA.counter >= this.memr.rTIMA.threshold)
    {
      this.memr.rTIMA.counter -= this.memr.rTIMA.threshold;
      this.memr.rTIMA.threshold = this.memr.rTAC.frequency;
      if (this.memr.TIMA < 0xFF)
        this.memr.TIMA = this.memr.TIMA + 1;
      else
      {
        this.memr.TIMA = this.memr.TMA;
        this.requestInterrupt(InterruptType.Timer);
      }
    }
    return ;
  }

}
