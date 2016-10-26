// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   interrupts.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/26 09:42:56 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/shared.dart" as Shared;

enum InterruptType {
  VBlank,
  LCDStat,
  Timer,
  Serial,
  Joypad
}

abstract class Interrupts
  implements Hardware.Hardware
  , Shared.Mmu {

  /* API **********************************************************************/

  void handleInterrupts() {
    if (this.cpur.ime == false)
      return ;
    final int IFandIE = this.memr.IE & this.memr.IF;
    if (IFandIE == 0)
      return ;
    for (InterruptType it in InterruptType.values) {
      if ((IFandIE & (1 << it.index)) != 0) {
        _serviceInterrupt(it);
        return ;
      }
    }
    return ;
  }

  void requestInterrupt(InterruptType i) {
    this.cpur.halt = false;
    this.cpur.stop = false;
    this.memr.IF |= (1 << i.index);
    return ;
  }

  /* Private */
  void _serviceInterrupt(InterruptType i) {
    this.cpur.ime = false;
    this.memr.IF = (this.memr.IF & ~(1 << i.index));
    this.pushOnStack16(this.cpur.PC);
    switch(i) {
      case (InterruptType.VBlank) : this.cpur.PC = 0x0040; break ;
      case (InterruptType.LCDStat) : this.cpur.PC = 0x0048 ; break ;
      case (InterruptType.Timer) : this.cpur.PC = 0x0050 ; break ;
      case (InterruptType.Serial) : this.cpur.PC = 0x0058 ; break ;
      case (InterruptType.Joypad) : this.cpur.PC = 0x0060 ; break ;
      default : assert(false, "InterruptManager: serviceInterrupt: switch failure");
    }
    return ;
  }

}
