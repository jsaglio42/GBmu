// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   enums.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:14 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/28 17:28:57 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

export 'package:emulator/src/worker/worker.dart'
  show DebuggerExternalMode
  , PauseExternalMode;
export 'package:emulator/src/mixins/gameboy.dart'
  show GameBoyType;
export 'package:emulator/src/hardware/cpu_registers.dart'
  show Reg16
  , Reg8
  , Reg1;
export 'package:emulator/src/hardware/headerdecoder.dart'
  show RomHeaderField
  , CartridgeType;
export 'package:emulator/src/hardware/mem_registers_info.dart'
  show MemReg;
export 'package:emulator/src/mixins/interrupts.dart'
  show InterruptType ;
export 'package:emulator/src/mixins/joypad.dart'
  show JoypadKey ;
export 'package:emulator/src/mixins/graphicstatemachine.dart'
  show GraphicInterrupt
  , GraphicMode;


enum DebuggerModeRequest {
  Toggle, Disable, Enable
}

enum LimitedEmulation {
  Instruction, Line, Frame, Second
}
