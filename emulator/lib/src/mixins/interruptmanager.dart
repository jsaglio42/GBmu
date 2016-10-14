// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   interruptmanager.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 15:30:40 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/mmu.dart" as Mmu;

enum InterruptType {
  VBlank,
  LCDStat,
  Timer,
  Serial,
  Joypad
}

abstract class InterruptManager
  implements Hardware.Hardware
  , Mmu.Mmu {

  /* API **********************************************************************/

  void handleInterrupts() {
    if (this.ime == false)
      return ;
    final int IE = this.IE;
    final int IF = this.IF;
    final int IFandIE = IF & IE;
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
    final int IF_old = this.IF;
    final int IF_new = IF_old | (1 << i.index);
    this.halt = false;
    this.stop = false;
    this.IF = IF_new;
    return ;
  }

  /* Private */

  int _vblankno = 0;
  void _serviceInterrupt(InterruptType i) {
    this.ime = false;
    final int IF_old = this.IF;
    final int IF_new = (IF_old & ~(1 << i.index)) & 0xFF;
    this.IF = IF_new;
    this.pushOnStack16(this.cpur.PC);
    switch(i) {
      case (InterruptType.VBlank) :
        // print('VBLANK NO: ${_vblankno++}');
        this.cpur.PC = 0x0040;
        break ;
      case (InterruptType.LCDStat) : this.cpur.PC = 0x0048 ; break ;
      case (InterruptType.Timer) : this.cpur.PC = 0x0050 ; break ;
      case (InterruptType.Serial) : this.cpur.PC = 0x0058 ; break ;
      case (InterruptType.Joypad) : this.cpur.PC = 0x0060 ; break ;
      default : assert(false, "InterruptManager: serviceInterrupt: switch failure");
    }
    return ;
  }

}
