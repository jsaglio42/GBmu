// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mmu.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 16:07:17 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import 'package:emulator/src/constants.dart';
import 'package:emulator/src/globals.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/tailrammanager.dart" as Tailram;
import "package:emulator/src/mixins/videorammanager.dart" as Videoram;

abstract class Mmu
  implements Hardware.Hardware
  , Videoram.TrapAccessor 
  , Tailram.TrapAccessor {

  /* 8-bits *******************************************************************/
  int pull8(int memAddr)
  {
    assert(memAddr & ~0xFFFF == 0, 'push8: invalid memAddr $memAddr');
    if (memAddr <= CARTRIDGE_ROM_LAST)
      return this.c.pull8_Rom(memAddr);
    else if (memAddr <= VIDEO_RAM_LAST)
      return vr_pull8(memAddr);
    else if (memAddr <= CARTRIDGE_RAM_LAST)
      return this.c.pull8_Ram(memAddr);
    else if (memAddr <= INTERNAL_RAM_LAST)
      return this.internalram.pull8(memAddr, this.memr.SVBK);
    else if (memAddr <= ECHO_RAM_LAST)
      return this.internalram.pull8(memAddr - ECHO_RAM_OFFSET, this.memr.SVBK);
    else if (memAddr <= OAM_LAST)
      return this.oam.pull8(memAddr);
    else if (memAddr <= FORBIDDEN_LAST)
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
    else if (memAddr <= TAIL_RAM_LAST)
      return this.tr_pull8(memAddr);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void push8(int memAddr, int v)
  {
    assert(v & ~0xFF == 0, 'push8: invalid value $v');
    assert(memAddr & ~0xFFFF == 0, 'push8: invalid memAddr $memAddr');
    if (memAddr <= CARTRIDGE_ROM_LAST)
      this.c.push8_Rom(memAddr, v);
    else if (memAddr <= VIDEO_RAM_LAST)
      this.vr_push8(memAddr, v);
    else if (memAddr <= CARTRIDGE_RAM_LAST)
      this.c.push8_Ram(memAddr, v);
    else if (memAddr <= INTERNAL_RAM_LAST)
      this.internalram.push8(memAddr, this.memr.SVBK, v);
    else if (memAddr <= ECHO_RAM_LAST)
      this.internalram.push8(memAddr - ECHO_RAM_OFFSET, this.memr.SVBK, v);
    else if (memAddr <= OAM_LAST)
      this.oam.push8(memAddr, v);
    else if (memAddr <= FORBIDDEN_LAST)
      return ;
    else if (memAddr <= TAIL_RAM_LAST)
      this.tr_push8(memAddr, v);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  /* 16-bits *******************************************************************/
  int pull16(int memAddr){
    final int l = this.pull8(memAddr);
    final int h = this.pull8(memAddr + 1);
    return (l | (h << 8));
  }

  void push16(int memAddr, int v){
    assert(v & ~0xFFFF == 0, 'push16: invalid value $v');
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

  void pushOnStack16(int v) {
    this.push16(this.cpur.SP - 2, v);
    this.cpur.SP -= 2;
    return ;
  }

}
