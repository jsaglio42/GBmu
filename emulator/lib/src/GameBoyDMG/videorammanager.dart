// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   videorammanager.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 21:22:23 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;

final int MAP_OFFSET = 0x1800;

abstract class VideoRamManager
  implements Hardware.Hardware {

  /* API ***********************************************************************/
  int vr_pull8(int memAddr) {
    assert(memAddr >= VIDEO_RAM_FIRST && memAddr <= VIDEO_RAM_LAST, 'vr_pull8: invalid memAddr $memAddr');
    memAddr -= VIDEO_RAM_FIRST;
    if (memAddr < MAP_OFFSET)
      return this.videoram.pull8_TileData(memAddr, this.memr.VBK);
    else
    {
      if (this.memr.VBK == 0)
        return this.videoram.pull8_TileID(memAddr - MAP_OFFSET);
      else
        return this.videoram.pull8_TileInfo(memAddr - MAP_OFFSET);
    }
  }

  void vr_push8(int memAddr, int v) {
    assert(memAddr >= VIDEO_RAM_FIRST && memAddr <= VIDEO_RAM_LAST, 'vr_push8: invalid memAddr $memAddr');
    memAddr -= VIDEO_RAM_FIRST;
    if (memAddr < MAP_OFFSET)
      this.videoram.push8_TileData(memAddr, this.memr.VBK, v);
    else
    {
      if (this.memr.VBK == 0)
        this.videoram.push8_TileID(memAddr - MAP_OFFSET, v);
      else
        this.videoram.push8_TileInfo(memAddr - MAP_OFFSET, v);
    }
  }

}
