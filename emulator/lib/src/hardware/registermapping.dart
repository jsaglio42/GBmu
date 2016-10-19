// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registermapping.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 23:03:22 by jsaglio          ###   ########.fr       //
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

const int addr_P1 = 0xFF00;
const int addr_SB = 0xFF01;
const int addr_SC = 0xFF02;
const int addr_DIV = 0xFF04;
const int addr_TIMA = 0xFF05;
const int addr_TMA = 0xFF06;
const int addr_TAC = 0xFF07;
const int addr_IF = 0xFF0F;
const int addr_LCDC = 0xFF40;
const int addr_STAT = 0xFF41;
const int addr_SCY = 0xFF42;
const int addr_SCX = 0xFF43;
const int addr_LY = 0xFF44;
const int addr_LYC = 0xFF45;
const int addr_DMA = 0xFF46;
const int addr_BGP = 0xFF47;
const int addr_OBP0 = 0xFF48;
const int addr_OBP1 = 0xFF49;
const int addr_WY = 0xFF4A;
const int addr_WX = 0xFF4B;
const int addr_KEY1 = 0xFF4D;
const int addr_VBK = 0xFF4F;
const int addr_HDMA1 = 0xFF51;
const int addr_HDMA2 = 0xFF52;
const int addr_HDMA3 = 0xFF53;
const int addr_HDMA4 = 0xFF54;
const int addr_HDMA5 = 0xFF55;
const int addr_RP = 0xFF56;
const int addr_BGPI = 0xFF68;
const int addr_BGPD = 0xFF69;
const int addr_OBPI = 0xFF6A;
const int addr_OBPD = 0xFF6B;
const int addr_SVBK = 0xFF70;
const int addr_IE = 0xFFFF;

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

const List<MemRegInfo> g_memRegInfos = const <MemRegInfo>[
  const MemRegInfo(MemReg.P1, addr_P1, false, 0,
      'P1', 'Port/Mode', 'Joypad'),
  const MemRegInfo(MemReg.SB, addr_SB, false, 0,
      'SB', 'Port/Mode', 'Serial Transfer Data'),
  const MemRegInfo(MemReg.SC, addr_SC, false, 0,
      'SC', 'Port/Mode', 'Serial Transfer Control'),
  const MemRegInfo(MemReg.DIV, addr_DIV, false, 0,
      'DIV', 'Timer', 'Divider Register'),
  const MemRegInfo(MemReg.TIMA, addr_TIMA, false, 0,
      'TIMA', 'Timer', 'Timer Counter'),
  const MemRegInfo(MemReg.TMA, addr_TMA, false, 0,
      'TMA', 'Timer', 'Timer Modulo'),
  const MemRegInfo(MemReg.TAC, addr_TAC, false, 0,
      'TAC', 'Timer', 'Timer Control'),
  const MemRegInfo(MemReg.IF, addr_IF, false, 0,
      'IF', 'Interrupt', 'Interrupt Flag'),
  const MemRegInfo(MemReg.LCDC, addr_LCDC, false, 0x91,
      'LCDC', 'LCD Display', 'LCD Control'),
  const MemRegInfo(MemReg.STAT, addr_STAT, false, 0,
      'STAT', 'LCD Display', 'LCDC Status'),
  const MemRegInfo(MemReg.SCY, addr_SCY, false, 0,
      'SCY', 'LCD Display', 'Scroll Y'),
  const MemRegInfo(MemReg.SCX, addr_SCX, false, 0,
      'SCX', 'LCD Display', 'Scroll X'),
  const MemRegInfo(MemReg.LY, addr_LY, false, 0,
      'LY', 'LCD Display', 'LCDC Y-Coordinate'),
  const MemRegInfo(MemReg.LYC, addr_LYC, false, 0,
      'LYC', 'LCD Display', 'LY Compare'),
  const MemRegInfo(MemReg.DMA, addr_DMA, false, 0,
      'DMA', 'LCD Display', 'Direct Memory Access'),
  const MemRegInfo(MemReg.BGP, addr_BGP, false, 0xFC,
      'BGP', 'LCD Display', 'Background Palette data'),
  const MemRegInfo(MemReg.OBP0, addr_OBP0, false, 0XFF,
      'OBP0', 'LCD Display', 'Object Palette 0 Data'),
  const MemRegInfo(MemReg.OBP1, addr_OBP1, false, 0XFF,
      'OBP1', 'LCD Display', 'Object Palette 1 Data'),
  const MemRegInfo(MemReg.WY, addr_WY, false, 0,
      'WY', 'LCD Display', 'Window Y Position'),
  const MemRegInfo(MemReg.WX, addr_WX, false, 0,
      'WX', 'LCD Display', 'Window X Position minus 7'),
  const MemRegInfo(MemReg.KEY1, addr_KEY1, true, 0,
      'KEY1', 'Port/Mode', 'Prepare Speed Switch'),
  const MemRegInfo(MemReg.VBK, addr_VBK, true, 0,
      'VBK', 'Bank Control', 'VRAM Bank'),
  const MemRegInfo(MemReg.HDMA1, addr_HDMA1, true, 0,
      'HDMA1', 'LCD Display', 'New DMA Source, High'),
  const MemRegInfo(MemReg.HDMA2, addr_HDMA2, true, 0,
      'HDMA2', 'LCD Display', 'New DMA Source, Low'),
  const MemRegInfo(MemReg.HDMA3, addr_HDMA3, true, 0,
      'HDMA3', 'LCD Display', 'New DMA Destination, High'),
  const MemRegInfo(MemReg.HDMA4, addr_HDMA4, true, 0,
      'HDMA4', 'LCD Display', 'New DMA Destination, Low'),
  const MemRegInfo(MemReg.HDMA5, addr_HDMA5, true, 0,
      'HDMA5', 'LCD Display', 'New DMA Length/Mode/Start'),
  const MemRegInfo(MemReg.RP, addr_RP, true, 0,
      'RP', 'Port/Mode', 'Infrared Communications Port'),
  const MemRegInfo(MemReg.BGPI, addr_BGPI, true, 0,
      'BGPI', 'LCD Display', 'Background Palette Index'),
  const MemRegInfo(MemReg.BGPD, addr_BGPD, true, 0,
      'BGPD', 'LCD Display', 'Background Palette Data'),
  const MemRegInfo(MemReg.OBPI, addr_OBPI, true, 0,
      'OBPI', 'LCD Display', 'Sprite Palette Index'),
  const MemRegInfo(MemReg.OBPD, addr_OBPD, true, 0,
      'OBPD', 'LCD Display', 'Sprite Palette Data'),
  const MemRegInfo(MemReg.SVBK, addr_SVBK, true, 0,
      'SVBK', 'Bank Control', 'WRAM Bank'),
  const MemRegInfo(MemReg.IE, addr_IE, false, 0,
      'IE', 'Interrupt', 'Interrupt Enable'),
];
