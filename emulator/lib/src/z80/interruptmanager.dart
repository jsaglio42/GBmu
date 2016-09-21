// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   z80.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 10:19:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/enums.dart";

import "package:emulator/src/gameboy.dart" as GameBoy;

enum InterruptType {
  VBlank,
  LCDStat,
  Timer,
  Serial,
  Joypad
}

abstract class InterruptManager
  implements GameBoy.GameBoyMemory {

  /* API **********************************************************************/

  bool ime = true;

  void requestInterrupt(InterruptType i) {
    return ;
  }

  void serviceInterrupt(InterruptType i) {
    return ;
  }

  /* Private ******************************************************************/


}