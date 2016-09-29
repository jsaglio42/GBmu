// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   graphics.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 15:39:09 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";
import "package:emulator/src/constants.dart";
// import "package:emulator/src/globals.dart";

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;
import "package:emulator/src/mixins/mmu.dart" as Mmu;

abstract class Graphics
  implements Hardware.Hardware
  , Mmu.Mmu
  , Interrupt.InterruptManager {

  int _counterVideo = 0;
  Uint8List _buffer = new Uint8List(LCD_DATA_SIZE);

  /* API **********************************************************************/
  void updateGraphics(int nbClock) {
    _counterVideo += nbClock;

    return ;
  }

  /* Private ******************************************************************/


}
