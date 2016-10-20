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
    if (memAddr <= 0x17FF)
    {
      return 0xFF;
    }
    else if (memAddr <= VIDEO_RAM_LAST)
    {
      return 0xFF;
    }
    else
      throw new Exception('vr_pull8: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

  void vr_push8(int memAddr, int v) {
    memAddr -= VIDEO_RAM_FIRST;
    assert(memAddr & ~0x1FFF == 0, 'vr_push8: invalid memAddr $memAddr');
    if (memAddr <= 0x17FF)
    {
      if (this.memr.VBK == 0)
        return ;// this.c.pull8_Rom(memAddr);
      else
        return ;// this.c.pull
    }
    else if (memAddr <= VIDEO_RAM_LAST)
    {
      if (this.memr.VBK == 0)
        return ;// this.c.pull8_Rom(memAddr);
      else
        return ;// this.c.pull
    }
    else
      throw new Exception('vr_push8: cannot access address ${Ft.toAddressString(memAddr, 4)}');
  }

}
