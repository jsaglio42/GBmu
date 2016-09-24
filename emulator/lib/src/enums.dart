// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   enums.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:14 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 10:27:03 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

export 'package:emulator/src/worker.dart'
  show DebuggerExternalMode, GameBoyExternalMode, PauseExternalMode,
  AutoBreakExternalMode, EmulatorEvent;
export 'package:emulator/src/z80/cpu_registers.dart'
  show Reg16, Reg8, Reg1;
export 'package:emulator/src/memory/mem_registers.dart'
  show MemReg;
export 'package:emulator/src/memory/headerdecoder.dart'
  show RomHeaderField, CartridgeType;
export 'package:emulator/src/z80/interruptmanager.dart'
  show InterruptType ;

enum DebuggerModeRequest {
  Toggle, Disable, Enable
}
