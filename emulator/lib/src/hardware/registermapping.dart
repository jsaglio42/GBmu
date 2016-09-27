// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registermapping.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/26 19:59:32 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * Byte Registers Mapped in Memory
 * Page2 : https://docs.google.com/spreadsheets/d/1ffcl5dd_Q12Eqf9Zlrho_ghUZO5lT-gIpRi392XHU10
 * Sorted by address
 */

/* Enums **********************************************************************/

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

/* Mem Registers Info *********************************************************/

class MemRegInfo {

  final MemReg reg;
  final int address;
  final bool cgb;
  final String name;
  final String category;
  final String description;

  const MemRegInfo(this.reg
    , this.address
    , this.cgb
    , this.name
    , this.category
    , this.description);

}

/* Global *********************************************************************/
final Map<int, MemRegInfo> g_memRegInfosByAddress = new Map<int, MemRegInfo>
  .fromIterable(g_memRegInfos
    , key: (rinfo) => rinfo.address
    , value: (rinfo) => rinfo);

const List<MemRegInfo> g_memRegInfos = const <MemRegInfo>[
    const MemRegInfo(MemReg.P1, 0xFF00, false, 'P1', 'Port/Mode', 'Joypad'),
    const MemRegInfo(MemReg.SB, 0xFF01, false, 'SB', 'Port/Mode', 'Serial Transfer Data'),
    const MemRegInfo(MemReg.SC, 0xFF02, false, 'SC', 'Port/Mode', 'Serial Transfer Control'),
    const MemRegInfo(MemReg.DIV, 0xFF04, false, 'DIV', 'Timer', 'Divider Register'),
    const MemRegInfo(MemReg.TIMA, 0xFF05, false, 'TIMA', 'Timer', 'Timer Counter'),
    const MemRegInfo(MemReg.TMA, 0xFF06, false, 'TMA', 'Timer', 'Timer Modulo'),
    const MemRegInfo(MemReg.TAC, 0xFF07, false, 'TAC', 'Timer', 'Timer Control'),
    const MemRegInfo(MemReg.IF, 0xFF0F, false, 'IF', 'Interrupt', 'Interrupt Flag'),
    const MemRegInfo(MemReg.LCDC, 0xFF40, false, 'LCDC', 'LCD Display', 'LCD Control'),
    const MemRegInfo(MemReg.STAT, 0xFF41, false, 'STAT', 'LCD Display', 'LCDC Status'),
    const MemRegInfo(MemReg.SCY, 0xFF42, false, 'SCY', 'LCD Display', 'Scroll Y'),
    const MemRegInfo(MemReg.SCX, 0xFF43, false, 'SCX', 'LCD Display', 'Scroll X'),
    const MemRegInfo(MemReg.LY, 0xFF44, false, 'LY', 'LCD Display', 'LCDC Y-Coordinate'),
    const MemRegInfo(MemReg.LYC, 0xFF45, false, 'LYC', 'LCD Display', 'LY Compare'),
    const MemRegInfo(MemReg.DMA, 0xFF46, false, 'DMA', 'LCD Display', 'Direct Memory Access'),
    const MemRegInfo(MemReg.BGP, 0xFF47, false, 'BGP', 'LCD Display', 'Background Palette data'),
    const MemRegInfo(MemReg.OBP0, 0xFF48, false, 'OBP0', 'LCD Display', 'Object Palette 0 Data'),
    const MemRegInfo(MemReg.OBP1, 0xFF49, false, 'OBP1', 'LCD Display', 'Object Palette 1 Data'),
    const MemRegInfo(MemReg.WY, 0xFF4A, false, 'WY', 'LCD Display', 'Window Y Position'),
    const MemRegInfo(MemReg.WX, 0xFF4B, false, 'WX', 'LCD Display', 'Window X Position minus 7'),
    const MemRegInfo(MemReg.KEY1, 0xFF4D, true, 'KEY1', 'Port/Mode', 'Prepare Speed Switch'),
    const MemRegInfo(MemReg.VBK, 0xFF4F, true, 'VBK', 'Bank Control', 'VRAM Bank'),
    const MemRegInfo(MemReg.HDMA1, 0xFF51, true, 'HDMA1', 'LCD Display', 'New DMA Source, High'),
    const MemRegInfo(MemReg.HDMA2, 0xFF52, true, 'HDMA2', 'LCD Display', 'New DMA Source, Low'),
    const MemRegInfo(MemReg.HDMA3, 0xFF53, true, 'HDMA3', 'LCD Display', 'New DMA Destination, High'),
    const MemRegInfo(MemReg.HDMA4, 0xFF54, true, 'HDMA4', 'LCD Display', 'New DMA Destination, Low'),
    const MemRegInfo(MemReg.HDMA5, 0xFF55, true, 'HDMA5', 'LCD Display', 'New DMA Length/Mode/Start'),
    const MemRegInfo(MemReg.RP, 0xFF56, true, 'RP', 'Port/Mode', 'Infrared Communications Port'),
    const MemRegInfo(MemReg.BGPI, 0xFF68, true, 'BGPI', 'LCD Display', 'Background Palette Index'),
    const MemRegInfo(MemReg.BGPD, 0xFF69, true, 'BGPD', 'LCD Display', 'Background Palette Data'),
    const MemRegInfo(MemReg.OBPI, 0xFF6A, true, 'OBPI', 'LCD Display', 'Sprite Palette Index'),
    const MemRegInfo(MemReg.OBPD, 0xFF6B, true, 'OBPD', 'LCD Display', 'Sprite Palette Data'),
    const MemRegInfo(MemReg.SVBK, 0xFF70, true, 'SVBK', 'Bank Control', 'WRAM Bank'),
    const MemRegInfo(MemReg.IE, 0xFFFF, false, 'IE', 'Interrupt', 'Interrupt Enable')
  ];
