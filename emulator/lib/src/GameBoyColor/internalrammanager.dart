// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalrammanager.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 14:38:43 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;

abstract class InternalRamManager
  implements Hardware.Hardware {

  /* API ***********************************************************************/
  int ir_pull8(int memAddr) {
    return (this.internalRam.pull8(memAddr, this.memr.SVBK));
  }

  void ir_push8(int memAddr, int v) {
    this.internalRam.pull8(memAddr, this.memr.SVBK, v);
  }

}
