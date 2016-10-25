// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   videorammanager.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 15:35:08 by jsaglio          ###   ########.fr       //
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
  int vr_pull8(int addr) {
    assert(addr & ~0x1FFF == 0, 'vr_pull8: invalid addr $addr');
    if (addr < MAP_OFFSET)
      return this.videoram.pull8_TileData(addr, 0);
    else
      return this.videoram.pull8_TileID(addr - MAP_OFFSET);
  }

  void vr_push8(int addr, int v) {
    assert(addr & ~0x1FFF == 0, 'vr_push8: invalid addr $addr');
    if (addr < MAP_OFFSET)
      this.videoram.push8_TileData(addr, 0, v);
    else
      this.videoram.push8_TileID(addr - MAP_OFFSET, v);
    }
}
