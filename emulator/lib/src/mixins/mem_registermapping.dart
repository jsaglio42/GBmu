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

import "package:emulator/src/hardware/hardware.dart" as Hardware;

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

  MemReg  reg;
  int     address;
  bool    cgb;
  String  name;
  String  category;
  String  description;

  MemRegInfo(this.reg
    , this.address
    , this.cgb
    , this.name
    , this.category
    , this.description);

}

/* Global *********************************************************************/

final memRegInfos =
  new List<MemRegInfo>.unmodifiable([
    new MemRegInfo(MemReg.P1, 0xFF00, false, 'P1', 'Port/Mode', 'Joypad'),
    new MemRegInfo(MemReg.SB, 0xFF01, false, 'SB', 'Port/Mode', 'Serial Transfer Data'),
    new MemRegInfo(MemReg.SC, 0xFF02, false, 'SC', 'Port/Mode', 'Serial Transfer Control'),
    new MemRegInfo(MemReg.DIV, 0xFF04, false, 'DIV', 'Timer', 'Divider Register'),
    new MemRegInfo(MemReg.TIMA, 0xFF05, false, 'TIMA', 'Timer', 'Timer Counter'),
    new MemRegInfo(MemReg.TMA, 0xFF06, false, 'TMA', 'Timer', 'Timer Modulo'),
    new MemRegInfo(MemReg.TAC, 0xFF07, false, 'TAC', 'Timer', 'Timer Control'),
    new MemRegInfo(MemReg.IF, 0xFF0F, false, 'IF', 'Interrupt', 'Interrupt Flag'),
    new MemRegInfo(MemReg.LCDC, 0xFF40, false, 'LCDC', 'LCD Display', 'LCD Control'),
    new MemRegInfo(MemReg.STAT, 0xFF41, false, 'STAT', 'LCD Display', 'LCDC Status'),
    new MemRegInfo(MemReg.SCY, 0xFF42, false, 'SCY', 'LCD Display', 'Scroll Y'),
    new MemRegInfo(MemReg.SCX, 0xFF43, false, 'SCX', 'LCD Display', 'Scroll X'),
    new MemRegInfo(MemReg.LY, 0xFF44, false, 'LY', 'LCD Display', 'LCDC Y-Coordinate'),
    new MemRegInfo(MemReg.LYC, 0xFF45, false, 'LYC', 'LCD Display', 'LY Compare'),
    new MemRegInfo(MemReg.DMA, 0xFF46, false, 'DMA', 'LCD Display', 'Direct Memory Access'),
    new MemRegInfo(MemReg.BGP, 0xFF47, false, 'BGP', 'LCD Display', 'Background Palette data'),
    new MemRegInfo(MemReg.OBP0, 0xFF48, false, 'OBP0', 'LCD Display', 'Object Palette 0 Data'),
    new MemRegInfo(MemReg.OBP1, 0xFF49, false, 'OBP1', 'LCD Display', 'Object Palette 1 Data'),
    new MemRegInfo(MemReg.WY, 0xFF4A, false, 'WY', 'LCD Display', 'Window Y Position'),
    new MemRegInfo(MemReg.WX, 0xFF4B, false, 'WX', 'LCD Display', 'Window X Position minus 7'),
    new MemRegInfo(MemReg.KEY1, 0xFF4D, true, 'KEY1', 'Port/Mode', 'Prepare Speed Switch'),
    new MemRegInfo(MemReg.VBK, 0xFF4F, true, 'VBK', 'Bank Control', 'VRAM Bank'),
    new MemRegInfo(MemReg.HDMA1, 0xFF51, true, 'HDMA1', 'LCD Display', 'New DMA Source, High'),
    new MemRegInfo(MemReg.HDMA2, 0xFF52, true, 'HDMA2', 'LCD Display', 'New DMA Source, Low'),
    new MemRegInfo(MemReg.HDMA3, 0xFF53, true, 'HDMA3', 'LCD Display', 'New DMA Destination, High'),
    new MemRegInfo(MemReg.HDMA4, 0xFF54, true, 'HDMA4', 'LCD Display', 'New DMA Destination, Low'),
    new MemRegInfo(MemReg.HDMA5, 0xFF55, true, 'HDMA5', 'LCD Display', 'New DMA Length/Mode/Start'),
    new MemRegInfo(MemReg.RP, 0xFF56, true, 'RP', 'Port/Mode', 'Infrared Communications Port'),
    new MemRegInfo(MemReg.BGPI, 0xFF68, true, 'BGPI', 'LCD Display', 'Background Palette Index'),
    new MemRegInfo(MemReg.BGPD, 0xFF69, true, 'BGPD', 'LCD Display', 'Background Palette Data'),
    new MemRegInfo(MemReg.OBPI, 0xFF6A, true, 'OBPI', 'LCD Display', 'Sprite Palette Index'),
    new MemRegInfo(MemReg.OBPD, 0xFF6B, true, 'OBPD', 'LCD Display', 'Sprite Palette Data'),
    new MemRegInfo(MemReg.SVBK, 0xFF70, true, 'SVBK', 'Bank Control', 'WRAM Bank'),
    new MemRegInfo(MemReg.IE, 0xFFFF, false, 'IE', 'Interrupt', 'Interrupt Enable'),
  ]);
