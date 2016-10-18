// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   joypad.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/17 18:18:37 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/enums.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interrupts.dart" as Interrupts;

/*
* Joypad behaviour is strange, depending on value in b4 and b5, reading to  FF00
* will return the states of either buttons or directions.
* There is a private attribute _joypadState that stores the state of all
* and reading from FF00 will build the answer based on this _joypadState.
* !!! Reading to the Joypad return the complementary of the states (ie 0 = set)
*
* Wiring of Joypad input:              Implementation via joypadState:
*
*   FF00H                                  joypadState
*   +---+                                   +---+
*   | 7 |                                   | 7 +--- Start
*   |   |                                   |   |
*   | 6 |                                   | 6 +--- Select
*   |   |                                   |   |
*   | 5 +-------------------+               | 5 +--- B
*   |   |                   |               |   |
*   | 4 +---------+         |               | 4 +--- A
*   |   |    Down |   Start |               |   |
*   | 3 +---------+---------+ - R3          | 3 +--- Down
*   |   |      Up |  Select |               |   |
*   | 2 +---------+---------+ - R2          | 2 +--- Up
*   |   |    Left |       B |               |   |
*   | 1 +---------+---------+ - R1          | 1 +--- Left
*   |   |   Right |       A |               |   |
*   | 0 +---------+---------+ - R0          | 0 +--- Right
*   +---+         |         |               +---+
*                C0        C1              
*
*/

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
      if (this.memr.rP1.getBit(k.index) == 0)
        this.requestInterrupt(InterruptType.Joypad);
      this.memr.rP1.setBit(k.index);
      return ;
    }

    void keyRelease(JoypadKey k) {
      this.memr.rP1.unsetBit(k.index);
      return;
    }

}
