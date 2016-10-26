// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   shared.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/26 11:20:30 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:emulator/src/enums.dart';
import "package:emulator/src/hardware/hardware.dart" as Hardware;

abstract class Interrupts {
  void requestInterrupt(InterruptType i);
}

abstract class Mmu {
  int pull8(int memAddr);
  void push8(int memAddr, int v);

  int pull16(int memAddr);
  void push16(int memAddr, int v);
  void pushOnStack16(int v);

}

abstract class VideoRam {
  int vr_pull8(int memAddr);
  void vr_push8(int memAddr, int v);
}

abstract class InternalRam {
  int ir_pull8(int memAddr);
  void ir_push8(int memAddr, int v);
}

abstract class TailRam
  implements Hardware.Hardware
  , Mmu
  , Interrupts {

  int tr_pull8(int memAddr);
  void tr_push8(int memAddr, int v);

  void setLYRegister(int v) {
      this.memr.LY = v;
      this.updateSTAT_coincidence();
      return ;
  }

  void setLYCRegister(int v) {
    this.memr.LYC = v;
    this.updateSTAT_coincidence();
    return ;
  }

  void setSTATRegister(int v) {
    this.memr.rSTAT.interrupts = v;
    this.updateSTAT_coincidence();
    return ;
  }

  void setLCDCRegister(int v) {
    final bool enabling = ((v >> 7) & 0x1 == 1);
    if (!this.memr.rLCDC.isLCDEnabled && enabling)
    {
      this.memr.rSTAT.counter = 0;
      this.memr.rSTAT.mode = GraphicMode.OAM_ACCESS;
      this.setLYRegister(0);
      this.updateSTAT_coincidence();
    }
    this.memr.LCDC = v;
    return ;
  }

  void setDMARegister(int v) {
    int addr = v * 0x100;

    for (int i = 0 ; i < 40; ++i) {
      this.oam[i].posY = this.pull8(addr + 0);
      this.oam[i].posX = this.pull8(addr + 1);
      this.oam[i].tileID = this.pull8(addr + 2);
      this.oam[i].info.value = this.pull8(addr + 3);
      addr += 4;
    }
    this.memr.DMA = v;
  return ;
  }

  void updateSTAT_coincidence() {
    if (this.memr.LYC != this.memr.LY)
      this.memr.rSTAT.coincidence = 0x0;
    else
    {
      this.memr.rSTAT.coincidence = 0x1;
      if (this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.COINCIDENCE))
        this.requestInterrupt(InterruptType.LCDStat);
    }
    return ;
  }

}

