// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalrammanager.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 15:15:28 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;

abstract class InternalRamManager
  implements Hardware.Hardware {

  /* API ***********************************************************************/
  int ir_pull8(int addr) {
    assert(addr & ~0x1FFF == 0, 'vr_pull8: invalid addr $addr');
    return (this.internalram.pull8(addr, 0));
  }

  void ir_push8(int addr, int v) {
    assert(addr & ~0x1FFF == 0, 'vr_pull8: invalid addr $addr');
    this.internalram.push8(addr, 0, v);
  }

}
