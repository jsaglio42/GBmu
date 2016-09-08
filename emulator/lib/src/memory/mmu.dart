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

import "package:ft/src/misc.dart" as Ft;

import "package:emulator/src/enums.dart";
import 'package:emulator/src/constants.dart';

import "package:emulator/src/memory/data.dart" as Data;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;
import 'package:emulator/src/memory/memregisters.dart' as Memregisters;

class Mmu {

  final Cartridge.ACartridge _c;
  final _vr = new Data.VideoRam(new Uint8List(VIDEO_RAM_SIZE));
  final _wr = new Data.WorkingRam(new Uint8List(WORKING_RAM_SIZE));
  final _tr = new Data.TailRam(new Uint8List(TAIL_RAM_SIZE));

  Mmu(this._c);

  void init() {
    _vr.clear();
    _wr.clear();
    _tr.clear();
    this.pushMem8(0xFF05, 0x00);
    this.pushMem8(0xFF06, 0x00);
    this.pushMem8(0xFF07, 0x00);
    this.pushMem8(0xFF10, 0x80);
    this.pushMem8(0xFF11, 0xBF);
    this.pushMem8(0xFF12, 0xF3);
    this.pushMem8(0xFF14, 0xBF);
    this.pushMem8(0xFF16, 0x3F);
    this.pushMem8(0xFF17, 0x00);
    this.pushMem8(0xFF19, 0xBF);
    this.pushMem8(0xFF1A, 0x7F);
    this.pushMem8(0xFF1B, 0xFF);
    this.pushMem8(0xFF1C, 0x9F);
    this.pushMem8(0xFF1E, 0xBF);
    this.pushMem8(0xFF20, 0xFF);
    this.pushMem8(0xFF21, 0x00);
    this.pushMem8(0xFF22, 0x00);
    this.pushMem8(0xFF23, 0xBF);
    this.pushMem8(0xFF24, 0x77);
    this.pushMem8(0xFF25, 0xF3);
    this.pushMem8(0xFF26, 0xF1);
    this.pushMem8(0xFF40, 0x91);
    this.pushMem8(0xFF42, 0x00);
    this.pushMem8(0xFF43, 0x00);
    this.pushMem8(0xFF45, 0x00);
    this.pushMem8(0xFF47, 0xFC);
    this.pushMem8(0xFF48, 0xFF);
    this.pushMem8(0xFF49, 0xFF);
    this.pushMem8(0xFF4A, 0x00);
    this.pushMem8(0xFF4B, 0x00);
    this.pushMem8(0xFFFF, 0x00);
    return ;
  }

  /* Mem Reg API **************************************************************/

  int pullMemReg(MemReg reg) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    return this.pullMem8(addr);
  }

  void pushMemReg(MemReg reg, int byte) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    this.pushMem8(addr, byte);
  }

  /* Memory API ***************************************************************/
  /* 8 bits */

  int pullMem8(int memAddr)
  {
    assert(CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST);
    if ((CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      || (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST))
      return _c.pullMem8(memAddr);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      return _vr.pull8(memAddr - VIDEO_RAM_FIRST);
    else if (WORKING_RAM_FIRST <= memAddr && memAddr <= WORKING_RAM_LAST)
      return _wr.pull8(memAddr - WORKING_RAM_FIRST);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      return _tr.pull8(memAddr - TAIL_RAM_FIRST);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void pushMem8(int memAddr, int byte)
  {
    assert(byte & ~0xFF == 0);
    assert(CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST);
    if ((CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      || (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST))
      _c.pushMem8(memAddr, byte);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      _vr.push8(memAddr - VIDEO_RAM_FIRST, byte);
    else if (WORKING_RAM_FIRST <= memAddr && memAddr <= WORKING_RAM_LAST)
      _wr.push8(memAddr - WORKING_RAM_FIRST, byte);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      _tr.push8(memAddr - TAIL_RAM_FIRST, byte);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  /* 16 bits */

  int pullMem16(int memAddr)
  {
    assert(memAddr % 2 == 0);
    assert(CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST);
    if ((CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      || (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST))
      return _c.pullMem16(memAddr);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      return _vr.pull16(memAddr - VIDEO_RAM_FIRST);
    else if (WORKING_RAM_FIRST <= memAddr && memAddr <= WORKING_RAM_LAST)
      return _wr.pull16(memAddr - WORKING_RAM_FIRST);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      return _tr.pull16(memAddr - TAIL_RAM_FIRST);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void pushMem16(int memAddr, int word)
  {
    assert(memAddr % 2 == 0);
    assert(word & ~0xFFFF == 0);
    assert(CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST);
    if ((CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      || (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST))
      _c.pushMem16(memAddr, word);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      _vr.push16(memAddr - VIDEO_RAM_FIRST, word);
    else if (WORKING_RAM_FIRST <= memAddr && memAddr <= WORKING_RAM_LAST)
      _wr.push16(memAddr - WORKING_RAM_FIRST, word);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      _tr.push16(memAddr - TAIL_RAM_FIRST, word);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

}