// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mmu.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 14:53:50 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import "imbc.dart";
import 'mem_registers.dart';

class Mmu {

  final IMbc      _mbc;
  final Uint8List _wRam;
  final Uint8List _vRam;
  final Uint8List _tailRam;

  Mmu(this._mbc);

  int     pullMemReg(MemReg reg) {
    final addr = memRegInfos[reg.index].address;
    return readByte(addr);
  }

  void    pushMemReg(MemReg reg, int value) {
    final addr = memRegInfos[reg.index].address;
    writeByte(addr, value);
  }

  int pullMem(int memAddr) {
    if (true)
      return _mbc.pullMem(memAddr);
    // else if (...)
    //   ...;
    // else
    //   ...;
  }
  void pushMem(int memAddr, int v) {}

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
