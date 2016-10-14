// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registermapping.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 15:12:08 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * Byte Registers Mapped in Memory
 * Sorted by address
 */

enum MemReg {
  P1,
  SB,
  SC,
  DIV,
  TIMA,
  TMA,
  TAC,
  IF,
  LCDC,
  STAT,
  SCY,
  SCX,
  LY,
  LYC,
  DMA,
  BGP,
  OBP0,
  OBP1,
  WY,
  WX,
  KEY1,
  VBK,
  HDMA1,
  HDMA2,
  HDMA3,
  HDMA4,
  HDMA5,
  RP,
  BGPI,
  BGPD,
  OBPI,
  OBPD,
  SVBK,
  IE,
}

const int P1addr = 0xFF00;
const int SBaddr = 0xFF01;
const int SCaddr = 0xFF02;
const int DIVaddr = 0xFF04;
const int TIMAaddr = 0xFF05;
const int TMAaddr = 0xFF06;
const int TACaddr = 0xFF07;
const int IFaddr = 0xFF0;
const int LCDCaddr = 0xFF40;
const int STATaddr = 0xFF41;
const int SCYaddr = 0xFF42;
const int SCXaddr = 0xFF43;
const int LYaddr = 0xFF44;
const int LYCaddr = 0xFF45;
const int DMAaddr = 0xFF46;
const int BGPaddr = 0xFF47;
const int OBP0addr = 0xFF;
const int OBP1addr = 0xFF;
const int WYaddr = 0xFF4;
const int WXaddr = 0xFF4;
const int KEY1addr = 0xFF;
const int VBKaddr = 0xFF4;
const int HDMA1addr = 0xFF;
const int HDMA2addr = 0xFF;
const int HDMA3addr = 0xFF;
const int HDMA4addr = 0xFF;
const int HDMA5addr = 0xFF;
const int RPaddr = 0xFF56;
const int BGPIaddr = 0xFF68;
const int BGPDaddr = 0xFF69;
const int OBPIaddr = 0xFF6;
const int OBPDaddr = 0xFF6;
const int SVBKaddr = 0xFF70;
const int IEaddr = 0xFFFF;

class MemRegInfo {

  final MemReg reg;
  final int address;
  final bool cgb;
  final int initValue; //TODO: MemRegInfo.initValue
  final String name;
  final String category;
  final String description;

  const MemRegInfo(this.reg
      , this.address
      , this.cgb
      , this.initValue
      , this.name
      , this.category
      , this.description);

}

final Map<int, MemRegInfo> g_memRegInfosByAddress = new Map<int, MemRegInfo>
  .fromIterable(g_memRegInfos
    , key: (rinfo) => rinfo.address
    , value: (rinfo) => rinfo);

const List<MemRegInfo> g_memRegInfos = const <MemRegInfo>[
  const MemRegInfo(MemReg.P1, 0xFF00, false, 0,
      'P1', 'Port/Mode', 'Joypad'),
  const MemRegInfo(MemReg.SB, 0xFF01, false, 0,
      'SB', 'Port/Mode', 'Serial Transfer Data'),
  const MemRegInfo(MemReg.SC, 0xFF02, false, 0,
      'SC', 'Port/Mode', 'Serial Transfer Control'),
  const MemRegInfo(MemReg.DIV, 0xFF04, false, 0,
      'DIV', 'Timer', 'Divider Register'),
  const MemRegInfo(MemReg.TIMA, 0xFF05, false, 0,
      'TIMA', 'Timer', 'Timer Counter'),
  const MemRegInfo(MemReg.TMA, 0xFF06, false, 0,
      'TMA', 'Timer', 'Timer Modulo'),
  const MemRegInfo(MemReg.TAC, 0xFF07, false, 0,
      'TAC', 'Timer', 'Timer Control'),
  const MemRegInfo(MemReg.IF, 0xFF0F, false, 0,
      'IF', 'Interrupt', 'Interrupt Flag'),
  const MemRegInfo(MemReg.LCDC, 0xFF40, false, 0x91,
      'LCDC', 'LCD Display', 'LCD Control'),
  const MemRegInfo(MemReg.STAT, 0xFF41, false, 0,
      'STAT', 'LCD Display', 'LCDC Status'),
  const MemRegInfo(MemReg.SCY, 0xFF42, false, 0,
      'SCY', 'LCD Display', 'Scroll Y'),
  const MemRegInfo(MemReg.SCX, 0xFF43, false, 0,
      'SCX', 'LCD Display', 'Scroll X'),
  const MemRegInfo(MemReg.LY, 0xFF44, false, 0,
      'LY', 'LCD Display', 'LCDC Y-Coordinate'),
  const MemRegInfo(MemReg.LYC, 0xFF45, false, 0,
      'LYC', 'LCD Display', 'LY Compare'),
  const MemRegInfo(MemReg.DMA, 0xFF46, false, 0,
      'DMA', 'LCD Display', 'Direct Memory Access'),
  const MemRegInfo(MemReg.BGP, 0xFF47, false, 0xFC,
      'BGP', 'LCD Display', 'Background Palette data'),
  const MemRegInfo(MemReg.OBP0, 0xFF48, false, 0XFF,
      'OBP0', 'LCD Display', 'Object Palette 0 Data'),
  const MemRegInfo(MemReg.OBP1, 0xFF49, false, 0XFF,
      'OBP1', 'LCD Display', 'Object Palette 1 Data'),
  const MemRegInfo(MemReg.WY, 0xFF4A, false, 0,
      'WY', 'LCD Display', 'Window Y Position'),
  const MemRegInfo(MemReg.WX, 0xFF4B, false, 0,
      'WX', 'LCD Display', 'Window X Position minus 7'),
  const MemRegInfo(MemReg.KEY1, 0xFF4D, true, 0,
      'KEY1', 'Port/Mode', 'Prepare Speed Switch'),
  const MemRegInfo(MemReg.VBK, 0xFF4F, true, 0,
      'VBK', 'Bank Control', 'VRAM Bank'),
  const MemRegInfo(MemReg.HDMA1, 0xFF51, true, 0,
      'HDMA1', 'LCD Display', 'New DMA Source, High'),
  const MemRegInfo(MemReg.HDMA2, 0xFF52, true, 0,
      'HDMA2', 'LCD Display', 'New DMA Source, Low'),
  const MemRegInfo(MemReg.HDMA3, 0xFF53, true, 0,
      'HDMA3', 'LCD Display', 'New DMA Destination, High'),
  const MemRegInfo(MemReg.HDMA4, 0xFF54, true, 0,
      'HDMA4', 'LCD Display', 'New DMA Destination, Low'),
  const MemRegInfo(MemReg.HDMA5, 0xFF55, true, 0,
      'HDMA5', 'LCD Display', 'New DMA Length/Mode/Start'),
  const MemRegInfo(MemReg.RP, 0xFF56, true, 0,
      'RP', 'Port/Mode', 'Infrared Communications Port'),
  const MemRegInfo(MemReg.BGPI, 0xFF68, true, 0,
      'BGPI', 'LCD Display', 'Background Palette Index'),
  const MemRegInfo(MemReg.BGPD, 0xFF69, true, 0,
      'BGPD', 'LCD Display', 'Background Palette Data'),
  const MemRegInfo(MemReg.OBPI, 0xFF6A, true, 0,
      'OBPI', 'LCD Display', 'Sprite Palette Index'),
  const MemRegInfo(MemReg.OBPD, 0xFF6B, true, 0,
      'OBPD', 'LCD Display', 'Sprite Palette Data'),
  const MemRegInfo(MemReg.SVBK, 0xFF70, true, 0,
      'SVBK', 'Bank Control', 'WRAM Bank'),
  const MemRegInfo(MemReg.IE, 0xFFFF, false, 0,
      'IE', 'Interrupt', 'Interrupt Enable'),
];
