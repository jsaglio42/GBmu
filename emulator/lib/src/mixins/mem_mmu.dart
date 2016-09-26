// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_mmu.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/26 20:35:53 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import 'package:emulator/src/constants.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/mem_registermapping.dart" as Memregisters;

bool _isInRange(int i, int f, int l) => (i >= f && i <= l);

abstract class Mmu
  implements Hardware.Hardware {

  /* 8-bits *******************************************************************/
  int pull8(int memAddr)
  {
    if (_isInRange(memAddr, CARTRIDGE_ROM_FIRST, CARTRIDGE_ROM_LAST))
      return this.c.pull8_Rom(memAddr);
    else if (_isInRange(memAddr, CARTRIDGE_RAM_FIRST, CARTRIDGE_RAM_LAST))
      return this.c.pull8_Ram(memAddr);
    else if (_isInRange(memAddr, VIDEO_RAM_FIRST, VIDEO_RAM_LAST))
      return this.videoRam.pull8_unsafe(memAddr);
    else if (_isInRange(memAddr, INTERNAL_RAM_FIRST, INTERNAL_RAM_LAST))
      return this.internalRam.pull8_unsafe(memAddr);
    else if (_isInRange(memAddr, TAIL_RAM_FIRST, TAIL_RAM_LAST))
      return _pull8_IO(memAddr);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void push8(int memAddr, int v)
  {
    if (_isInRange(memAddr, CARTRIDGE_ROM_FIRST, CARTRIDGE_ROM_LAST))
      this.c.push8_Rom(memAddr, v);
    else if (_isInRange(memAddr, CARTRIDGE_RAM_FIRST, CARTRIDGE_RAM_LAST))
      this.c.push8_Ram(memAddr, v);
    else if (_isInRange(memAddr, VIDEO_RAM_FIRST, VIDEO_RAM_LAST))
      this.videoRam.push8_unsafe(memAddr, v);
    else if (_isInRange(memAddr, INTERNAL_RAM_FIRST, INTERNAL_RAM_LAST))
      this.internalRam.push8_unsafe(memAddr, v);
    else if (_isInRange(memAddr, TAIL_RAM_FIRST, TAIL_RAM_LAST))
      _push8_IO(memAddr, v);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
    return ;
  }

  /* 16-bits *******************************************************************/
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

  /* Misc *********************************************************************/
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

  int pullMemReg(Memregisters.MemReg reg) {
    final rinfo = Memregisters.memRegInfos[reg.index];
    return _pullMemReg(rinfo);
  }

  void pushOnStack16(int v) {
    this.push16(this.cpur.SP - 2, v);
    this.cpur.SP -= 2;
    return ;
  }


  /* IO trapping routine ******************************************************/
  /* pull */
  int _pull8_IO(int memAddr) {
    for (Memregisters.MemRegInfo rinfo in Memregisters.memRegInfos) {
      if (rinfo.address == memAddr) {
        return _pullMemReg(rinfo);
      }
    }
    return this.tailRam.pull8_unsafe(memAddr);
  }

  int _pullMemReg(Memregisters.MemRegInfo rinfo) {
    switch (rinfo.reg) {
      default : break ;
    }
    return this.tailRam.pull8_unsafe(rinfo.address);
  }

  /* push */
  void _push8_IO(int memAddr, int v) {
    for (Memregisters.MemRegInfo rinfo in Memregisters.memRegInfos) {
      if (rinfo.address == memAddr) {
        _pushMemReg(rinfo, v);
        return ;
      }
    }
    return this.tailRam.push8_unsafe(memAddr, v);
  }

  void _pushMemReg(Memregisters.MemRegInfo rinfo, int v) {
    switch (rinfo.reg) {
      default :
        this.tailRam.push8_unsafe(rinfo.address, v);
        return ;
    }
  }

}
