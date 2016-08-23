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
  BCPS,
  BCPD,
  OCPS,
  OCPD,
  SVBK,
  IE,
}

class MemRegInfo {
  int address;
  bool cgb;
  String name;
  String category;
  String description;

  MemRegInfo(
      this.address, this.cgb, this.name, this.category, this.description);
}

final memRegInfos =
  new List<MemRegInfo>.unmodifiable(_makeMemRegInfos());

_makeMemRegInfos()
{
  return [
    new MemRegInfo(0xFF00, false, 'P1', 'Port/Mode', 'Unknown'),
    new MemRegInfo(0xFF01, false, 'SB', 'Port/Mode', 'Serial Transfer Data Register'),
    new MemRegInfo(0xFF02, false, 'SC', 'Port/Mode', 'Serial Transfer - Control Register'),
    new MemRegInfo(0xFF04, false, 'DIV', 'Port/Mode', 'Divider Register'),
    new MemRegInfo(0xFF05, false, 'TIMA', 'Port/Mode', 'Timer Counter Register'),
    new MemRegInfo(0xFF06, false, 'TMA', 'Port/Mode', 'Timer Modulo Register'),
    new MemRegInfo(0xFF07, false, 'TAC', 'Port/Mode', 'Timer Control Register'),
    new MemRegInfo(0xFF0F, false, 'IF', 'Interrupt', 'Interrupt Type Register'),
    new MemRegInfo(0xFF40, false, 'LCDC', 'LCD Display', 'LCD Control register'),
    new MemRegInfo(0xFF41, false, 'STAT', 'LCD Display', 'LCDC Interrupts Status Register'),
    new MemRegInfo(0xFF42, false, 'SCY', 'LCD Display', 'Scroll Y Register'),
    new MemRegInfo(0xFF43, false, 'SCX', 'LCD Display', 'Scroll X Register'),
    new MemRegInfo(0xFF44, false, 'LY', 'LCD Display', 'Transferred Line Register'),
    new MemRegInfo(0xFF45, false, 'LYC', 'LCD Display', 'LY Mirror Register'),
    new MemRegInfo(0xFF46, false, 'DMA', 'LCD Display', 'Direct Memory Access Register'),
    new MemRegInfo(0xFF47, false, 'BGP', 'LCD Display', 'Background Palette Register'),
    new MemRegInfo(0xFF48, false, 'OBP0', 'LCD Display', 'Obj Color Palette Register 1'),
    new MemRegInfo(0xFF49, false, 'OBP1', 'LCD Display', 'Obj Color Palette Register 2'),
    new MemRegInfo(0xFF4A, false, 'WY', 'LCD Display', 'Window Position X'),
    new MemRegInfo(0xFF4B, false, 'WX', 'LCD Display', 'Window Position Y'),
    new MemRegInfo(0xFF4D, true, 'KEY1', 'Port/Mode', 'Unknown'),
    new MemRegInfo(0xFF4F, true, 'VBK', 'Bank Control', 'VRAM Bank Register'),
    new MemRegInfo(0xFF51, true, 'HDMA1', 'LCD Display', ''),
    new MemRegInfo(0xFF52, true, 'HDMA2', 'LCD Display', ''),
    new MemRegInfo(0xFF53, true, 'HDMA3', 'LCD Display', ''),
    new MemRegInfo(0xFF54, true, 'HDMA4', 'LCD Display', ''),
    new MemRegInfo(0xFF55, true, 'HDMA5', 'LCD Display', ''),
    new MemRegInfo(0xFF56, true, 'RP', 'Port/Mode', ''),
    new MemRegInfo(0xFF68, true, 'BCPS', 'LCD Display', ''),
    new MemRegInfo(0xFF69, true, 'BCPD', 'LCD Display', ''),
    new MemRegInfo(0xFF6A, true, 'OCPS', 'LCD Display', ''),
    new MemRegInfo(0xFF6B, true, 'OCPD', 'LCD Display', ''),
    new MemRegInfo(0xFF70, true, 'SVBK', 'Bank Control', ''),
    new MemRegInfo(0xFFFF, false, 'IE', 'Interrupt', 'Interrupt Enable Register'),
  ];
}

// class MemoryBank {
//   final _data = Uint8List()...;
//   int regValue(MRegister reg) {
//     return _data[
//       mappedRegisters[reg.index].address
//     ];
//   }
//   void regUpdate(MRegister reg, int value) {
//     _data[
//       mappedRegisters[reg.index].address
//     ] = value;
//   }
//   List<int> copyRegisters() {
//     return mappedRegisters.map((data){
//         });
//   }
// }
