// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailram.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 16:18:17 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/registermapping.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/mmu.dart" as Mmu;
import "package:emulator/src/mixins/interrupts.dart" as Interrupt;

abstract class TrapAccessor {
  int tr_pull8(int memAddr);
  void tr_push8(int memAddr, int v);
}

abstract class TailRam
  implements Hardware.Hardware
  , Mmu.Mmu
  , Interrupt.Interrupts {

  /* Getters ******************************************************************/
  int tr_pull8(int memAddr) {
    switch (memAddr) {
      case (P1addr): return this.memr.P1;
      case (SBaddr): return this.memr.SB;
      case (SCaddr): return this.memr.SC;
      case (DIVaddr): return this.memr.DIV;
      case (TIMAaddr): return this.memr.TIMA;
      case (TMAaddr): return this.memr.TMA;
      case (TACaddr): return this.memr.TAC;
      case (IFaddr): return this.memr.IF;
      case (LCDCaddr): return this.memr.LCDC;
      case (STATaddr): return this.memr.STAT;
      case (SCYaddr): return this.memr.SCY;
      case (SCXaddr): return this.memr.SCX;
      case (LYaddr): return this.memr.LY;
      case (LYCaddr): return this.memr.LYC;
      case (DMAaddr): return this.memr.DMA;
      case (BGPaddr): return this.memr.BGP;
      case (OBP0addr): return this.memr.OBP0;
      case (OBP1addr): return this.memr.OBP1;
      case (WYaddr): return this.memr.WY;
      case (WXaddr): return this.memr.WX;
      case (KEY1addr): return this.memr.KEY1;
      case (VBKaddr): return this.memr.VBK;
      case (HDMA1addr): return this.memr.HDMA1;
      case (HDMA2addr): return this.memr.HDMA2;
      case (HDMA3addr): return this.memr.HDMA3;
      case (HDMA4addr): return this.memr.HDMA4;
      case (HDMA5addr): return this.memr.HDMA5;
      case (RPaddr): return this.memr.RP;
      case (BGPIaddr): return this.memr.BGPI;
      case (BGPDaddr): return this.memr.BGPD;
      case (OBPIaddr): return this.memr.OBPI;
      case (OBPDaddr): return this.memr.OBPD;
      case (SVBKaddr): return this.memr.SVBK;
      case (IEaddr): return this.memr.IE;
      default: return this.tailRam.pull8_unsafe(memAddr);
    }
  }

  void tr_push8(int memAddr, int v) {
    switch (memAddr) {
      /* Timers */
      case (DIVaddr):
        this.memr.DIV = 0;
        this.memr.rDIV.counter = 0;
        break ;
      case (TIMAaddr):
        this.memr.TIMA = v;
        this.memr.rTIMA.counter = 0; // Needed ???
        break ;
      case (TMAaddr): this.memr.TMA = v; break ;
      case (TACaddr): this.memr.TAC = v; break ;
      /* Graphics */
      case (LYaddr):
        this.memr.LY = 0;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        break ;
      case (LYCaddr):
        this.memr.LYC = v;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        break ;
      case (STATaddr):
        print('push STAT $v');
        this.memr.STAT = v;
        _updateCoincidence(this.memr.LYC == this.memr.LY);
        break;
      case (DMAaddr): _execDMA(v); break ;
      case (LCDCaddr): _setLCDCRegister(v); break ;
      /* Regular */
      case (P1addr): this.memr.P1 = v; break ;
      case (SBaddr): this.memr.SB = v; break ;
      case (SCaddr): this.memr.SC = v; break ;
      case (IFaddr): this.memr.IF = v; break ;
      case (SCYaddr): this.memr.SCY = v; break ;
      case (SCXaddr): this.memr.SCX = v; break ;
      case (BGPaddr): this.memr.BGP = v; break ;
      case (OBP0addr): this.memr.OBP0 = v; break ;
      case (OBP1addr): this.memr.OBP1 = v; break ;
      case (WYaddr): this.memr.WY = v; break ;
      case (WXaddr): this.memr.WX = v; break ;
      case (KEY1addr): this.memr.KEY1 = v; break ;
      case (VBKaddr): this.memr.VBK = v; break ;
      case (HDMA1addr): this.memr.HDMA1 = v; break ;
      case (HDMA2addr): this.memr.HDMA2 = v; break ;
      case (HDMA3addr): this.memr.HDMA3 = v; break ;
      case (HDMA4addr): this.memr.HDMA4 = v; break ;
      case (HDMA5addr): this.memr.HDMA5 = v; break ;
      case (RPaddr): this.memr.RP = v; break ;
      case (BGPIaddr): this.memr.BGPI = v; break ;
      case (BGPDaddr): this.memr.BGPD = v; break ;
      case (OBPIaddr): this.memr.OBPI = v; break ;
      case (OBPDaddr): this.memr.OBPD = v; break ;
      case (SVBKaddr): this.memr.SVBK = v; break ;
      case (IEaddr): this.memr.IE = v; break ;
      default: this.tailRam.push8_unsafe(memAddr, v); break ;
    }
  }

  /* Specific routines ********************************************************/
  void _setLCDCRegister(int v) {
    final bool enabling = ((v >> 7) & 0x1 == 1);
    if (!this.memr.rLCDC.isLCDEnabled && enabling)
    {
      this.memr.rSTAT.counter = 0;
      this.memr.rSTAT.mode = GraphicMode.OAM_ACCESS;
      this.memr.LY = 0;
      _updateCoincidence(this.memr.LY == this.memr.LYC);
    }
    this.memr.LCDC = v;
    return ;
  }

  void _execDMA(int v) {
    int addr = v * 0x100;

    for (int i = 0 ; i < 40; ++i) {
      this.oam[i].posY = this.pull8(addr + 0);
      this.oam[i].posX = this.pull8(addr + 1);
      this.oam[i].tileID = this.pull8(addr + 2);
      this.oam[i].attribute = this.pull8(addr + 3);
      addr += 4;
    }
    this.memr.DMA = v;
    return ;
  }

  /* BE CAREFUL THE SAME FUNCTION IS IS GRAPHIC -> TO UPDATE */
  /* Generaly, LY, LYC and STAT are linked and should be updated together
  * ASK FOR EXPLANATION */
  void _updateCoincidence(bool coincidence) {
    this.memr.rSTAT.coincidence = coincidence;
    if (coincidence
      && this.memr.rSTAT.isInterruptMonitored(GraphicInterrupt.COINCIDENCE))
      this.requestInterrupt(InterruptType.LCDStat);
    return ;
  }

}
