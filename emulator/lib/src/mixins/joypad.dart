// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   joypad.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/17 12:46:18 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/enums.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/interruptmanager.dart" as Interrupt;

/*
* Joypad behaviour is strange, depending on value in b4 and b5, reading to  FF00
* will return the states of either buttons or directions.
* There is a private attribute _joypadState that stores the state of all
* and reading from FF00 will build the answer based on this _joypadState.
* !!! Reading to the Joypad return the complementary of the states (ie 0 = set)
*
* Wiring of Joypad input:              Implementation via joypadState:
*
*                                         joypadState
*   FF00H                                   +---+
*   +---+                                   | 8 +--- Direction = 0 | Buttons = 1
*   | 7 |                                   |---|
*   |   |                                   | 7 +--- Down
*   | 6 |                                   |   |
*   |   |                                   | 6 +--- Up
*   | 5 +-------------------+               |   |
*   |   |                   |               | 5 +--- Left
*   | 4 +---------+         |               |   |
*   |   |    Down |   Start |               | 4 +--- Right
*   | 3 +---------+---------+ - R3          |   |
*   |   |      Up |  Select |               | 3 +--- Start
*   | 2 +---------+---------+ - R2          |   |
*   |   |    Left |       B |               | 2 +--- Select
*   | 1 +---------+---------+ - R1          |   |
*   |   |   Right |       A |               | 1 +--- B
*   | 0 +---------+---------+ - R0          |   |
*   +---+         |         |               | 0 +--- A
*                C0        C1               +---+
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

abstract class TrapAccessors {

  int getJoypadRegister();
  void setJoypadRegister(int v);

}

abstract class Joypad
  implements Hardware.Hardware
  , Interrupt.InterruptManager
{

    void keyPress(JoypadKey k) {
      final int bit = (1 << k.index);
      if (this.joypadState & bit == 0)
        this.requestInterrupt(InterruptType.Joypad);
      this.joypadState |= bit;
      return ;
    }

    void keyRelease(JoypadKey k) {
      final int state = 0x100 & this.joypadState;
      final int bit = (1 << k.index);
      final int mask = ~bit & 0xFF;
      this.joypadState = (this.joypadState & mask) | state;
      return;
    }

  int getJoypadRegister() {
    if (this.joypadState & 0x100 == 0) // b8 = 0: return directions
      return ~((0x0F & (this.joypadState >> 0)) | 0x10) & 0x3F;
    else // b8 = 1: return buttons
      return ~((0x0F & (this.joypadState >> 4)) | 0x20) & 0x3F;
  }

  void setJoypadRegister(int v) {
    if (v & 0x10 == 0) // Directions: b8 <- 1
      this.joypadState &= 0xFF;
    else if (v & 0x20 == 0) // Buttons: b8 <- 1
      this.joypadState |= (1 << 8);
    return ;
  }

}
