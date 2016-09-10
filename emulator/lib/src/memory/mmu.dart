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

import "package:emulator/src/memory/data.dart" as Data;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;

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
    this.pushMem(0xFF05, 0x00, DataType.BYTE);
    this.pushMem(0xFF06, 0x00, DataType.BYTE);
    this.pushMem(0xFF07, 0x00, DataType.BYTE);
    this.pushMem(0xFF10, 0x80, DataType.BYTE);
    this.pushMem(0xFF11, 0xBF, DataType.BYTE);
    this.pushMem(0xFF12, 0xF3, DataType.BYTE);
    this.pushMem(0xFF14, 0xBF, DataType.BYTE);
    this.pushMem(0xFF16, 0x3F, DataType.BYTE);
    this.pushMem(0xFF17, 0x00, DataType.BYTE);
    this.pushMem(0xFF19, 0xBF, DataType.BYTE);
    this.pushMem(0xFF1A, 0x7F, DataType.BYTE);
    this.pushMem(0xFF1B, 0xFF, DataType.BYTE);
    this.pushMem(0xFF1C, 0x9F, DataType.BYTE);
    this.pushMem(0xFF1E, 0xBF, DataType.BYTE);
    this.pushMem(0xFF20, 0xFF, DataType.BYTE);
    this.pushMem(0xFF21, 0x00, DataType.BYTE);
    this.pushMem(0xFF22, 0x00, DataType.BYTE);
    this.pushMem(0xFF23, 0xBF, DataType.BYTE);
    this.pushMem(0xFF24, 0x77, DataType.BYTE);
    this.pushMem(0xFF25, 0xF3, DataType.BYTE);
    this.pushMem(0xFF26, 0xF1, DataType.BYTE);
    this.pushMem(0xFF40, 0x91, DataType.BYTE);
    this.pushMem(0xFF42, 0x00, DataType.BYTE);
    this.pushMem(0xFF43, 0x00, DataType.BYTE);
    this.pushMem(0xFF45, 0x00, DataType.BYTE);
    this.pushMem(0xFF47, 0xFC, DataType.BYTE);
    this.pushMem(0xFF48, 0xFF, DataType.BYTE);
    this.pushMem(0xFF49, 0xFF, DataType.BYTE);
    this.pushMem(0xFF4A, 0x00, DataType.BYTE);
    this.pushMem(0xFF4B, 0x00, DataType.BYTE);
    this.pushMem(0xFFFF, 0x00, DataType.BYTE);
    return ;
  }

  /* Mem Reg API **************************************************************/

  int pullMemReg(MemReg reg) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    return this.pullMem(addr, DataType.BYTE);
  }

  void pushMemReg(MemReg reg, int byte) {
    final addr = Memregisters.memRegInfos[reg.index].address;
    this.pushMem(addr, byte, DataType.BYTE);
  }

  /* Memory API ***************************************************************/

  int pullMem(int memAddr, DataType t)
  {
    assert(CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST);
    if (CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      return _c.pullRom(memAddr, t);
    else if (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST)
      return _c.pullRam(memAddr, t);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      return _vr.pull(memAddr - VIDEO_RAM_FIRST, t);
    else if (WORKING_RAM_FIRST <= memAddr && memAddr <= WORKING_RAM_LAST)
      return _wr.pull(memAddr - WORKING_RAM_FIRST, t);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      return _tr.pull(memAddr - TAIL_RAM_FIRST, t);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void pushMem(int memAddr, int v, DataType t)
  {
    assert(CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST);
    if (CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      _c.pushRom(memAddr, v, t);
    else if (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST)
      _c.pushRam(memAddr, v, t);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      _vr.push(memAddr - VIDEO_RAM_FIRST, t);
    else if (WORKING_RAM_FIRST <= memAddr && memAddr <= WORKING_RAM_LAST)
      _wr.push(memAddr - WORKING_RAM_FIRST, v, t);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      _tr.push(memAddr - TAIL_RAM_FIRST, v, t);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

}