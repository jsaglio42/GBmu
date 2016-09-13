// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cpu_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 10:19:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';

import "package:emulator/src/enums.dart";

import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/z80/instructions.dart" as Instructions;
import "package:emulator/src/z80/cpu_registers.dart" as Cpuregs;

class Z80 {

  final Cpuregs.CpuRegs cpur;

  final Mmu.Mmu _mmu;

  int _clockCount;
  int _clockWait;

  /*
  ** Constructors **************************************************************
  */

  Z80(Mmu.Mmu m) :
    this.cpur = new Cpuregs.CpuRegs(),
    this._mmu = m,
    _clockCount = 0,
    _clockWait = 0;
  
  Z80.clone(Z80 src) :
    this.cpur = new Cpuregs.CpuRegs.clone(src.cpur),
    _mmu = src._mmu,
    _clockCount = src._clockCount,
    _clockWait = src._clockWait;

  /*
  ** API ***********************************************************************
  */

  int get clockCount => this._clockCount;

  void reset() {
    this.cpur.reset();
    _clockCount = 0;
    _clockWait = 0;
    return ;
  }

  void exec(int nbClock) {
    _clockCount += nbClock;
    while (nbClock-- > 0)
    {
      if (_clockWait > 0)
        _clockWait--;
      else
        _execInst();
    }
    return ;
  }
  
  Instructions.Instruction pullInstruction() {
    final addr = this.cpur.PC;
    final info = _getInstructionInfo(addr);
    int data;
    switch (info.dataSize)
    {
      case (0):
        data = 0;
        break;
      case (1):
        data = _mmu.pullMem(this.cpur.PC + info.opCodeSize, DataType.BYTE);
        break;
      case (2):
        data = _mmu.pullMem(this.cpur.PC + info.opCodeSize, DataType.WORD);
        break;
      default :
        assert(false, 'InstructionDecoder: switch(dataSize): failure');
    }
    this.cpur.PC += info.instSize;
    return new Instructions.Instruction(addr, info, data);
  }

  /*
  ** Private *******************************************************************
  */

  Instructions.InstructionInfo _getInstructionInfo(int addr) {
    assert(addr >= 0 && addr + 1 <= 0xFFFF);
    final op = _mmu.pullMem(addr, DataType.WORD);
    if ((op & 0x00FF) != 0xCB)
      return Instructions.instInfos[(op & 0x00FF)];
    else
      return Instructions.instInfos_CB[(op >> 8)];
  }

  void _execInst(){
    var info = _getInstructionInfo(this.cpur.PC);
    this.cpur.PC += info.instSize;
    return ;
  }

  void _NOP() {
    return ;
  }

}
