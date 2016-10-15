// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 19:33:28 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/registermapping.dart";

class MemRegs {

  final List<int> _data;

  /* Constructors *************************************************************/
  MemRegs.ofList(List<int> l) : _data = l;

  MemRegs() : this.ofList(new List<int>.filled(g_memRegInfos.length, 0));

  /* API **********************************************************************/
  void reset() {
    for (MemRegInfo mrinfo in g_memRegInfos) {
      _data[mrinfo.reg.index] = mrinfo.initValue;
    }
  }
  
  /* RAW ACCESSORS *****************************/
  int get P1 => _data[MemReg.P1.index];
  int get SB => _data[MemReg.SB.index];
  int get SC => _data[MemReg.SC.index];
  int get DIV => _data[MemReg.DIV.index];
  int get TIMA => _data[MemReg.TIMA.index];
  int get TMA => _data[MemReg.TMA.index];
  int get TAC => _data[MemReg.TAC.index];
  int get IF => _data[MemReg.IF.index];
  int get LCDC => _data[MemReg.LCDC.index];
  int get STAT => _data[MemReg.STAT.index];
  int get SCY => _data[MemReg.SCY.index];
  int get SCX => _data[MemReg.SCX.index];
  int get LY => _data[MemReg.LY.index];
  int get LYC => _data[MemReg.LYC.index];
  int get DMA => _data[MemReg.DMA.index];
  int get BGP => _data[MemReg.BGP.index];
  int get OBP0 => _data[MemReg.OBP0.index];
  int get OBP1 => _data[MemReg.OBP1.index];
  int get WY => _data[MemReg.WY.index];
  int get WX => _data[MemReg.WX.index];
  int get KEY1 => _data[MemReg.KEY1.index];
  int get VBK => _data[MemReg.VBK.index];
  int get HDMA1 => _data[MemReg.HDMA1.index];
  int get HDMA2 => _data[MemReg.HDMA2.index];
  int get HDMA3 => _data[MemReg.HDMA3.index];
  int get HDMA4 => _data[MemReg.HDMA4.index];
  int get HDMA5 => _data[MemReg.HDMA5.index];
  int get RP => _data[MemReg.RP.index];
  int get BGPI => _data[MemReg.BGPI.index];
  int get BGPD => _data[MemReg.BGPD.index];
  int get OBPI => _data[MemReg.OBPI.index];
  int get OBPD => _data[MemReg.OBPD.index];
  int get SVBK => _data[MemReg.SVBK.index];
  int get IE => _data[MemReg.IE.index];

  void set P1(int v) {_data[MemReg.P1.index] = v;}
  void set SB(int v) {_data[MemReg.SB.index] = v;}
  void set SC(int v) {_data[MemReg.SC.index] = v;}
  void set DIV(int v) {_data[MemReg.DIV.index] = v;}
  void set TIMA(int v) {_data[MemReg.TIMA.index] = v;}
  void set TMA(int v) {_data[MemReg.TMA.index] = v;}
  void set TAC(int v) {_data[MemReg.TAC.index] = v;}
  void set IF(int v) {_data[MemReg.IF.index] = v;}
  void set LCDC(int v) {_data[MemReg.LCDC.index] = v;}
  void set STAT(int v) {_data[MemReg.STAT.index] = v;}
  void set SCY(int v) {_data[MemReg.SCY.index] = v;}
  void set SCX(int v) {_data[MemReg.SCX.index] = v;}
  void set LY(int v) {_data[MemReg.LY.index] = v;}
  void set LYC(int v) {_data[MemReg.LYC.index] = v;}
  void set DMA(int v) {_data[MemReg.DMA.index] = v;}
  void set BGP(int v) {_data[MemReg.BGP.index] = v;}
  void set OBP0(int v) {_data[MemReg.OBP0.index] = v;}
  void set OBP1(int v) {_data[MemReg.OBP1.index] = v;}
  void set WY(int v) {_data[MemReg.WY.index] = v;}
  void set WX(int v) {_data[MemReg.WX.index] = v;}
  void set KEY1(int v) {_data[MemReg.KEY1.index] = v;}
  void set VBK(int v) {_data[MemReg.VBK.index] = v;}
  void set HDMA1(int v) {_data[MemReg.HDMA1.index] = v;}
  void set HDMA2(int v) {_data[MemReg.HDMA2.index] = v;}
  void set HDMA3(int v) {_data[MemReg.HDMA3.index] = v;}
  void set HDMA4(int v) {_data[MemReg.HDMA4.index] = v;}
  void set HDMA5(int v) {_data[MemReg.HDMA5.index] = v;}
  void set RP(int v) {_data[MemReg.RP.index] = v;}
  void set BGPI(int v) {_data[MemReg.BGPI.index] = v;}
  void set BGPD(int v) {_data[MemReg.BGPD.index] = v;}
  void set OBPI(int v) {_data[MemReg.OBPI.index] = v;}
  void set OBPD(int v) {_data[MemReg.OBPD.index] = v;}
  void set SVBK(int v) {_data[MemReg.SVBK.index] = v;}
  void set IE(int v) {_data[MemReg.IE.index] = v;}

  int pull8(MemReg r) => _data[r.index];

}
