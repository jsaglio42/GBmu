// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mmu.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:34:37 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import 'package:emulator/src/constants.dart';
import 'package:emulator/src/globals.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/hardware/registermapping.dart" as Memregisters;

import "package:emulator/src/mixins/tailrammanager.dart" as Tailram;

abstract class Mmu
  implements Hardware.Hardware
  , Tailram.TrapAccessor {

  /* 8-bits *******************************************************************/
  int pull8(int memAddr)
  {
    if (CARTRIDGE_ROM_FIRST <= memAddr && memAddr <= CARTRIDGE_ROM_LAST)
      return this.c.pull8_Rom(memAddr);
    else if (CARTRIDGE_RAM_FIRST <= memAddr && memAddr <= CARTRIDGE_RAM_LAST)
      return this.c.pull8_Ram(memAddr);
    else if (VIDEO_RAM_FIRST <= memAddr && memAddr <= VIDEO_RAM_LAST)
      return this.videoRam.pull8(memAddr);
    else if (INTERNAL_RAM_FIRST <= memAddr && memAddr <= INTERNAL_RAM_LAST)
      return this.internalRam.pull8(memAddr);
    else if (ECHO_RAM_FIRST <= memAddr && memAddr <= ECHO_RAM_LAST)
      return this.internalRam.pull8(memAddr - ECHO_RAM_OFFSET);
    else if (OAM_FIRST <= memAddr && memAddr <= OAM_LAST)
      return this.oam.pull8(memAddr);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      return this.tr_pull8(memAddr);
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
      this.videoRam.push8(memAddr, v);
    else if (INTERNAL_RAM_FIRST <= memAddr && memAddr <= INTERNAL_RAM_LAST)
      this.internalRam.push8(memAddr, v);
    else if (ECHO_RAM_FIRST <= memAddr && memAddr <= ECHO_RAM_LAST)
      this.internalRam.push8(memAddr - ECHO_RAM_OFFSET, v);
    else if (OAM_FIRST <= memAddr && memAddr <= OAM_LAST)
      this.oam.push8(memAddr, v);
    else if (TAIL_RAM_FIRST <= memAddr && memAddr <= TAIL_RAM_LAST)
      this.tr_push8(memAddr, v);
    // else
    //   throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
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

  void pushOnStack16(int v) {
    this.push16(this.cpur.SP - 2, v);
    this.cpur.SP -= 2;
    return ;
  }

}
