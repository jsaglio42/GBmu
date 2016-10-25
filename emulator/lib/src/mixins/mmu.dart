// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mmu.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 15:26:41 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import "package:emulator/src/enums.dart";
import 'package:emulator/src/constants.dart';
import 'package:emulator/src/globals.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/trapaccessors.dart" as Trap;

abstract class Mmu
  implements Hardware.Hardware
  , Trap.TVideoRam
  , Trap.TInternalRam
  , Trap.TTailRam {

  /* 8-bits *******************************************************************/
  int pull8(int memAddr)
  {
    assert(memAddr & ~0xFFFF == 0, 'push8: invalid memAddr $memAddr');
    if (memAddr <= CARTRIDGE_ROM_LAST)
      return this.c.pull8_Rom(memAddr & 0x7FFF);
    else if (memAddr <= VIDEO_RAM_LAST)
      return vr_pull8(memAddr & 0x1FFF);
    else if (memAddr <= CARTRIDGE_RAM_LAST)
      return this.c.pull8_Ram(memAddr & 0x1FFF);
    // else if (memAddr <= INTERNAL_RAM_LAST)
    //   return this.ir_pull8(memAddr & 0x1FFF);
    else if (memAddr <= ECHO_RAM_LAST)
      return this.ir_pull8(memAddr & 0x1FFF);
    else if (memAddr <= OAM_LAST)
      return this.oam.pull8(memAddr & 0x00FF);
    else if (memAddr <= FORBIDDEN_LAST)
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
    else if (memAddr <= TAIL_RAM_LAST)
      return this.tr_pull8(memAddr & 0x00FF);
    else
      throw new Exception('MMU: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void push8(int memAddr, int v)
  {
    assert(v & ~0xFF == 0, 'push8: invalid value $v');
    assert(memAddr & ~0xFFFF == 0, 'push8: invalid memAddr $memAddr');
    if (memAddr <= CARTRIDGE_ROM_LAST)
      this.c.push8_Rom(memAddr & 0x7FFF, v);
    else if (memAddr <= VIDEO_RAM_LAST)
      this.vr_push8(memAddr & 0x1FFF, v);
    else if (memAddr <= CARTRIDGE_RAM_LAST)
      this.c.push8_Ram(memAddr & 0x1FFF, v);
    // else if (memAddr <= INTERNAL_RAM_LAST)
    //   this.ir_push8(memAddr, v);
    else if (memAddr <= ECHO_RAM_LAST)
      this.ir_push8(memAddr & 0x1FFF, v);
    else if (memAddr <= OAM_LAST)
      this.oam.push8(memAddr & 0x00FF, v);
    else if (memAddr <= FORBIDDEN_LAST)
      return ;
    else if (memAddr <= TAIL_RAM_LAST)
      this.tr_push8(memAddr & 0x00FF, v);
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








  // int pull8(int memAddr)
  // {
  //   assert(memAddr & ~0xFFFF == 0, 'push8: invalid memAddr $memAddr');
  //   switch (memAddr & 0xF000)
  //   {
  //     /* Cartridge RAM */
  //     case (0x0000) : case (0x1000) : case (0x2000) : case (0x3000) :
  //     case (0x4000) : case (0x5000) : case (0x6000) : case (0x7000) :
  //       return this.c.pull8_Rom(memAddr & 0x7FFF);

  //     /* Video RAM */
  //     case (0x8000) : case (0x9000) :
  //       return this.vr_pull8(memAddr & 0x1FFF);

  //     /* Cartridge RAM */
  //     case (0xA000) : case (0xB000) :
  //       return this.c.pull8_Rom(memAddr & 0x1FFF);

  //     /* Internal RAM */
  //     case (0xC000) : case (0xD000) :
  //       return this.ir_pull8(memAddr & 0x1FFF);

  //     /* Echo RAM */
  //     case (0xE000) :
  //       return this.ir_pull8(memAddr & 0x1FFF);

  //     case (0xF000) : switch (memAddr & 0x0F00)
  //     {
  //       /* Echo RAM */
  //       case (0x000) : case (0x100) : case (0x200) : case (0x300) :
  //       case (0x400) : case (0x500) : case (0x600) : case (0x700) :
  //       case (0x800) : case (0x900) : case (0xA00) : case (0xB00) :
  //       case (0xC00) : case (0xD00) :
  //         return this.ir_pull8(memAddr & 0x1FFF);

  //       case (0xE00) : switch (memAddr & 0x00F0)
  //       {
  //         /* OAM */
  //         case (0x00) : case (0x10) : case (0x20) : case (0x30) : 
  //         case (0x40) : case (0x50) : case (0x60) : case (0x70) : 
  //         case (0x80) : case (0x90) :
  //         return this.oam.pull8(memAddr & 0x009F);

  //         /* Forbidden */
  //         default : 
  //           throw new Exception('MMU: Forbidden $memAddr');
  //       }

  //       /* Tail Ram */
  //       default :
  //         return this.tr_pull8(memAddr & 0xFF);
  //     }

  //   }
