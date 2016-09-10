// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gameboy.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:31:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 13:06:31 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import "package:emulator/src/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/memory/mmu.dart" as Mmu;
import "package:emulator/src/memory/cartridge.dart" as Cartridge;
import 'package:emulator/src/instructions.dart' as Instructions;

class GameBoy {

  final Mmu.Mmu mmu;
  final Cartridge.ACartridge cartridge;
  final Cpuregs.CpuRegs cpur = new Cpuregs.CpuRegs();
  // final LCDScreen lcd;
  // final Headset sound;

  int         _clockCount = 0;
  int         _clockWait = 0;

  GameBoy(Cartridge.ACartridge c) //TODO: pass LCDScreen and eadset <- DONT AGREE
    : this.cartridge = c
    , this.mmu = new Mmu.Mmu(c)
  {
    cpur.init();
    mmu.init();
  }

  int get clockCount => _clockCount;

  void exec(int nbClock) {    
    _clockCount += nbClock;
    while (nbClock-- > 0)
    {
      if (_clockWait > 0)
        _clockWait--;
      else
        _clockWait = _execInst();
    }
    return ;
  }

  int _execInst() {
    final inst = this.mmu.pullMem(cpur.PC, DataType.BYTE);
    final info = Instructions.instInfos[inst];
    bool s = true;
    switch (info.opCode)
    {
      case OpCode.NOP: break;
      case OpCode.LD_BC_d16: break;
      case OpCode.LD_i_BC_A: break;
      case OpCode.INC_BC: break;
      case OpCode.INC_B: break;
      case OpCode.DEC_B: break;
      case OpCode.LD_B_d8: break;
      case OpCode.RLCA: break;
      case OpCode.LD_i_a16_SP: break;
      case OpCode.ADD_HL_BC: break;
      case OpCode.LD_A_i_BC: break;
      case OpCode.DEC_BC: break;
      case OpCode.INC_C: break;
      case OpCode.DEC_C: break;
      case OpCode.LD_C_d8: break;
      case OpCode.RRCA: break;
      case OpCode.STOP_0: break;
      case OpCode.LD_DE_d16: break;
      case OpCode.LD_i_DE_A: break;
      case OpCode.INC_DE: break;
      case OpCode.INC_D: break;
      case OpCode.DEC_D: break;
      case OpCode.LD_D_d8: break;
      case OpCode.RLA: break;
      case OpCode.JR_r8: break;
      case OpCode.ADD_HL_DE: break;
      case OpCode.LD_A_i_DE: break;
      case OpCode.DEC_DE: break;
      case OpCode.INC_E: break;
      case OpCode.DEC_E: break;
      case OpCode.LD_E_d8: break;
      case OpCode.RRA: break;
      case OpCode.JR_NZ_r8: break;
      case OpCode.LD_HL_d16: break;
      case OpCode.LD_i_HLp_A: break;
      case OpCode.INC_HL: break;
      case OpCode.INC_H: break;
      case OpCode.DEC_H: break;
      case OpCode.LD_H_d8: break;
      case OpCode.DAA: break;
      case OpCode.JR_Z_r8: break;
      case OpCode.ADD_HL_HL: break;
      case OpCode.LD_A_i_HLp: break;
      case OpCode.DEC_HL: break;
      case OpCode.INC_L: break;
      case OpCode.DEC_L: break;
      case OpCode.LD_L_d8: break;
      case OpCode.CPL: break;
      case OpCode.JR_NC_r8: break;
      case OpCode.LD_SP_d16: break;
      case OpCode.LD_i_HLm_A: break;
      case OpCode.INC_SP: break;
      case OpCode.INC_i_HL: break;
      case OpCode.DEC_i_HL: break;
      case OpCode.LD_i_HL_d8: break;
      case OpCode.SCF: break;
      case OpCode.JR_C_r8: break;
      case OpCode.ADD_HL_SP: break;
      case OpCode.LD_A_i_HLm: break;
      case OpCode.DEC_SP: break;
      case OpCode.INC_A: break;
      case OpCode.DEC_A: break;
      case OpCode.LD_A_d8: break;
      case OpCode.CCF: break;
      case OpCode.LD_B_B: break;
      case OpCode.LD_B_C: break;
      case OpCode.LD_B_D: break;
      case OpCode.LD_B_E: break;
      case OpCode.LD_B_H: break;
      case OpCode.LD_B_L: break;
      case OpCode.LD_B_i_HL: break;
      case OpCode.LD_B_A: break;
      case OpCode.LD_C_B: break;
      case OpCode.LD_C_C: break;
      case OpCode.LD_C_D: break;
      case OpCode.LD_C_E: break;
      case OpCode.LD_C_H: break;
      case OpCode.LD_C_L: break;
      case OpCode.LD_C_i_HL: break;
      case OpCode.LD_C_A: break;
      case OpCode.LD_D_B: break;
      case OpCode.LD_D_C: break;
      case OpCode.LD_D_D: break;
      case OpCode.LD_D_E: break;
      case OpCode.LD_D_H: break;
      case OpCode.LD_D_L: break;
      case OpCode.LD_D_i_HL: break;
      case OpCode.LD_D_A: break;
      case OpCode.LD_E_B: break;
      case OpCode.LD_E_C: break;
      case OpCode.LD_E_D: break;
      case OpCode.LD_E_E: break;
      case OpCode.LD_E_H: break;
      case OpCode.LD_E_L: break;
      case OpCode.LD_E_i_HL: break;
      case OpCode.LD_E_A: break;
      case OpCode.LD_H_B: break;
      case OpCode.LD_H_C: break;
      case OpCode.LD_H_D: break;
      case OpCode.LD_H_E: break;
      case OpCode.LD_H_H: break;
      case OpCode.LD_H_L: break;
      case OpCode.LD_H_i_HL: break;
      case OpCode.LD_H_A: break;
      case OpCode.LD_L_B: break;
      case OpCode.LD_L_C: break;
      case OpCode.LD_L_D: break;
      case OpCode.LD_L_E: break;
      case OpCode.LD_L_H: break;
      case OpCode.LD_L_L: break;
      case OpCode.LD_L_i_HL: break;
      case OpCode.LD_L_A: break;
      case OpCode.LD_i_HL_B: break;
      case OpCode.LD_i_HL_C: break;
      case OpCode.LD_i_HL_D: break;
      case OpCode.LD_i_HL_E: break;
      case OpCode.LD_i_HL_H: break;
      case OpCode.LD_i_HL_L: break;
      case OpCode.HALT: break;
      case OpCode.LD_i_HL_A: break;
      case OpCode.LD_A_B: break;
      case OpCode.LD_A_C: break;
      case OpCode.LD_A_D: break;
      case OpCode.LD_A_E: break;
      case OpCode.LD_A_H: break;
      case OpCode.LD_A_L: break;
      case OpCode.LD_A_i_HL: break;
      case OpCode.LD_A_A: break;
      case OpCode.ADD_A_B: break;
      case OpCode.ADD_A_C: break;
      case OpCode.ADD_A_D: break;
      case OpCode.ADD_A_E: break;
      case OpCode.ADD_A_H: break;
      case OpCode.ADD_A_L: break;
      case OpCode.ADD_A_i_HL: break;
      case OpCode.ADD_A_A: break;
      case OpCode.ADC_A_B: break;
      case OpCode.ADC_A_C: break;
      case OpCode.ADC_A_D: break;
      case OpCode.ADC_A_E: break;
      case OpCode.ADC_A_H: break;
      case OpCode.ADC_A_L: break;
      case OpCode.ADC_A_i_HL: break;
      case OpCode.ADC_A_A: break;
      case OpCode.SUB_B: break;
      case OpCode.SUB_C: break;
      case OpCode.SUB_D: break;
      case OpCode.SUB_E: break;
      case OpCode.SUB_H: break;
      case OpCode.SUB_L: break;
      case OpCode.SUB_i_HL: break;
      case OpCode.SUB_A: break;
      case OpCode.SBC_A_B: break;
      case OpCode.SBC_A_C: break;
      case OpCode.SBC_A_D: break;
      case OpCode.SBC_A_E: break;
      case OpCode.SBC_A_H: break;
      case OpCode.SBC_A_L: break;
      case OpCode.SBC_A_i_HL: break;
      case OpCode.SBC_A_A: break;
      case OpCode.AND_B: break;
      case OpCode.AND_C: break;
      case OpCode.AND_D: break;
      case OpCode.AND_E: break;
      case OpCode.AND_H: break;
      case OpCode.AND_L: break;
      case OpCode.AND_i_HL: break;
      case OpCode.AND_A: break;
      case OpCode.XOR_B: break;
      case OpCode.XOR_C: break;
      case OpCode.XOR_D: break;
      case OpCode.XOR_E: break;
      case OpCode.XOR_H: break;
      case OpCode.XOR_L: break;
      case OpCode.XOR_i_HL: break;
      case OpCode.XOR_A: break;
      case OpCode.OR_B: break;
      case OpCode.OR_C: break;
      case OpCode.OR_D: break;
      case OpCode.OR_E: break;
      case OpCode.OR_H: break;
      case OpCode.OR_L: break;
      case OpCode.OR_i_HL: break;
      case OpCode.OR_A: break;
      case OpCode.CP_B: break;
      case OpCode.CP_C: break;
      case OpCode.CP_D: break;
      case OpCode.CP_E: break;
      case OpCode.CP_H: break;
      case OpCode.CP_L: break;
      case OpCode.CP_i_HL: break;
      case OpCode.CP_A: break;
      case OpCode.RET_NZ: break;
      case OpCode.POP_BC: break;
      case OpCode.JP_NZ_a16: break;
      case OpCode.JP_a16: break;
      case OpCode.CALL_NZ_a16: break;
      case OpCode.PUSH_BC: break;
      case OpCode.ADD_A_d8: break;
      case OpCode.RST_00H: break;
      case OpCode.RET_Z: break;
      case OpCode.RET: break;
      case OpCode.JP_Z_a16: break;
      case OpCode.CB_PREFIX: break;
      case OpCode.CALL_Z_a16: break;
      case OpCode.CALL_a16: break;
      case OpCode.ADC_A_d8: break;
      case OpCode.RST_08H: break;
      case OpCode.RET_NC: break;
      case OpCode.POP_DE: break;
      case OpCode.JP_NC_a16: break;
      case OpCode.D3_NA: break;
      case OpCode.CALL_NC_a16: break;
      case OpCode.PUSH_DE: break;
      case OpCode.SUB_d8: break;
      case OpCode.RST_10H: break;
      case OpCode.RET_C: break;
      case OpCode.RETI: break;
      case OpCode.JP_C_a16: break;
      case OpCode.DB_NA: break;
      case OpCode.CALL_C_a16: break;
      case OpCode.DD_NA: break;
      case OpCode.SBC_A_d8: break;
      case OpCode.RST_18H: break;
      case OpCode.LDH_i_a8_A: break;
      case OpCode.POP_HL: break;
      case OpCode.LD_i_C_A: break;
      case OpCode.E3_NA: break;
      case OpCode.E4_NA: break;
      case OpCode.PUSH_HL: break;
      case OpCode.AND_d8: break;
      case OpCode.RST_20H: break;
      case OpCode.ADD_SP_r8: break;
      case OpCode.JP_i_HL: break;
      case OpCode.LD_i_a16_A: break;
      case OpCode.EB_NA: break;
      case OpCode.EC_NA: break;
      case OpCode.ED_NA: break;
      case OpCode.XOR_d8: break;
      case OpCode.RST_28H: break;
      case OpCode.LDH_A_i_a8: break;
      case OpCode.POP_AF: break;
      case OpCode.LD_A_i_C: break;
      case OpCode.DI: break;
      case OpCode.F4_NA: break;
      case OpCode.PUSH_AF: break;
      case OpCode.OR_d8: break;
      case OpCode.RST_30H: break;
      case OpCode.LD_HL_SPpr8: break;
      case OpCode.LD_SP_HL: break;
      case OpCode.LD_A_i_a16: break;
      case OpCode.EI: break;
      case OpCode.FC_NA: break;
      case OpCode.FD_NA: break;
      case OpCode.CP_d8: break;
      case OpCode.RST_38H: break;
      default: throw new Exception('Gameboy: exec: Unexpected instruction');
    }
    this.cpur.PC += info.byteSize;
    return (s) ? info.durationSuccess : info.durationFail;
  }

  int _execExtendedInst() {
    this.cpur.PC++;
    final inst = this.mmu.pullMem(cpur.PC, DataType.BYTE);
    final info = Instructions.EXinstInfos[inst];
    switch (info.opCode)
    {
      default: break;
    }
    this.cpur.PC += info.byteSize;
    return info.durationSuccess;
  }

}



// OLD ** Only for debug

// import 'dart:math' as Math;
// var rng = new Math.Random();
// Map _generateRandomMapFromIterable(Iterable l, int value_range)
// {
//   final size = Math.max(1, rng.nextInt(l.length));
//   final m = {};
//   var v;
//   for (int i = 0; i < size; i++) {
//     v = l.elementAt(rng.nextInt(l.length));
//     m[v] = rng.nextInt(value_range);
//   }
//   return m;
// }


// void exec(int nbClock) {
    // OLD ** Only for debug
    // _generateRandomMapFromIterable(Reg16.values, 256 * 256).forEach((r, v) {
    //   this.cpur.update16(r, v);
    // });
    // _generateRandomMapFromIterable(MemReg.values, 256).forEach((r, v) {
    //   this.mmu.pushMemReg(r, v);
    // });
  // }