// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mmu.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 17:04:16 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:emulator/enums.dart";
import 'package:emulator/constants.dart';
import "package:emulator/src/memory/imbc.dart" as Imbc;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;

class Mmu {

  final Imbc.IMbc _mbc;
  final Uint8List _wRam = new Uint8List(WORKING_RAM_SIZE);
  final Uint8List _vRam = new Uint8List(VIDEO_RAM_SIZE);
  final Uint8List _tailRam = new Uint8List(TAIL_RAM_SIZE);

  Mmu(this._mbc);

  int pullMemReg(MemReg reg) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    return this.pullMem8(addr);
  }

  /** memAddr [0, 0xff], byte [0, 0xff] */
  void pushMemReg(MemReg reg, int byte) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    this.pushMem8(addr, byte);
  }

  /** memAddr [0, 0xff] */
  int pullMem8(int memAddr) {
    assert(memAddr <= 0xFFFF && memAddr >= 0
        , "Mmu.pullMem($memAddr)\tout of range");
    if (memAddr > TAIL_RAM_LAST)
      throw new Exception();
    else if (memAddr >= TAIL_RAM_BEGIN)
      return _tailRam[memAddr - TAIL_RAM_BEGIN];
    else // TODO: pullMem
      return 0x42;
  }

  /** memAddr [0, 0xff], byte [0, 0xff] */
  void pushMem8(int memAddr, int byte) {
    if (memAddr > TAIL_RAM_LAST)
      throw new Exception("Mmu.pushMem($memAddr, $byte)\tout of range");
    else if (memAddr >= TAIL_RAM_BEGIN)
      _tailRam[memAddr - TAIL_RAM_BEGIN] = byte;
    // TODO: pullMem
    return ;
  }

  int pullMem16(int memAddr)  //TODO: are word addresses aligned ?
  {return 12;}
  void pushMem16(int memAddr, int word)
  {}

}

// void writeByte(int addr, int value)
// {
//   if (0x0000 <= addr && addr < 0x4000)
//     doNothing();
//   if (0x4000 <= addr && addr < 0x8000)
//     doNothing();
//   if (0x8000 <= addr && addr < 0xA000)
//     doNothing();
//   if (0xA000 <= addr && addr < 0xC000)
//     doNothing();
//   if (0xC000 <= addr && addr < 0xD000)
//     doNothing();
//   if (0xD000 <= addr && addr < 0xE000)
//     doNothing();
//   if (0xE000 <= addr && addr < 0xFE00)
//     doNothing();
//   if (0xFE00 <= addr && addr < 0xFEA0)
//     doNothing();
//   if (0xFEA0 <= addr && addr < 0xFF00)
//     doNothing();
//   if (0xFF00 <= addr && addr < 0xFF80)
//     doNothing();
//   if (0xFF80 <= addr && addr < 0xFFFF)
//     doNothing();
//     else if (addr == 0xFFFF)
//       doNothing();
//   else
//     print ("MMU: writeByte: address not valid");
// }
