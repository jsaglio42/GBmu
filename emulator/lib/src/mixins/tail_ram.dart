// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tail_ram.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 15:38:29 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/registermapping.dart";
import "package:emulator/src/mixins/graphics.dart" as Graphics;
import "package:emulator/src/mixins/joypad.dart" as Joypad;
import "package:emulator/src/mixins/timers.dart" as Timers;

// WORK IN PROGRESS - NOT LINKED - DOES NOT COMPILE

abstract class TailRam implements
  Joypad.TrapAccessors, Timers.TrapAccessors, Graphics.TrapAccessors
{

  // ATTRIBUTES ************************************************************* **
  final List<int> _memRegs = new List.from(
      g_memRegInfos.map((MemRegInfo i) => i.initValue), growable: false);
  final Uint8List _data = new Uint8List(TAIL_RAM_SIZE);

  // CONSTRUCTION *********************************************************** **
  void init_tailRam() {
    this.tr_push8(0xFF10, 0x80);
    this.tr_push8(0xFF11, 0xBF);
    this.tr_push8(0xFF12, 0xF3);
    this.tr_push8(0xFF14, 0xBF);
    this.tr_push8(0xFF16, 0x3F);
    this.tr_push8(0xFF17, 0x00);
    this.tr_push8(0xFF19, 0xBF);
    this.tr_push8(0xFF1A, 0x7F);
    this.tr_push8(0xFF1B, 0xFF);
    this.tr_push8(0xFF1C, 0x9F);
    this.tr_push8(0xFF1E, 0xBF);
    this.tr_push8(0xFF20, 0xFF);
    this.tr_push8(0xFF21, 0x00);
    this.tr_push8(0xFF22, 0x00);
    this.tr_push8(0xFF23, 0xBF);
    this.tr_push8(0xFF24, 0x77);
    this.tr_push8(0xFF25, 0xF3);
    this.tr_push8(0xFF26, 0xF1);
  }

  // ACCESSORS ************************************************************** **
  // RAW ACCESSORS **************************** **
  int get P1_raw => _memRegs[MemReg.P1.index];
  int get SB => _memRegs[MemReg.SB.index];
  int get SC => _memRegs[MemReg.SC.index];
  int get DIV => _memRegs[MemReg.DIV.index];
  int get TIMA => _memRegs[MemReg.TIMA.index];
  int get TMA => _memRegs[MemReg.TMA.index];
  int get TAC => _memRegs[MemReg.TAC.index];
  int get IF => _memRegs[MemReg.IF.index];
  int get LCDC => _memRegs[MemReg.LCDC.index];
  int get STAT => _memRegs[MemReg.STAT.index];
  int get SCY => _memRegs[MemReg.SCY.index];
  int get SCX => _memRegs[MemReg.SCX.index];
  int get LY => _memRegs[MemReg.LY.index];
  int get LYC => _memRegs[MemReg.LYC.index];
  int get DMA => _memRegs[MemReg.DMA.index];
  int get BGP => _memRegs[MemReg.BGP.index];
  int get OBP0 => _memRegs[MemReg.OBP0.index];
  int get OBP1 => _memRegs[MemReg.OBP1.index];
  int get WY => _memRegs[MemReg.WY.index];
  int get WX => _memRegs[MemReg.WX.index];
  int get KEY1 => _memRegs[MemReg.KEY1.index];
  int get VBK => _memRegs[MemReg.VBK.index];
  int get HDMA1 => _memRegs[MemReg.HDMA1.index];
  int get HDMA2 => _memRegs[MemReg.HDMA2.index];
  int get HDMA3 => _memRegs[MemReg.HDMA3.index];
  int get HDMA4 => _memRegs[MemReg.HDMA4.index];
  int get HDMA5 => _memRegs[MemReg.HDMA5.index];
  int get RP => _memRegs[MemReg.RP.index];
  int get BGPI => _memRegs[MemReg.BGPI.index];
  int get BGPD => _memRegs[MemReg.BGPD.index];
  int get OBPI => _memRegs[MemReg.OBPI.index];
  int get OBPD => _memRegs[MemReg.OBPD.index];
  int get SVBK => _memRegs[MemReg.SVBK.index];
  int get IE => _memRegs[MemReg.IE.index];

  void set P1_raw(int v) {_memRegs[MemReg.P1.index] = v;}
  void set SB(int v) {_memRegs[MemReg.SB.index] = v;}
  void set SC(int v) {_memRegs[MemReg.SC.index] = v;}
  void set DIV_raw(int v) {_memRegs[MemReg.DIV.index] = v;}
  void set TIMA(int v) {_memRegs[MemReg.TIMA.index] = v;}
  void set TMA(int v) {_memRegs[MemReg.TMA.index] = v;}
  void set TAC(int v) {_memRegs[MemReg.TAC.index] = v;}
  void set IF(int v) {_memRegs[MemReg.IF.index] = v;}
  void set LCDC(int v) {_memRegs[MemReg.LCDC.index] = v;}
  void set STAT(int v) {_memRegs[MemReg.STAT.index] = v;}
  void set SCY(int v) {_memRegs[MemReg.SCY.index] = v;}
  void set SCX(int v) {_memRegs[MemReg.SCX.index] = v;}
  void set LY_raw(int v) {_memRegs[MemReg.LY.index] = v;}
  void set LYC(int v) {_memRegs[MemReg.LYC.index] = v;}
  void set DMA_raw(int v) {_memRegs[MemReg.DMA.index] = v;}
  void set BGP(int v) {_memRegs[MemReg.BGP.index] = v;}
  void set OBP0(int v) {_memRegs[MemReg.OBP0.index] = v;}
  void set OBP1(int v) {_memRegs[MemReg.OBP1.index] = v;}
  void set WY(int v) {_memRegs[MemReg.WY.index] = v;}
  void set WX(int v) {_memRegs[MemReg.WX.index] = v;}
  void set KEY1(int v) {_memRegs[MemReg.KEY1.index] = v;}
  void set VBK(int v) {_memRegs[MemReg.VBK.index] = v;}
  void set HDMA1(int v) {_memRegs[MemReg.HDMA1.index] = v;}
  void set HDMA2(int v) {_memRegs[MemReg.HDMA2.index] = v;}
  void set HDMA3(int v) {_memRegs[MemReg.HDMA3.index] = v;}
  void set HDMA4(int v) {_memRegs[MemReg.HDMA4.index] = v;}
  void set HDMA5(int v) {_memRegs[MemReg.HDMA5.index] = v;}
  void set RP(int v) {_memRegs[MemReg.RP.index] = v;}
  void set BGPI(int v) {_memRegs[MemReg.BGPI.index] = v;}
  void set BGPD(int v) {_memRegs[MemReg.BGPD.index] = v;}
  void set OBPI(int v) {_memRegs[MemReg.OBPI.index] = v;}
  void set OBPD(int v) {_memRegs[MemReg.OBPD.index] = v;}
  void set SVBK(int v) {_memRegs[MemReg.SVBK.index] = v;}
  void set IE(int v) {_memRegs[MemReg.IE.index] = v;}

  // SPECIAL ACCESSORS ************************ **
  int get P1 => this.getJoypadRegister();
  void set P1(int v) {this.setJoypadRegister(v);}
  void set DIV(int v) {this.resetDIVRegister();}
  void set LY(int v) {this.resetLYRegister();}
  void set DMA(int v) {this.execDMA(v);}

  // ADDRESS ACCESSORS ************************ **
  int tr_pull8(int memAddr) {
    switch (memAddr) {
      case (P1addr): return this.P1;
      case (SBaddr): return this.SB;
      case (SCaddr): return this.SC;
      case (DIVaddr): return this.DIV;
      case (TIMAaddr): return this.TIMA;
      case (TMAaddr): return this.TMA;
      case (TACaddr): return this.TAC;
      case (IFaddr): return this.IF;
      case (LCDCaddr): return this.LCDC;
      case (STATaddr): return this.STAT;
      case (SCYaddr): return this.SCY;
      case (SCXaddr): return this.SCX;
      case (LYaddr): return this.LY;
      case (LYCaddr): return this.LYC;
      case (DMAaddr): return this.DMA;
      case (BGPaddr): return this.BGP;
      case (OBP0addr): return this.OBP0;
      case (OBP1addr): return this.OBP1;
      case (WYaddr): return this.WY;
      case (WXaddr): return this.WX;
      case (KEY1addr): return this.KEY1;
      case (VBKaddr): return this.VBK;
      case (HDMA1addr): return this.HDMA1;
      case (HDMA2addr): return this.HDMA2;
      case (HDMA3addr): return this.HDMA3;
      case (HDMA4addr): return this.HDMA4;
      case (HDMA5addr): return this.HDMA5;
      case (RPaddr): return this.RP;
      case (BGPIaddr): return this.BGPI;
      case (BGPDaddr): return this.BGPD;
      case (OBPIaddr): return this.OBPI;
      case (OBPDaddr): return this.OBPD;
      case (SVBKaddr): return this.SVBK;
      case (IEaddr): return this.IE;
      default: return _data[memAddr - TAIL_RAM_FIRST];
    }
  }

  void tr_push8(int memAddr, int v) {
    switch (memAddr) {
      case (P1addr): this.P1 = v; break ;
      case (SBaddr): this.SB = v; break ;
      case (SCaddr): this.SC = v; break ;
      case (DIVaddr): this.DIV = v; break ;
      case (TIMAaddr): this.TIMA = v; break ;
      case (TMAaddr): this.TMA = v; break ;
      case (TACaddr): this.TAC = v; break ;
      case (IFaddr): this.IF = v; break ;
      case (LCDCaddr): this.LCDC = v; break ;
      case (STATaddr): this.STAT = v; break ;
      case (SCYaddr): this.SCY = v; break ;
      case (SCXaddr): this.SCX = v; break ;
      case (LYaddr): this.LY = v; break ;
      case (LYCaddr): this.LYC = v; break ;
      case (DMAaddr): this.DMA = v; break ;
      case (BGPaddr): this.BGP = v; break ;
      case (OBP0addr): this.OBP0 = v; break ;
      case (OBP1addr): this.OBP1 = v; break ;
      case (WYaddr): this.WY = v; break ;
      case (WXaddr): this.WX = v; break ;
      case (KEY1addr): this.KEY1 = v; break ;
      case (VBKaddr): this.VBK = v; break ;
      case (HDMA1addr): this.HDMA1 = v; break ;
      case (HDMA2addr): this.HDMA2 = v; break ;
      case (HDMA3addr): this.HDMA3 = v; break ;
      case (HDMA4addr): this.HDMA4 = v; break ;
      case (HDMA5addr): this.HDMA5 = v; break ;
      case (RPaddr): this.RP = v; break ;
      case (BGPIaddr): this.BGPI = v; break ;
      case (BGPDaddr): this.BGPD = v; break ;
      case (OBPIaddr): this.OBPI = v; break ;
      case (OBPDaddr): this.OBPD = v; break ;
      case (SVBKaddr): this.SVBK = v; break ;
      case (IEaddr): this.IE = v; break ;
      default: _data[memAddr - TAIL_RAM_FIRST] = v; break ;
    }
  }

  // MISC ************************************* **
  int tr_pullMemReg(MemReg r) => _memRegs[r.index];

}