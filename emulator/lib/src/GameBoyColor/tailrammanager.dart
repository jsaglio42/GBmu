// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailrammanager.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 14:52:41 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/mem_registers_info.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/shared.dart" as Shared;

abstract class TailRamManager
  implements Hardware.Hardware
  , Shared.TailRam {

  /* Getters ******************************************************************/
  int tr_pull8(int memAddr) {
    assert(memAddr >= 0xFF00, 'tr_pull8: invalid memAddr $memAddr');
    assert(memAddr & ~0xFFFF == 0, 'tr_pull8: invalid memAddr $memAddr');
    switch (memAddr) {
      case (addr_P1): return this.memr.P1;
      case (addr_SB): return this.memr.SB;
      case (addr_SC): return this.memr.SC;
      case (addr_DIV): return this.memr.DIV;
      case (addr_TIMA): return this.memr.TIMA;
      case (addr_TMA): return this.memr.TMA;
      case (addr_TAC): return this.memr.TAC;
      case (addr_IF): return this.memr.IF;
      case (addr_LCDC): return this.memr.LCDC;
      case (addr_STAT): return this.memr.STAT;
      case (addr_SCY): return this.memr.SCY;
      case (addr_SCX): return this.memr.SCX;
      case (addr_LY): return this.memr.LY;
      case (addr_LYC): return this.memr.LYC;
      case (addr_DMA): return this.memr.DMA;
      case (addr_BGP): return this.memr.BGP;
      case (addr_OBP0): return this.memr.OBP0;
      case (addr_OBP1): return this.memr.OBP1;
      case (addr_WY): return this.memr.WY;
      case (addr_WX): return this.memr.WX;
      case (addr_IE): return this.memr.IE;
      default: return this.tailram.pull8(memAddr);
    }
  }

  void tr_push8(int memAddr, int v) {
    assert(memAddr >= 0xFF00, 'tr_push8: invalid memAddr $memAddr');
    assert(memAddr & ~0xFFFF == 0, 'tr_push8: invalid memAddr $memAddr');
    switch (memAddr) {
      /* Timers */
      case (addr_DIV):
        this.memr.DIV = 0;
        this.memr.rDIV.counter = 0;
        break ;
      case (addr_TIMA):
        this.memr.TIMA = v;
        this.memr.rTIMA.counter = 0;
        break ;
      case (addr_TMA): this.memr.TMA = v; break ;
      case (addr_TAC): this.memr.TAC = v; break ;
      /* Graphics */
      case (addr_LCDC): this.setLCDCRegister(v); break ;
      case (addr_LYC): this.setLYCRegister(v); break ;
      case (addr_LY): this.setLYRegister(0);
        this.memr.rSTAT.counter = 0;
        this.memr.rSTAT.mode = GraphicMode.OAM_ACCESS;
        break ;
      case (addr_STAT): this.setSTATRegister(v); break ;
      case (addr_DMA): this.setDMARegister(v); break ;
      /* Interrupts */
      case (addr_IF): this.memr.IF = (v & 0x1F); break ;
      case (addr_IE): this.memr.IE = (v & 0x1F); break ;
      /* Regular */
      case (addr_P1): this.memr.P1 = v; break ;
      case (addr_SB): this.memr.SB = v; break ;
      case (addr_SC): this.memr.SC = v; break ;
      case (addr_SCY): this.memr.SCY = v; break ;
      case (addr_SCX): this.memr.SCX = v; break ;
      case (addr_BGP): this.memr.BGP = v; break ;
      case (addr_OBP0): this.memr.OBP0 = v; break ;
      case (addr_OBP1): this.memr.OBP1 = v; break ;
      case (addr_WY): this.memr.WY = v; break ;
      case (addr_WX): this.memr.WX = v; break ;
      default: this.tailram.push8(memAddr, v); break ;
    }
  }

}
