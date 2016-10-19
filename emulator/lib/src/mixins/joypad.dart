// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   joypad.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 13:55:48 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/enums.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interrupts.dart" as Interrupts;

enum JoypadKey {
  Right,
  Left,
  Up,
  Down,
  A,
  B,
  Select,
  Start
}

abstract class Joypad
  implements Hardware.Hardware
  , Interrupts.Interrupts
{

    void keyPress(JoypadKey k) {
      if (this.memr.rP1.getKey(k) == 0)
        this.requestInterrupt(InterruptType.Joypad);
      this.memr.rP1.setKey(k);
      return ;
    }

    void keyRelease(JoypadKey k) {
      this.memr.rP1.unsetKey(k);
      return;
    }

}
