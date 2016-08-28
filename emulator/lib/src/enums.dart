// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   enums.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:14 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 18:32:03 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

export 'package:emulator/src/worker.dart'
  show DebuggerExternalMode, GameBoyExternalMode, ObserverExternalMode;
export 'package:emulator/src/cpu_registers.dart'
  show Reg16, Reg8, Reg1;
export 'package:emulator/src/memory/mem_registers.dart'
  show MemReg;
export 'package:emulator/src/memory/rom_header.dart'
  show RomHeaderField, CartridgeType;

enum DebuggerModeRequest {
  Toggle, Disable, Enable
}

enum AutoBreakMode {
  Instruction,
  Frame,
  Second,
  None
}
