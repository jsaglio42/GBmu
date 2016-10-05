// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   instructionsdecoder.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 11:48:57 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/enums.dart';
import 'package:emulator/src/globals.dart';

import "package:emulator/src/hardware/hardware.dart" as Hardware;
import "package:emulator/src/mixins/mmu.dart" as Mmu;
import "package:emulator/src/mixins/instructions.dart" as Instructions;

abstract class InstructionsDecoder
  implements Hardware.Hardware
  , Mmu.Mmu {

  /* API **********************************************************************/

  List<Instructions.Instruction> pullInstructionList(int len) {
    final lst = <Instructions.Instruction>[];
    int pc_current = this.cpur.PC;
    lst.add(_getPreviousInstruction(pc_current));
    for (int i = 1; i < len; ++i) {
      Instructions.Instruction inst;
      try {
        inst = _getInstruction(pc_current);
        pc_current += inst.info.instSize;
      } catch (e) { inst = null; }
      lst.add(inst);
    }
    return lst;
  }

  /* Private ******************************************************************/

  Instructions.Instruction _getPreviousInstruction(int addr) {
    final op = this.pull8(addr - 2);
    if (op == 0xCB)
      return _getInstruction(addr - 2);
    else
      return _getInstruction(addr - 1);
  }

  Instructions.InstructionInfo _getInstructionInfo(int addr) {
    final op = this.pull8(addr);
    if (op == 0xCB)
    {
      final opX = this.pull8(addr + 1);
      return g_instInfos_CB[opX];
    }
    else
      return g_instInfos[op];
  }

  Instructions.Instruction _getInstruction(int addr) {
    final info = _getInstructionInfo(addr);
    int data;
    switch (info.dataSize)
    {
      case (0):
        data = 0; break;
      case (1):
        data = this.pull8(addr + info.opCodeSize); break;
      case (2):
        data = this.pull16(addr + info.opCodeSize); break;
      default :
        assert(false, 'InstructionDecoder: switch(dataSize): failure');
    }
    return new Instructions.Instruction(addr, info, data);
  }

}
