// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 17:00:09 by ngoguey          ###   ########.fr       //
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
  OCPD,
  SVBK,
  IE,
}

/* MemRegInfo *****************************************************************/

class MemRegInfo {

  int     address;
  bool    cgb;
  String  name;
  String  category;
  String  description;

  MemRegInfo(
      this.address, this.cgb, this.name, this.category, this.description);
}

/* Global *********************************************************************/

final memRegInfos =
  new List<MemRegInfo>.unmodifiable([
    new MemRegInfo(0xFF00, false, 'P1', 'Port/Mode', 'Joypad'),
    new MemRegInfo(0xFF01, false, 'SB', 'Port/Mode', 'Serial Transfer Data'),
    new MemRegInfo(0xFF02, false, 'SC', 'Port/Mode', 'Serial Transfer Control'),
    new MemRegInfo(0xFF04, false, 'DIV', 'Timer', 'Divider Register'),
    new MemRegInfo(0xFF05, false, 'TIMA', 'Timer', 'Timer Counter'),
    new MemRegInfo(0xFF06, false, 'TMA', 'Timer', 'Timer Modulo'),
    new MemRegInfo(0xFF07, false, 'TAC', 'Timer', 'Timer Control'),
    new MemRegInfo(0xFF0F, false, 'IF', 'Interrupt', 'Interrupt Flag'),
    new MemRegInfo(0xFF40, false, 'LCDC', 'LCD Display', 'LCD Control'),
    new MemRegInfo(0xFF41, false, 'STAT', 'LCD Display', 'LCDC Status'),
    new MemRegInfo(0xFF42, false, 'SCY', 'LCD Display', 'Scroll Y'),
    new MemRegInfo(0xFF43, false, 'SCX', 'LCD Display', 'Scroll X'),
    new MemRegInfo(0xFF44, false, 'LY', 'LCD Display', 'LCDC Y-Coordinate'),
    new MemRegInfo(0xFF45, false, 'LYC', 'LCD Display', 'LY Compare'),
    new MemRegInfo(0xFF46, false, 'DMA', 'LCD Display', 'Direct Memory Access'),
    new MemRegInfo(0xFF47, false, 'BGP', 'LCD Display', 'Background Palette data'),
    new MemRegInfo(0xFF48, false, 'OBP0', 'LCD Display', 'Object Palette 0 Data'),
    new MemRegInfo(0xFF49, false, 'OBP1', 'LCD Display', 'Object Palette 1 Data'),
    new MemRegInfo(0xFF4A, false, 'WY', 'LCD Display', 'Window Y Position'),
    new MemRegInfo(0xFF4B, false, 'WX', 'LCD Display', 'Window X Position minus 7'),
    new MemRegInfo(0xFF4D, true, 'KEY1', 'Port/Mode', 'Prepare Speed Switch'),
    new MemRegInfo(0xFF4F, true, 'VBK', 'Bank Control', 'VRAM Bank'),
    new MemRegInfo(0xFF51, true, 'HDMA1', 'LCD Display', 'New DMA Source, High'),
    new MemRegInfo(0xFF52, true, 'HDMA2', 'LCD Display', 'New DMA Source, Low'),
    new MemRegInfo(0xFF53, true, 'HDMA3', 'LCD Display', 'New DMA Destination, High'),
    new MemRegInfo(0xFF54, true, 'HDMA4', 'LCD Display', 'New DMA Destination, Low'),
    new MemRegInfo(0xFF55, true, 'HDMA5', 'LCD Display', 'New DMA Length/Mode/Start'),
    new MemRegInfo(0xFF56, true, 'RP', 'Port/Mode', 'Infrared Communications Port'),
    new MemRegInfo(0xFF68, true, 'BGPI', 'LCD Display', 'Background Palette Index'),
    new MemRegInfo(0xFF69, true, 'BGPD', 'LCD Display', 'Background Palette Data'),
    new MemRegInfo(0xFF6A, true, 'OBPI', 'LCD Display', 'Sprite Palette Index'),
    new MemRegInfo(0xFF6B, true, 'OBPD', 'LCD Display', 'Sprite Palette Data'),
    new MemRegInfo(0xFF70, true, 'SVBK', 'Bank Control', 'WRAM Bank'),
    new MemRegInfo(0xFFFF, false, 'IE', 'Interrupt', 'Interrupt Enable'),
  ]);
