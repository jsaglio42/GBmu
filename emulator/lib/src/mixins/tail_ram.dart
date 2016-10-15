// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tail_ram.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 19:31:41 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/registermapping.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/graphics.dart" as Graphics;
import "package:emulator/src/mixins/joypad.dart" as Joypad;
import "package:emulator/src/mixins/timers.dart" as Timers;

// WORK IN PROGRESS - NOT LINKED - DOES NOT COMPILE

abstract class TailRam implements Hardware.Hardware
  , Joypad.TrapAccessors
  , Timers.TrapAccessors
  , Graphics.TrapAccessors
{

  final Uint8List _data = new Uint8List(TAIL_RAM_SIZE);

  // CONSTRUCTION *********************************************************** **
  void init_tailRam() {
    _data.fillRange(0, data.length, 0);
    _data[0xFF10 - TAIL_RAM_FIRST] = 0x80;
    _data[0xFF11 - TAIL_RAM_FIRST] = 0xBF;
    _data[0xFF12 - TAIL_RAM_FIRST] = 0xF3;
    _data[0xFF14 - TAIL_RAM_FIRST] = 0xBF;
    _data[0xFF16 - TAIL_RAM_FIRST] = 0x3F;
    _data[0xFF17 - TAIL_RAM_FIRST] = 0x00;
    _data[0xFF19 - TAIL_RAM_FIRST] = 0xBF;
    _data[0xFF1A - TAIL_RAM_FIRST] = 0x7F;
    _data[0xFF1B - TAIL_RAM_FIRST] = 0xFF;
    _data[0xFF1C - TAIL_RAM_FIRST] = 0x9F;
    _data[0xFF1E - TAIL_RAM_FIRST] = 0xBF;
    _data[0xFF20 - TAIL_RAM_FIRST] = 0xFF;
    _data[0xFF21 - TAIL_RAM_FIRST] = 0x00;
    _data[0xFF22 - TAIL_RAM_FIRST] = 0x00;
    _data[0xFF23 - TAIL_RAM_FIRST] = 0xBF;
    _data[0xFF24 - TAIL_RAM_FIRST] = 0x77;
    _data[0xFF25 - TAIL_RAM_FIRST] = 0xF3;
    _data[0xFF26 - TAIL_RAM_FIRST] = 0xF1;
  }

  // ACCESSORS ************************************************************** **
  // SPECIAL ACCESSORS ************************ **
  // int get P1 => this.getJoypadRegister();
  // void set P1(int v) {this.setJoypadRegister(v);}
  // void set DIV(int v) {this.resetDIVRegister();}
  // void set LY(int v) {this.resetLYRegister();}
  // void set DMA(int v) {this.execDMA(v);}

  // ADDRESS ACCESSORS ************************ **
  /* Add specific getter here */
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
      default: return _data[memAddr - TAIL_RAM_FIRST];
    }
  }

  /* Add specific setter here */
  void tr_push8(int memAddr, int v) {
    switch (memAddr) {
      case (P1addr): this.memr.P1 = v; break ;
      case (SBaddr): this.memr.SB = v; break ;
      case (SCaddr): this.memr.SC = v; break ;
      case (DIVaddr): this.memr.DIV = v; break ;
      case (TIMAaddr): this.memr.TIMA = v; break ;
      case (TMAaddr): this.memr.TMA = v; break ;
      case (TACaddr): this.memr.TAC = v; break ;
      case (IFaddr): this.memr.IF = v; break ;
      case (LCDCaddr): this.memr.LCDC = v; break ;
      case (STATaddr): this.memr.STAT = v; break ;
      case (SCYaddr): this.memr.SCY = v; break ;
      case (SCXaddr): this.memr.SCX = v; break ;
      case (LYaddr): this.memr.LY = v; break ;
      case (LYCaddr): this.memr.LYC = v; break ;
      case (DMAaddr): this.memr.DMA = v; break ;
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
      default: _data[memAddr - TAIL_RAM_FIRST] = v; break ;
    }
  }

  /* Add specific getter here */
  int tr_pullMemReg(MemReg r) {
    return this.memr.pull8(r);
  }

}
