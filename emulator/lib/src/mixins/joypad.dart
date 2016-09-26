// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   joypad.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/26 18:50:09 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
* Joypad behaviour is strange, depending on value in b4 and b5, reading to  FF00
* will return the states of either buttons or directions.
* There is a private attribute _joypadState that stores the state of all 
* and reading from FF00 will build the answer based on this _joypadState
* 
* Wiring of Joypad input:              Implementation via joypadState:
*                      
*                                         joypadState
*   FF00H                                   +---+
*   +---+                                   | 8 +--- Button = 0 | Direction = 1
*   | 7 |                                   |   |
*   |   |                                   | 7 +--- Down
*   | 6 |                                   |   |
*   |   |                                   | 6 +--- Up
*   | 5 +-------------------+               |   |
*   |   |                   |               | 5 +--- Left
*   | 4 +---------+         |               |   |
*   |   |   Start |    Down |               | 4 +--- Right
*   | 3 +---------+---------+ - R3          |   |
*   |   |  Select |      Up |               | 3 +--- Start
*   | 2 +---------+---------+ - R2          |   |
*   |   |       B |    Left |               | 2 +--- Select
*   | 1 +---------+---------+ - R1          |   |
*   |   |       A |   Right |               | 1 +--- B
*   | 0 +---------+---------+ - R0          |   |
*   +---+         |         |               | 0 +--- A
*                C0        C1               +---+
* 
*/

enum KeyStatus {
  KeyDown,
  KeyUp
}

enum KeyCode {
  A,
  B,
  Select,
  Start,
  Right,
  Left,
  Up,
  Down
}

abstract class Joypad
  implements GameBoy.Hardware
  , Interrupt.InterruptManager {

    void keyRelease(KeyCode k) {
      // final int bit_row = k.index % 4;
      // final int bit_column = (k.index < 4) ? 0x4 : 0x5;
      // final int mask = (1 << bit_position) | (1 << bit_row);
      // final int P1_old = this.mmu.pullMemReg(MemReg.P1);
      // final int P1_new = P1_old | mask;
      // return ;
    }

    void keyRelease(KeyCode k) {
      // final int bit_row = k.index % 4;
      // final int bit_column = (k.index < 4) ? 0x4 : 0x5;
      // final int mask = (1 << bit_position) | (1 << bit_row);
      // final int P1_old = this.mmu.pullMemReg(MemReg.P1);
      // final int P1_new = P1_old | mask;
      // return ;
    }

}
