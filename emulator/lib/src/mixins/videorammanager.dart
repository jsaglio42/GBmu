// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailrammanager.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 11:11:39 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;

final int MAP_OFFSET = 0x1800;

abstract class TrapAccessor {
  int vr_pull8(int memAddr);
  void vr_push8(int memAddr, int v);
}

abstract class VideoRamManager
  implements Hardware.Hardware {

  /* API ***********************************************************************/
  int vr_pull8(int memAddr) {
    memAddr -= VIDEO_RAM_FIRST;
    assert(memAddr & ~0x1FFF == 0, 'vr_pull8: invalid memAddr $memAddr');
    if (memAddr < MAP_OFFSET)
      return this.videoram.pull8_TileData(memAddr, this.memr.VBK);
    else if (memAddr <= VIDEO_RAM_LAST)
    {
      memAddr -= MAP_OFFSET;
      if (this.memr.VBK == 0)
        return this.videoram.pull8_TileID(memAddr);
      else
        return this.videoram.pull8_TileInfo(memAddr);
    }
    else
      throw new Exception('vr_pull8: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void vr_push8(int memAddr, int v) {
    memAddr -= VIDEO_RAM_FIRST;
    assert(memAddr & ~0x1FFF == 0, 'vr_push8: invalid memAddr $memAddr');
    if (memAddr < MAP_OFFSET)
      return this.videoram.push8_TileData(memAddr, this.memr.VBK, v);
    else if (memAddr <= VIDEO_RAM_LAST)
    {
      memAddr -= MAP_OFFSET;
      if (this.memr.VBK == 0)
        this.videoram.push8_TileID(memAddr, v);
      else
        this.videoram.push8_TileInfo(memAddr, v);
    }
    else
      throw new Exception('vr_push8: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

}
