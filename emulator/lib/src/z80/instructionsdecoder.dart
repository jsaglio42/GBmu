// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   instructions.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 10:19:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/src/enums.dart';
import "package:emulator/src/z80/instructions.dart" as Instructions;

import "package:emulator/src/gameboy.dart" as GameBoy;
import "package:emulator/src/z80/z80.dart" as Z80;

abstract class InstructionsDecoder
  implements GameBoy.GameBoyMemory, Z80.Z80 {

    /* API */
    List<Instructions.Instruction> pullInstructionList(int len) {
      final lst = <Instructions.Instruction>[];
      int pc_current = this.cpur.PC;

      for (int i = 0; i < len; ++i) {
        Instructions.Instruction inst;
        try {
          inst = _getInstruction(pc_current);
          pc_current += inst.info.instSize;
        } catch (e) { inst = null; }
        lst.add(inst);
      }
      return lst;
    }

    /* Private */
    Instructions.InstructionInfo _getInstructionInfo(int addr) {
      final op = this.mmu.pull8(addr);
      if (op == 0xCB)
      {
        final opX = this.mmu.pull8(addr + 1);
        return Instructions.instInfos_CB[opX];
      }
      else
        return Instructions.instInfos[op];
     }

    Instructions.Instruction _getInstruction(int addr) {
    final info = _getInstructionInfo(addr);
    int data;
    switch (info.dataSize)
    {
      case (0):
        data = 0; break;
      case (1):
        data = this.mmu.pull8(addr + info.opCodeSize); break;
      case (2):
        data = this.mmu.pull16(addr + info.opCodeSize); break;
      default :
        assert(false, 'InstructionDecoder: switch(dataSize): failure');
    }
    this.cpur.PC += info.instSize;
    return new Instructions.Instruction(addr, info, data);
  }

}
