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

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import 'package:emulator/src/constants.dart';

import "package:emulator/src/memory/cartridge.dart" as Cartridge;
import "package:emulator/src/memory/data.dart" as Data;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;

bool _isInRange(int i, int s, int e) => (i >= s && i <= e);

class Mmu
  implements GameBoy.Hardware {

  /* Mem Reg API **************************************************************/
  /* Safe */
  int pullMemReg(MemReg reg) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    return this.tailRam.pull8(addr);
  }

  void pushMemReg(MemReg reg, int byte) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    this.tailRam.push8(addr, byte);
    return ;
  }

  /* Unsafe */
  int pullMemReg_unsafe(MemReg reg) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    return this.tailRam.pull8_unsafe(addr);
  }

  void pushMemReg_unsafe(MemReg reg, int byte) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    this.tailRam.push8_unsafe(addr, byte);
    return ;
  }

  /* Memory API ***************************************************************/
  /* 8-bits */
  int pull8(int memAddr)
  {
    if (_isInRange(memAddr, CARTRIDGE_ROM_FIRST, CARTRIDGE_ROM_LAST))
      return this.c.pull8_Rom(memAddr);
    else if (_isInRange(memAddr, CARTRIDGE_RAM_FIRST, CARTRIDGE_RAM_LAST))
      return this.c.pull8_Ram(memAddr);
    else if (_isInRange(memAddr, VIDEO_RAM_FIRST, VIDEO_RAM_LAST))
      return this.videoRam.pull8(memAddr);
    else if (_isInRange(memAddr, INTERNAL_RAM_FIRST, INTERNAL_RAM_LAST))
      return this.workingRam.pull8(memAddr);
    else if (_isInRange(memAddr, TAIL_RAM_FIRST, TAIL_RAM_LAST))
      return this.trailingRam.pull8(memAddr);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void push8(int memAddr, int v)
  {
    if (CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      this.c.push8_Rom(memAddr, v);
    else if (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST)
      this.c.push8_Ram(memAddr, v);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      this.videoRam.push8(memAddr - VIDEO_RAM_FIRST);
    else if (INTERNAL_RAM_FIRST <= memAddr && memAddr <= INTERNAL_RAM_LAST)
      this.workingRam.push8(memAddr - INTERNAL_RAM_FIRST, v);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      this.trailingRam.push8(memAddr, v);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  /* 16-bits */
  int pull16(int memAddr){
    final int l = this.pull8(memAddr);
    final int h = this.pull8(memAddr + 1);
    return (l | (h << 8));
  }

  void push16(int memAddr, int v){
    assert(v & ~0xFFFF == 0);
    this.push8(memAddr, (v & 0xFF));
    this.push8(memAddr + 1, (v >> 8));
    return ;
  }

  /* Misc */
  List<int> pullMemoryList(int addr, int len) {
    final lst = <int>[];
    for (int i = 0; i < len; ++i) {
      int data;
      try { data = this.pull8(addr + i); }
      catch (e) { data = null; }
      lst.add(data);
    }
    return lst;
  }

  void pushOnStack16(int val) {
    assert(val & 0xFFFF == 0);
    this.push16(this.cpur.SP - 2, val);
    this.cpur.SP -= 2;
    return ;
  }

}



