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

import "package:ft/ft.dart" as Ft;

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
      if (_clockWait <= 0)
        _clockWait = _execInst();
      _clockWait--;
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
        data = 0; break;
      case (1):
        data = _mmu.pull8(this.cpur.PC + info.opCodeSize); break;
      case (2):
        data = _mmu.pull16(this.cpur.PC + info.opCodeSize); break;
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
    final op = _mmu.pull8(addr);
    if (op == 0xCB)
    {
      final opX = _mmu.pull8(addr + 1);
      return Instructions.instInfos_CB[opX];
    }
    else
      return Instructions.instInfos[op];
  }

  /* Instructions */

  int _execInst(){
    final op = _mmu.pull8(this.cpur.PC);
    switch (op) {
      case (0x00) : return _NOP();                             //  NOP
      case (0x01) : this.cpur.PC += 1; return 1;               //  LD BC, d16
      case (0x02) : this.cpur.PC += 1; return 1;               //  LD (BC), A
      case (0x03) : this.cpur.PC += 1; return 1;               //  INC BC
      case (0x04) : this.cpur.PC += 1; return 1;               //  INC B
      case (0x05) : this.cpur.PC += 1; return 1;               //  DEC B
      case (0x06) : this.cpur.PC += 1; return 1;               //  LD B, d8
      case (0x07) : this.cpur.PC += 1; return 1;               //  RLCA

      case (0x08) : this.cpur.PC += 1; return 1;               //  LD (nn), SP
      case (0x09) : this.cpur.PC += 1; return 1;               //  ADD HL, BC
      case (0x0A) : this.cpur.PC += 1; return 1;               //  LD A, (BC)
      case (0x0B) : this.cpur.PC += 1; return 1;               //  DEC BC
      case (0x0C) : this.cpur.PC += 1; return 1;               //  INC C
      case (0x0D) : this.cpur.PC += 1; return 1;               //  DEC C
      case (0x0E) : this.cpur.PC += 1; return 1;               //  LD C, d8
      case (0x0F) : this.cpur.PC += 1; return 1;               //  RRCA

      case (0x10) : this.cpur.PC += 1; return 1;               //  STOP 0
      case (0x11) : this.cpur.PC += 1; return 1;               //  LD DE, d16
      case (0x12) : this.cpur.PC += 1; return 1;               //  LD (DE), A
      case (0x13) : this.cpur.PC += 1; return 1;               //  INC DE
      case (0x14) : this.cpur.PC += 1; return 1;               //  INC D
      case (0x15) : this.cpur.PC += 1; return 1;               //  DEC D
      case (0x16) : this.cpur.PC += 1; return 1;               //  LD D, d8
      case (0x17) : this.cpur.PC += 1; return 1;               //  RLA

      case (0x18) : return _JR_e();                            //  JR e
      case (0x19) : this.cpur.PC += 1; return 1;               //  ADD HL, DE
      case (0x1A) : this.cpur.PC += 1; return 1;               //  LD A, (DE)
      case (0x1B) : this.cpur.PC += 1; return 1;               //  DEC DE
      case (0x1C) : this.cpur.PC += 1; return 1;               //  INC E
      case (0x1D) : this.cpur.PC += 1; return 1;               //  DEC E
      case (0x1E) : this.cpur.PC += 1; return 1;               //  LD E, d8
      case (0x1F) : this.cpur.PC += 1; return 1;               //  RRA

      case (0x20) : return _JR_NZ_e();                         //  JR NZ, e
      case (0x21) : this.cpur.PC += 1; return 1;               //  LD HL, d16
      case (0x22) : this.cpur.PC += 1; return 1;               //  LD (HL+), A
      case (0x23) : this.cpur.PC += 1; return 1;               //  INC HL
      case (0x24) : this.cpur.PC += 1; return 1;               //  INC H
      case (0x25) : this.cpur.PC += 1; return 1;               //  DEC H
      case (0x26) : this.cpur.PC += 1; return 1;               //  LD H, d8
      case (0x27) : this.cpur.PC += 1; return 1;               //  DAA

      case (0x28) : return _JR_Z_e();                          //  JR Z, e
      case (0x29) : this.cpur.PC += 1; return 1;               //  ADD HL, HL
      case (0x2A) : this.cpur.PC += 1; return 1;               //  LD A, (HL+)
      case (0x2B) : this.cpur.PC += 1; return 1;               //  DEC HL
      case (0x2C) : this.cpur.PC += 1; return 1;               //  INC L
      case (0x2D) : this.cpur.PC += 1; return 1;               //  DEC L
      case (0x2E) : this.cpur.PC += 1; return 1;               //  LD L, d8
      case (0x2F) : this.cpur.PC += 1; return 1;               //  CPL

      case (0x30) : return _JR_NC_e();                         //  JR NC, e
      case (0x31) : this.cpur.PC += 1; return 1;               //  LD SP, d16
      case (0x32) : this.cpur.PC += 1; return 1;               //  LD (HL-), A
      case (0x33) : this.cpur.PC += 1; return 1;               //  INC SP
      case (0x34) : this.cpur.PC += 1; return 1;               //  INC (HL)
      case (0x35) : this.cpur.PC += 1; return 1;               //  DEC (HL)
      case (0x36) : this.cpur.PC += 1; return 1;               //  LD (HL), d8
      case (0x37) : this.cpur.PC += 1; return 1;               //  SCF

      case (0x38) : return _JR_C_e();                           //  JR C, e
      case (0x39) : this.cpur.PC += 1; return 1;               //  ADD HL, SP
      case (0x3A) : this.cpur.PC += 1; return 1;               //  LD A, (HL-)
      case (0x3B) : this.cpur.PC += 1; return 1;               //  DEC SP
      case (0x3C) : this.cpur.PC += 1; return 1;               //  INC A
      case (0x3D) : this.cpur.PC += 1; return 1;               //  DEC A
      case (0x3E) : this.cpur.PC += 1; return 1;               //  LD A, d8
      case (0x3F) : this.cpur.PC += 1; return 1;               //  CCF

      case (0x40) : this.cpur.PC += 1; return 1;               //  LD B, B
      case (0x41) : this.cpur.PC += 1; return 1;               //  LD B, C
      case (0x42) : this.cpur.PC += 1; return 1;               //  LD B, D
      case (0x43) : this.cpur.PC += 1; return 1;               //  LD B, E
      case (0x44) : this.cpur.PC += 1; return 1;               //  LD B, H
      case (0x45) : this.cpur.PC += 1; return 1;               //  LD B, L
      case (0x46) : this.cpur.PC += 1; return 1;               //  LD B, (HL)
      case (0x47) : this.cpur.PC += 1; return 1;               //  LD B, A

      case (0x48) : this.cpur.PC += 1; return 1;               //  LD C, B
      case (0x49) : this.cpur.PC += 1; return 1;               //  LD C, C
      case (0x4A) : this.cpur.PC += 1; return 1;               //  LD C, D
      case (0x4B) : this.cpur.PC += 1; return 1;               //  LD C, E
      case (0x4C) : this.cpur.PC += 1; return 1;               //  LD C, H
      case (0x4D) : this.cpur.PC += 1; return 1;               //  LD C, L
      case (0x4E) : this.cpur.PC += 1; return 1;               //  LD C, (HL)
      case (0x4F) : this.cpur.PC += 1; return 1;               //  LD C, A

      case (0x50) : this.cpur.PC += 1; return 1;               //  LD D, B
      case (0x51) : this.cpur.PC += 1; return 1;               //  LD D, C
      case (0x52) : this.cpur.PC += 1; return 1;               //  LD D, D
      case (0x53) : this.cpur.PC += 1; return 1;               //  LD D, E
      case (0x54) : this.cpur.PC += 1; return 1;               //  LD D, H
      case (0x55) : this.cpur.PC += 1; return 1;               //  LD D, L
      case (0x56) : this.cpur.PC += 1; return 1;               //  LD D, (HL)
      case (0x57) : this.cpur.PC += 1; return 1;               //  LD D, A

      case (0x58) : this.cpur.PC += 1; return 1;               //  LD E, B
      case (0x59) : this.cpur.PC += 1; return 1;               //  LD E, C
      case (0x5A) : this.cpur.PC += 1; return 1;               //  LD E, D
      case (0x5B) : this.cpur.PC += 1; return 1;               //  LD E, E
      case (0x5C) : this.cpur.PC += 1; return 1;               //  LD E, H
      case (0x5D) : this.cpur.PC += 1; return 1;               //  LD E, L
      case (0x5E) : this.cpur.PC += 1; return 1;               //  LD E, (HL)
      case (0x5F) : this.cpur.PC += 1; return 1;               //  LD E, A

      case (0x60) : this.cpur.PC += 1; return 1;               //  LD H, B
      case (0x61) : this.cpur.PC += 1; return 1;               //  LD H, C
      case (0x62) : this.cpur.PC += 1; return 1;               //  LD H, D
      case (0x63) : this.cpur.PC += 1; return 1;               //  LD H, E
      case (0x64) : this.cpur.PC += 1; return 1;               //  LD H, H
      case (0x65) : this.cpur.PC += 1; return 1;               //  LD H, L
      case (0x66) : this.cpur.PC += 1; return 1;               //  LD H, (HL)
      case (0x67) : this.cpur.PC += 1; return 1;               //  LD H, A

      case (0x68) : this.cpur.PC += 1; return 1;               //  LD L, B
      case (0x69) : this.cpur.PC += 1; return 1;               //  LD L, C
      case (0x6A) : this.cpur.PC += 1; return 1;               //  LD L, D
      case (0x6B) : this.cpur.PC += 1; return 1;               //  LD L, E
      case (0x6C) : this.cpur.PC += 1; return 1;               //  LD L, H
      case (0x6D) : this.cpur.PC += 1; return 1;               //  LD L, L
      case (0x6E) : this.cpur.PC += 1; return 1;               //  LD L, (HL)
      case (0x6F) : this.cpur.PC += 1; return 1;               //  LD L, A

      case (0x70) : this.cpur.PC += 1; return 1;               //  LD (HL), B
      case (0x71) : this.cpur.PC += 1; return 1;               //  LD (HL), C
      case (0x72) : this.cpur.PC += 1; return 1;               //  LD (HL), D
      case (0x73) : this.cpur.PC += 1; return 1;               //  LD (HL), E
      case (0x74) : this.cpur.PC += 1; return 1;               //  LD (HL), H
      case (0x75) : this.cpur.PC += 1; return 1;               //  LD (HL), L
      case (0x76) : this.cpur.PC += 1; return 1;               //  HALT
      case (0x77) : this.cpur.PC += 1; return 1;               //  LD (HL), A

      case (0x78) : this.cpur.PC += 1; return 1;               //  LD A, B
      case (0x79) : this.cpur.PC += 1; return 1;               //  LD A, C
      case (0x7A) : this.cpur.PC += 1; return 1;               //  LD A, D
      case (0x7B) : this.cpur.PC += 1; return 1;               //  LD A, E
      case (0x7C) : this.cpur.PC += 1; return 1;               //  LD A, H
      case (0x7D) : this.cpur.PC += 1; return 1;               //  LD A, L
      case (0x7E) : this.cpur.PC += 1; return 1;               //  LD A, (HL)
      case (0x7F) : this.cpur.PC += 1; return 1;               //  LD A, A

      case (0x80) : return _ADD_r(Reg8.B);                     //  ADD A, B
      case (0x81) : return _ADD_r(Reg8.C);                     //  ADD A, C
      case (0x82) : return _ADD_r(Reg8.D);                     //  ADD A, D
      case (0x83) : return _ADD_r(Reg8.E);                     //  ADD A, E
      case (0x84) : return _ADD_r(Reg8.H);                     //  ADD A, H
      case (0x85) : return _ADD_r(Reg8.L);                     //  ADD A, L
      case (0x86) : return _ADD_HL();                          //  ADD A, (HL)
      case (0x87) : return _ADD_r(Reg8.A);                     //  ADD A, A

      case (0x88) : return _ADC_r(Reg8.B);                     //  ADC A, B
      case (0x89) : return _ADC_r(Reg8.C);                     //  ADC A, C
      case (0x8A) : return _ADC_r(Reg8.D);                     //  ADC A, D
      case (0x8B) : return _ADC_r(Reg8.E);                     //  ADC A, E
      case (0x8C) : return _ADC_r(Reg8.H);                     //  ADC A, H
      case (0x8D) : return _ADC_r(Reg8.L);                     //  ADC A, L
      case (0x8E) : return _ADC_HL();                          //  ADC A, (HL)
      case (0x8F) : return _ADC_r(Reg8.A);                     //  ADC A, A

      case (0x90) : this.cpur.PC += 1; return 1;               //  SUB B
      case (0x91) : this.cpur.PC += 1; return 1;               //  SUB C
      case (0x92) : this.cpur.PC += 1; return 1;               //  SUB D
      case (0x93) : this.cpur.PC += 1; return 1;               //  SUB E
      case (0x94) : this.cpur.PC += 1; return 1;               //  SUB H
      case (0x95) : this.cpur.PC += 1; return 1;               //  SUB L
      case (0x96) : this.cpur.PC += 1; return 1;               //  SUB (HL)
      case (0x97) : this.cpur.PC += 1; return 1;               //  SUB A

      case (0x98) : this.cpur.PC += 1; return 1;               //  SBC A, B
      case (0x99) : this.cpur.PC += 1; return 1;               //  SBC A, C
      case (0x9A) : this.cpur.PC += 1; return 1;               //  SBC A, D
      case (0x9B) : this.cpur.PC += 1; return 1;               //  SBC A, E
      case (0x9C) : this.cpur.PC += 1; return 1;               //  SBC A, H
      case (0x9D) : this.cpur.PC += 1; return 1;               //  SBC A, L
      case (0x9E) : this.cpur.PC += 1; return 1;               //  SBC A, (HL)
      case (0x9F) : this.cpur.PC += 1; return 1;               //  SBC A, A

      case (0xA0) : return _AND_r(Reg8.B);                     //  AND B
      case (0xA1) : return _AND_r(Reg8.C);                     //  AND C
      case (0xA2) : return _AND_r(Reg8.D);                     //  AND D
      case (0xA3) : return _AND_r(Reg8.E);                     //  AND E
      case (0xA4) : return _AND_r(Reg8.H);                     //  AND H
      case (0xA5) : return _AND_r(Reg8.L);                     //  AND L
      case (0xA6) : return _AND_HL();                          //  AND (HL)
      case (0xA7) : return _AND_r(Reg8.A);                     //  AND A

      case (0xA8) : return _XOR_r(Reg8.B);                     //  XOR B
      case (0xA9) : return _XOR_r(Reg8.C);                     //  XOR C
      case (0xAA) : return _XOR_r(Reg8.D);                     //  XOR D
      case (0xAB) : return _XOR_r(Reg8.E);                     //  XOR E
      case (0xAC) : return _XOR_r(Reg8.H);                     //  XOR H
      case (0xAD) : return _XOR_r(Reg8.L);                     //  XOR L
      case (0xAE) : return _XOR_HL();                          //  XOR (HL)
      case (0xAF) : return _XOR_r(Reg8.A);                     //  XOR A

      case (0xB0) : return _OR_r(Reg8.B);                      //  OR B
      case (0xB1) : return _OR_r(Reg8.C);                      //  OR C
      case (0xB2) : return _OR_r(Reg8.D);                      //  OR D
      case (0xB3) : return _OR_r(Reg8.E);                      //  OR E
      case (0xB4) : return _OR_r(Reg8.H);                      //  OR H
      case (0xB5) : return _OR_r(Reg8.L);                      //  OR L
      case (0xB6) : return _OR_HL();                           //  OR (HL)
      case (0xB7) : return _OR_r(Reg8.A);                      //  OR A

      case (0xB8) : this.cpur.PC += 1; return 1;               //  CP B
      case (0xB9) : this.cpur.PC += 1; return 1;               //  CP C
      case (0xBA) : this.cpur.PC += 1; return 1;               //  CP D
      case (0xBB) : this.cpur.PC += 1; return 1;               //  CP E
      case (0xBC) : this.cpur.PC += 1; return 1;               //  CP H
      case (0xBD) : this.cpur.PC += 1; return 1;               //  CP L
      case (0xBE) : this.cpur.PC += 1; return 1;               //  CP (HL)
      case (0xBF) : this.cpur.PC += 1; return 1;               //  CP A

      case (0xC0) : this.cpur.PC += 1; return 1;               //  RET NZ
      case (0xC1) : this.cpur.PC += 1; return 1;               //  POP BC
      case (0xC2) : return _JP_NZ_nn();                        //  JP NZ, nn
      case (0xC3) : return _JP_nn();                           //  JP nn
      case (0xC4) : return _CALL_NZ_nn();                      //  CALL NZ, nn
      case (0xC5) : this.cpur.PC += 1; return 1;               //  PUSH BC
      case (0xC6) : this.cpur.PC += 1; return 1;               //  ADD A, d8
      case (0xC7) : return _RST_00H();                         //  RST 00H

      case (0xC8) : this.cpur.PC += 1; return 1;               //  RET Z
      case (0xC9) : this.cpur.PC += 1; return 1;               //  RET
      case (0xCA) : return _JP_Z_nn();                         //  JP Z, nn
      case (0xCB) : return _execInst_CB();                     //  0xCB: PREFIX
      case (0xCC) : return _CALL_Z_nn();                       //  CALL Z, nn
      case (0xCD) : return _CALL_nn();                         //  CALL nn
      case (0xCE) : this.cpur.PC += 1; return 1;               //  ADC A, d8
      case (0xCF) : return _RST_08H();                         //  RST 08H

      case (0xD0) : this.cpur.PC += 1; return 1;               //  RET NC
      case (0xD1) : this.cpur.PC += 1; return 1;               //  POP DE
      case (0xD2) : return _JP_NC_nn();                        //  JP NC, nn
      case (0xD3) : return _NOP();                             //  0xD3: N/A
      case (0xD4) : return _CALL_NC_nn();                      //  CALL NC, nn
      case (0xD5) : this.cpur.PC += 1; return 1;               //  PUSH DE
      case (0xD6) : this.cpur.PC += 1; return 1;               //  SUB d8
      case (0xD7) : return _RST_10H();                         //  RST 10H

      case (0xD8) : this.cpur.PC += 1; return 1;               //  RET C
      case (0xD9) : this.cpur.PC += 1; return 1;               //  RETI
      case (0xDA) : return _JP_C_nn();                         //  JP C, nn
      case (0xDB) : return _NOP();                             //  0xDB: N/A
      case (0xDC) : return _CALL_C_nn();                       //  CALL C, nn
      case (0xDD) : return _NOP();                             //  0xDD: N/A
      case (0xDE) : this.cpur.PC += 1; return 1;               //  SBC A, d8
      case (0xDF) : return _RST_18H();                         //  RST 18H

      case (0xE0) : this.cpur.PC += 1; return 1;               //  LDH (a8), A
      case (0xE1) : this.cpur.PC += 1; return 1;               //  POP HL
      case (0xE2) : this.cpur.PC += 1; return 1;               //  LD (C), A
      case (0xE3) : return _NOP();                             //  0xE3: N/A
      case (0xE4) : return _NOP();                             //  0xE4: N/A
      case (0xE5) : this.cpur.PC += 1; return 1;               //  PUSH HL
      case (0xE6) : this.cpur.PC += 1; return 1;               //  AND d8
      case (0xE7) : return _RST_20H();                         //  RST 20H

      case (0xE8) : this.cpur.PC += 1; return 1;               //  ADD SP, r8
      case (0xE9) : return _JP_HL();                           //  JP (HL)
      case (0xEA) : this.cpur.PC += 1; return 1;               //  LD (a16), A
      case (0xEB) : return _NOP();                             //  0xEB: N/A
      case (0xEC) : return _NOP();                             //  0xEC: N/A
      case (0xED) : return _NOP();                             //  0xED: N/A
      case (0xEE) : this.cpur.PC += 1; return 1;               //  XOR d8
      case (0xEF) : return _RST_28H();                         //  RST 28H

      case (0xF0) : this.cpur.PC += 1; return 1;               //  LDH A, (a8)
      case (0xF1) : this.cpur.PC += 1; return 1;               //  POP AF
      case (0xF2) : this.cpur.PC += 1; return 1;               //  LD A, (C)
      case (0xF3) : this.cpur.PC += 1; return 1;               //  DI
      case (0xF4) : return _NOP();                             //  0xF4: N/A
      case (0xF5) : this.cpur.PC += 1; return 1;               //  PUSH AF
      case (0xF6) : this.cpur.PC += 1; return 1;               //  OR d8
      case (0xF7) : return _RST_30H();                         //  RST 30H

      case (0xF8) : this.cpur.PC += 1; return 1;               //  LD HL, SP+r8
      case (0xF9) : this.cpur.PC += 1; return 1;               //  LD SP, HL
      case (0xFA) : this.cpur.PC += 1; return 1;               //  LD A, (a16)
      case (0xFB) : this.cpur.PC += 1; return 1;               //  EI
      case (0xFC) : return _NOP();                             //  0xFC: N/A
      case (0xFD) : return _NOP();                             //  0xFD: N/A
      case (0xFE) : this.cpur.PC += 1; return 1;               //  CP d8
      case (0xFF) : return _RST_38H();                         //  RST 38H
      default : break;
    }
    throw new Exception('z80: Opcode ${Ft.toAddressString(op, 4)} not suported');
  }

  /* Extended Instructions */

  int _execInst_CB(){
    final op = _mmu.pull8(this.cpur.PC + 1);
    switch (op) {
      case (0x00) : return _RLC(Reg8.B);         //  RLC B
      case (0x01) : return _RLC(Reg8.C);         //  RLC C
      case (0x02) : return _RLC(Reg8.D);         //  RLC D
      case (0x03) : return _RLC(Reg8.E);         //  RLC E
      case (0x04) : return _RLC(Reg8.H);         //  RLC H
      case (0x05) : return _RLC(Reg8.L);         //  RLC L
      case (0x06) : return _RLC_HL();            //  RLC (HL)
      case (0x07) : return _RLC(Reg8.A);         //  RLC A

      case (0x08) : return _RRC(Reg8.B);         //  RRC B
      case (0x09) : return _RRC(Reg8.C);         //  RRC C
      case (0x0A) : return _RRC(Reg8.D);         //  RRC D
      case (0x0B) : return _RRC(Reg8.E);         //  RRC E
      case (0x0C) : return _RRC(Reg8.H);         //  RRC H
      case (0x0D) : return _RRC(Reg8.L);         //  RRC L
      case (0x0E) : return _RRC_HL();            //  RRC (HL)
      case (0x0F) : return _RRC(Reg8.A);         //  RRC A

      case (0x10) : return _RL(Reg8.B);          //  RL B
      case (0x11) : return _RL(Reg8.C);          //  RL C
      case (0x12) : return _RL(Reg8.D);          //  RL D
      case (0x13) : return _RL(Reg8.E);          //  RL E
      case (0x14) : return _RL(Reg8.H);          //  RL H
      case (0x15) : return _RL(Reg8.L);          //  RL L
      case (0x16) : return _RL_HL();             //  RL (HL)
      case (0x17) : return _RL(Reg8.A);          //  RL A

      case (0x18) : return _RR(Reg8.B);          //  RR B
      case (0x19) : return _RR(Reg8.C);          //  RR C
      case (0x1A) : return _RR(Reg8.D);          //  RR D
      case (0x1B) : return _RR(Reg8.E);          //  RR E
      case (0x1C) : return _RR(Reg8.H);          //  RR H
      case (0x1D) : return _RR(Reg8.L);          //  RR L
      case (0x1E) : return _RR_HL();             //  RR (HL)
      case (0x1F) : return _RR(Reg8.A);          //  RR A

      case (0x20) : return _SLA(Reg8.B);         //  SLA B
      case (0x21) : return _SLA(Reg8.C);         //  SLA C
      case (0x22) : return _SLA(Reg8.D);         //  SLA D
      case (0x23) : return _SLA(Reg8.E);         //  SLA E
      case (0x24) : return _SLA(Reg8.H);         //  SLA H
      case (0x25) : return _SLA(Reg8.L);         //  SLA L
      case (0x26) : return _SLA_HL();            //  SLA (HL)
      case (0x27) : return _SLA(Reg8.A);         //  SLA A

      case (0x28) : return _SRA(Reg8.B);         //  SRA B
      case (0x29) : return _SRA(Reg8.C);         //  SRA C
      case (0x2A) : return _SRA(Reg8.D);         //  SRA D
      case (0x2B) : return _SRA(Reg8.E);         //  SRA E
      case (0x2C) : return _SRA(Reg8.H);         //  SRA H
      case (0x2D) : return _SRA(Reg8.L);         //  SRA L
      case (0x2E) : return _SRA_HL();            //  SRA (HL)
      case (0x2F) : return _SRA(Reg8.A);         //  SRA A

      case (0x30) : return _SWAP(Reg8.B);        //  SWAP B
      case (0x31) : return _SWAP(Reg8.C);        //  SWAP C
      case (0x32) : return _SWAP(Reg8.D);        //  SWAP D
      case (0x33) : return _SWAP(Reg8.E);        //  SWAP E
      case (0x34) : return _SWAP(Reg8.H);        //  SWAP H
      case (0x35) : return _SWAP(Reg8.L);        //  SWAP L
      case (0x36) : return _SWAP_HL();           //  SWAP (HL)
      case (0x37) : return _SWAP(Reg8.A);        //  SWAP A

      case (0x38) : return _SRL(Reg8.B);         //  SRL B
      case (0x39) : return _SRL(Reg8.C);         //  SRL C
      case (0x3A) : return _SRL(Reg8.D);         //  SRL D
      case (0x3B) : return _SRL(Reg8.E);         //  SRL E
      case (0x3C) : return _SRL(Reg8.H);         //  SRL H
      case (0x3D) : return _SRL(Reg8.L);         //  SRL L
      case (0x3E) : return _SRL_HL();            //  SRL (HL)
      case (0x3F) : return _SRL(Reg8.A);         //  SRL A

      case (0x40) : return _BIT(   0, Reg8.B);   //  BIT 0, B
      case (0x41) : return _BIT(   0, Reg8.C);   //  BIT 0, C
      case (0x42) : return _BIT(   0, Reg8.D);   //  BIT 0, D
      case (0x43) : return _BIT(   0, Reg8.E);   //  BIT 0, E
      case (0x44) : return _BIT(   0, Reg8.H);   //  BIT 0, H
      case (0x45) : return _BIT(   0, Reg8.L);   //  BIT 0, L
      case (0x46) : return _BIT_HL(0);           //  BIT 0, (HL)
      case (0x47) : return _BIT(   0, Reg8.A);   //  BIT 0, A

      case (0x48) : return _BIT(   1, Reg8.B);   //  BIT 1, B
      case (0x49) : return _BIT(   1, Reg8.C);   //  BIT 1, C
      case (0x4A) : return _BIT(   1, Reg8.D);   //  BIT 1, D
      case (0x4B) : return _BIT(   1, Reg8.E);   //  BIT 1, E
      case (0x4C) : return _BIT(   1, Reg8.H);   //  BIT 1, H
      case (0x4D) : return _BIT(   1, Reg8.L);   //  BIT 1, L
      case (0x4E) : return _BIT_HL(1);           //  BIT 1, (HL)
      case (0x4F) : return _BIT(   1, Reg8.A);   //  BIT 1, A

      case (0x50) : return _BIT(   2, Reg8.B);   //  BIT 2, B
      case (0x51) : return _BIT(   2, Reg8.C);   //  BIT 2, C
      case (0x52) : return _BIT(   2, Reg8.D);   //  BIT 2, D
      case (0x53) : return _BIT(   2, Reg8.E);   //  BIT 2, E
      case (0x54) : return _BIT(   2, Reg8.H);   //  BIT 2, H
      case (0x55) : return _BIT(   2, Reg8.L);   //  BIT 2, L
      case (0x56) : return _BIT_HL(2);           //  BIT 2, (HL)
      case (0x57) : return _BIT(   2, Reg8.A);   //  BIT 2, A

      case (0x58) : return _BIT(   3, Reg8.B);   //  BIT 3, B
      case (0x59) : return _BIT(   3, Reg8.C);   //  BIT 3, C
      case (0x5A) : return _BIT(   3, Reg8.D);   //  BIT 3, D
      case (0x5B) : return _BIT(   3, Reg8.E);   //  BIT 3, E
      case (0x5C) : return _BIT(   3, Reg8.H);   //  BIT 3, H
      case (0x5D) : return _BIT(   3, Reg8.L);   //  BIT 3, L
      case (0x5E) : return _BIT_HL(3);           //  BIT 3, (HL)
      case (0x5F) : return _BIT(   3, Reg8.A);   //  BIT 3, A

      case (0x60) : return _BIT(   4, Reg8.B);   //  BIT 4, B
      case (0x61) : return _BIT(   4, Reg8.C);   //  BIT 4, C
      case (0x62) : return _BIT(   4, Reg8.D);   //  BIT 4, D
      case (0x63) : return _BIT(   4, Reg8.E);   //  BIT 4, E
      case (0x64) : return _BIT(   4, Reg8.H);   //  BIT 4, H
      case (0x65) : return _BIT(   4, Reg8.L);   //  BIT 4, L
      case (0x66) : return _BIT_HL(4);           //  BIT 4, (HL)
      case (0x67) : return _BIT(   4, Reg8.A);   //  BIT 4, A

      case (0x68) : return _BIT(   5, Reg8.B);   //  BIT 5, B
      case (0x69) : return _BIT(   5, Reg8.C);   //  BIT 5, C
      case (0x6A) : return _BIT(   5, Reg8.D);   //  BIT 5, D
      case (0x6B) : return _BIT(   5, Reg8.E);   //  BIT 5, E
      case (0x6C) : return _BIT(   5, Reg8.H);   //  BIT 5, H
      case (0x6D) : return _BIT(   5, Reg8.L);   //  BIT 5, L
      case (0x6E) : return _BIT_HL(5);           //  BIT 5, (HL)
      case (0x6F) : return _BIT(   5, Reg8.A);   //  BIT 5, A

      case (0x70) : return _BIT(   6, Reg8.B);   //  BIT 6, B
      case (0x71) : return _BIT(   6, Reg8.C);   //  BIT 6, C
      case (0x72) : return _BIT(   6, Reg8.D);   //  BIT 6, D
      case (0x73) : return _BIT(   6, Reg8.E);   //  BIT 6, E
      case (0x74) : return _BIT(   6, Reg8.H);   //  BIT 6, H
      case (0x75) : return _BIT(   6, Reg8.L);   //  BIT 6, L
      case (0x76) : return _BIT_HL(6);           //  BIT 6, (HL)
      case (0x77) : return _BIT(   6, Reg8.A);   //  BIT 6, A

      case (0x78) : return _BIT(   7, Reg8.B);   //  BIT 7, B
      case (0x79) : return _BIT(   7, Reg8.C);   //  BIT 7, C
      case (0x7A) : return _BIT(   7, Reg8.D);   //  BIT 7, D
      case (0x7B) : return _BIT(   7, Reg8.E);   //  BIT 7, E
      case (0x7C) : return _BIT(   7, Reg8.H);   //  BIT 7, H
      case (0x7D) : return _BIT(    7, Reg8.L);  //  BIT 7, L
      case (0x7E) : return _BIT_HL(7);           //  BIT 7, (HL)
      case (0x7F) : return _BIT(   7, Reg8.A);   //  BIT 7, A

      case (0x80) : return _RES(   0, Reg8.B);   //  RES 0, B
      case (0x81) : return _RES(   0, Reg8.C);   //  RES 0, C
      case (0x82) : return _RES(   0, Reg8.D);   //  RES 0, D
      case (0x83) : return _RES(   0, Reg8.E);   //  RES 0, E
      case (0x84) : return _RES(   0, Reg8.H);   //  RES 0, H
      case (0x85) : return _RES(   0, Reg8.L);   //  RES 0, L
      case (0x86) : return _RES_HL(0);           //  RES 0, (HL)
      case (0x87) : return _RES(   0, Reg8.A);   //  RES 0, A

      case (0x88) : return _RES(   1, Reg8.B);   //  RES 1, B
      case (0x89) : return _RES(   1, Reg8.C);   //  RES 1, C
      case (0x8A) : return _RES(   1, Reg8.D);   //  RES 1, D
      case (0x8B) : return _RES(   1, Reg8.E);   //  RES 1, E
      case (0x8C) : return _RES(   1, Reg8.H);   //  RES 1, H
      case (0x8D) : return _RES(   1, Reg8.L);   //  RES 1, L
      case (0x8E) : return _RES_HL(1);           //  RES 1, (HL)
      case (0x8F) : return _RES(   1, Reg8.A);   //  RES 1, A

      case (0x90) : return _RES(   2, Reg8.B);   //  RES 2, B
      case (0x91) : return _RES(   2, Reg8.C);   //  RES 2, C
      case (0x92) : return _RES(   2, Reg8.D);   //  RES 2, D
      case (0x93) : return _RES(   2, Reg8.E);   //  RES 2, E
      case (0x94) : return _RES(   2, Reg8.H);   //  RES 2, H
      case (0x95) : return _RES(   2, Reg8.L);   //  RES 2, L
      case (0x96) : return _RES_HL(2);           //  RES 2, (HL)
      case (0x97) : return _RES(   2, Reg8.A);   //  RES 2, A

      case (0x98) : return _RES(   3, Reg8.B);   //  RES 3, B
      case (0x99) : return _RES(   3, Reg8.C);   //  RES 3, C
      case (0x9A) : return _RES(   3, Reg8.D);   //  RES 3, D
      case (0x9B) : return _RES(   3, Reg8.E);   //  RES 3, E
      case (0x9C) : return _RES(   3, Reg8.H);   //  RES 3, H
      case (0x9D) : return _RES(   3, Reg8.L);   //  RES 3, L
      case (0x9E) : return _RES_HL(3);           //  RES 3, (HL)
      case (0x9F) : return _RES(   3, Reg8.A);   //  RES 3, A

      case (0xA0) : return _RES(   4, Reg8.B);   //  RES 4, B
      case (0xA1) : return _RES(   4, Reg8.C);   //  RES 4, C
      case (0xA2) : return _RES(   4, Reg8.D);   //  RES 4, D
      case (0xA3) : return _RES(   4, Reg8.E);   //  RES 4, E
      case (0xA4) : return _RES(   4, Reg8.H);   //  RES 4, H
      case (0xA5) : return _RES(   4, Reg8.L);   //  RES 4, L
      case (0xA6) : return _RES_HL(4);           //  RES 4, (HL)
      case (0xA7) : return _RES(   4, Reg8.A);   //  RES 4, A

      case (0xA8) : return _RES(   5, Reg8.B);   //  RES 5, B
      case (0xA9) : return _RES(   5, Reg8.C);   //  RES 5, C
      case (0xAA) : return _RES(   5, Reg8.D);   //  RES 5, D
      case (0xAB) : return _RES(   5, Reg8.E);   //  RES 5, E
      case (0xAC) : return _RES(   5, Reg8.H);   //  RES 5, H
      case (0xAD) : return _RES(   5, Reg8.L);   //  RES 5, L
      case (0xAE) : return _RES_HL(5);           //  RES 5, (HL)
      case (0xAF) : return _RES(   5, Reg8.A);   //  RES 5, A

      case (0xB0) : return _RES(   6, Reg8.B);   //  RES 6, B
      case (0xB1) : return _RES(   6, Reg8.C);   //  RES 6, C
      case (0xB2) : return _RES(   6, Reg8.D);   //  RES 6, D
      case (0xB3) : return _RES(   6, Reg8.E);   //  RES 6, E
      case (0xB4) : return _RES(   6, Reg8.H);   //  RES 6, H
      case (0xB5) : return _RES(   6, Reg8.L);   //  RES 6, L
      case (0xB6) : return _RES_HL(6);           //  RES 6, (HL)
      case (0xB7) : return _RES(   6, Reg8.A);   //  RES 6, A

      case (0xB8) : return _RES(   7, Reg8.B);   //  RES 7, B
      case (0xB9) : return _RES(   7, Reg8.C);   //  RES 7, C
      case (0xBA) : return _RES(   7, Reg8.D);   //  RES 7, D
      case (0xBB) : return _RES(   7, Reg8.E);   //  RES 7, E
      case (0xBC) : return _RES(   7, Reg8.H);   //  RES 7, H
      case (0xBD) : return _RES(   7, Reg8.L);   //  RES 7, L
      case (0xBE) : return _RES_HL(7);           //  RES 7, (HL)
      case (0xBF) : return _RES(   7, Reg8.A);   //  RES 7, A

      case (0xC0) : return _SET(   0, Reg8.B);   //  SET 0, B
      case (0xC1) : return _SET(   0, Reg8.C);   //  SET 0, C
      case (0xC2) : return _SET(   0, Reg8.D);   //  SET 0, D
      case (0xC3) : return _SET(   0, Reg8.E);   //  SET 0, E
      case (0xC4) : return _SET(   0, Reg8.H);   //  SET 0, H
      case (0xC5) : return _SET(   0, Reg8.L);   //  SET 0, L
      case (0xC6) : return _SET_HL(0);           //  SET 6, (HL)
      case (0xC7) : return _SET(   0, Reg8.A);   //  SET 0, A

      case (0xC8) : return _SET(   1, Reg8.B);   //  SET 1, B
      case (0xC9) : return _SET(   1, Reg8.C);   //  SET 1, C
      case (0xCA) : return _SET(   1, Reg8.D);   //  SET 1, D
      case (0xCB) : return _SET(   1, Reg8.E);   //  SET 1, E
      case (0xCC) : return _SET(   1, Reg8.H);   //  SET 1, H
      case (0xCD) : return _SET(   1, Reg8.L);   //  SET 1, L
      case (0xCE) : return _SET_HL(1);           //  SET 6, (HL)
      case (0xCF) : return _SET(   1, Reg8.A);   //  SET 1, A

      case (0xD0) : return _SET(   2, Reg8.B);   //  SET 2, B
      case (0xD1) : return _SET(   2, Reg8.C);   //  SET 2, C
      case (0xD2) : return _SET(   2, Reg8.D);   //  SET 2, D
      case (0xD3) : return _SET(   2, Reg8.E);   //  SET 2, E
      case (0xD4) : return _SET(   2, Reg8.H);   //  SET 2, H
      case (0xD5) : return _SET(   2, Reg8.L);   //  SET 2, L
      case (0xD6) : return _SET_HL(2);           //  SET 6, (HL)
      case (0xD7) : return _SET(   2, Reg8.A);   //  SET 2, A

      case (0xD8) : return _SET(   3, Reg8.B);   //  SET 3, B
      case (0xD9) : return _SET(   3, Reg8.C);   //  SET 3, C
      case (0xDA) : return _SET(   3, Reg8.D);   //  SET 3, D
      case (0xDB) : return _SET(   3, Reg8.E);   //  SET 3, E
      case (0xDC) : return _SET(   3, Reg8.H);   //  SET 3, H
      case (0xDD) : return _SET(   3, Reg8.L);   //  SET 3, L
      case (0xDE) : return _SET_HL(3);           //  SET 6, (HL)
      case (0xDF) : return _SET(   3, Reg8.A);   //  SET 3, A

      case (0xE0) : return _SET(   4, Reg8.B);   //  SET 4, B
      case (0xE1) : return _SET(   4, Reg8.C);   //  SET 4, C
      case (0xE2) : return _SET(   4, Reg8.D);   //  SET 4, D
      case (0xE3) : return _SET(   4, Reg8.E);   //  SET 4, E
      case (0xE4) : return _SET(   4, Reg8.H);   //  SET 4, H
      case (0xE5) : return _SET(   4, Reg8.L);   //  SET 4, L
      case (0xE6) : return _SET_HL(4);           //  SET 6, (HL)
      case (0xE7) : return _SET(   4, Reg8.A);   //  SET 4, A

      case (0xE8) : return _SET(   5, Reg8.B);   //  SET 5, B
      case (0xE9) : return _SET(   5, Reg8.C);   //  SET 5, C
      case (0xEA) : return _SET(   5, Reg8.D);   //  SET 5, D
      case (0xEB) : return _SET(   5, Reg8.E);   //  SET 5, E
      case (0xEC) : return _SET(   5, Reg8.H);   //  SET 5, H
      case (0xED) : return _SET(   5, Reg8.L);   //  SET 5, L
      case (0xEE) : return _SET_HL(5);           //  SET 6, (HL)
      case (0xEF) : return _SET(   5, Reg8.A);   //  SET 5, A

      case (0xF0) : return _SET(   6, Reg8.B);   //  SET 6, B
      case (0xF1) : return _SET(   6, Reg8.C);   //  SET 6, C
      case (0xF2) : return _SET(   6, Reg8.D);   //  SET 6, D
      case (0xF3) : return _SET(   6, Reg8.E);   //  SET 6, E
      case (0xF4) : return _SET(   6, Reg8.H);   //  SET 6, H
      case (0xF5) : return _SET(   6, Reg8.L);   //  SET 6, L
      case (0xF6) : return _SET_HL(6);           //  SET 6, (HL)
      case (0xF7) : return _SET(   6, Reg8.A);   //  SET 6, A

      case (0xF8) : return _SET(   7, Reg8.B);   //  SET 7, B
      case (0xF9) : return _SET(   7, Reg8.C);   //  SET 7, C
      case (0xFA) : return _SET(   7, Reg8.D);   //  SET 7, D
      case (0xFB) : return _SET(   7, Reg8.E);   //  SET 7, E
      case (0xFC) : return _SET(   7, Reg8.H);   //  SET 7, H
      case (0xFD) : return _SET(   7, Reg8.L);   //  SET 7, L
      case (0xFE) : return _SET_HL(7);           //  SET 6, (HL)
      case (0xFF) : return _SET(   7, Reg8.A);   //  SET 7, A
      default : break;
    }
    throw new Exception('z80: CB Prefix: Opcode ${Ft.toAddressString(op, 4)} not suported');
  }

  /* 8-bits Loads *************************************************************/
  /* 16-bits Loads ************************************************************/



  /* 16-bits ALU **************************************************************/
  int _ADD16_calculate(int l, int r) {
    assert((l & ~0xFFFF == 0) && (r & ~0xFFFF == 0));
    final int calculated = l + r;
    final int result = calculated & 0xFFFF;
    this.cpur.cy = ((l + r) > 0xFFFF) ? 1 : 0;
    this.cpur.h = ((l & 0xFF) + (r & 0xFF) > 0xFF) ? 1 : 0;
    return result;
  }

  int _ADD_HL_r(Reg16 r) {
    final int val = this.cpur.pull16(r);
    this.cpur.HL = _ADD16_calculate(this.cpur.HL, val);
    this.cpur.n = 0;
    return 8;
  }

  int _ADD_SP_e() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    this.cpur.HL = _ADD16_calculate(this.cpur.HL, val);
    this.cpur.n = 0;
    this.cpur.z = 0;
    return 16;
  }

  int _INC_rr(Reg16 r) {
    final int val = this.cpur.pull16(r);
    final int res = (val + 1) & 0xFFFF;
    this.cpur.push16(r, res);
    return 8;
  }

  int _DEC_rr(Reg16 r) {
    final int val = this.cpur.pull16(r);
    final int res = (val - 1) & 0xFFFF;
    this.cpur.push16(r, res);
    return 8;
  }

  /* 8-bits ALU ***************************************************************/
  /* ADD **********************************************************************/
  int _ADD_calculate(int l, int r) {
    assert((l & ~0xFF == 0) && (r & ~0xFF == 0));
    final int calculated = l + r;
    final int result = calculated & 0xFF;
    this.cpur.cy = ((l + r) > 0xFF) ? 1 : 0;
    this.cpur.h = ((l & 0xF) + (r & 0xF) > 0xF) ? 1 : 0;
    this.cpur.n = 0;
    this.cpur.z = result;
    return result;
  }

  int _ADD_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    this.cpur.A = _ADD_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _ADD_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    this.cpur.A = _ADD_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _ADD_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    this.cpur.A = _ADD_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* ADC */
  int _ADC_r(Reg8 r) {
    final int val = this.cpur.pull8(r) + this.cpur.cy;
    this.cpur.A = _ADD_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _ADC_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1) + this.cpur.cy;
    this.cpur.A = _ADD_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _ADC_HL() {
    final int val = _mmu.pull8(this.cpur.HL) + this.cpur.cy;
    this.cpur.A = _ADD_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* INC */
  int _INC_r(Reg8 r) {
    final int cy_old = this.cpur.cy;
    final int val = this.cpur.pull8(r);
    final int res = _ADD_calculate(val, 1);
    this.cpur.push8(r, res);
    this.cpur.cy = cy_old;
    this.cpur.PC += 1;
    return 4;
  }

  int _INC_HL() {
    final int cy_old = this.cpur.cy;
    final int val = _mmu.pull8(this.cpur.HL);
    final int res = _ADD_calculate(val, 1);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.cy = cy_old;
    this.cpur.PC += 1;
    return 12;
  }

  /* SUB **********************************************************************/
  int _SUB_calculate(int l, int r) {
    assert((l & ~0xFF == 0) && (r & ~0xFF == 0));
    final int calculated = l - r;
    final int result = calculated & 0xFF;
    this.cpur.cy = (l < r) ? 1 : 0;
    this.cpur.h = ((l & 0xF) < (r & 0xF)) ? 1 : 0;
    this.cpur.n = 1;
    this.cpur.z = result;
    return result;
  }

  int _SUB_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    this.cpur.A = _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _SUB_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    this.cpur.A = _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _SUB_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    this.cpur.A = _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* SBC */
  int _SBC_r(Reg8 r) {
    final int val = this.cpur.pull8(r) + this.cpur.cy;
    this.cpur.A = _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _SBC_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1) + this.cpur.cy;
    this.cpur.A = _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _SBC_HL() {
    final int val = _mmu.pull8(this.cpur.HL) + this.cpur.cy;
    this.cpur.A = _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* DEC */
  int _DEC_r(Reg8 r) {
    final int cy_old = this.cpur.cy;
    final int val = this.cpur.pull8(r);
    final int res = _SUB_calculate(val, 1);
    this.cpur.push8(r, res);
    this.cpur.cy = cy_old;
    this.cpur.PC += 1;
    return 4;
  }

  int _DEC_HL() {
    final int cy_old = this.cpur.cy;
    final int val = _mmu.pull8(this.cpur.HL);
    final int res = _SUB_calculate(val, 1);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.cy = cy_old;
    this.cpur.PC += 1;
    return 12;
  }

  /* CP */
  int _CP_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _CP_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _CP_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    _SUB_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* Logic ********************************************************************/
  /* Logical AND */
  int _AND_calculate(int l, int r) {
    assert((l & ~0xFF == 0) && (r & ~0xFF == 0));
    final int calculated = l & r;
    final int result = calculated & 0xFF;
    this.cpur.cy = 0;
    this.cpur.h = 1;
    this.cpur.n = 0;
    this.cpur.z = result;
    return result;
  }

  int _AND_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    this.cpur.A = _AND_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _AND_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    this.cpur.A = _AND_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _AND_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    this.cpur.A = _AND_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* Logical OR */
  int _OR_calculate(int l, int r) {
    assert((l & ~0xFF == 0) && (r & ~0xFF == 0));
    final int calculated = l | r;
    final int result = calculated & 0xFF;
    this.cpur.cy = 0;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = result;
    return result;
  }

  int _OR_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    this.cpur.A = _OR_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _OR_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    this.cpur.A = _OR_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _OR_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    this.cpur.A = _OR_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* Logical XOR */
  int _XOR_calculate(int l, int r) {
    assert((l & ~0xFF == 0) && (r & ~0xFF == 0));
    final int calculated = l ^ r;
    final int result = calculated & 0xFF;
    this.cpur.cy = 0;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = result;
    return result;
  }

  int _XOR_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    this.cpur.A = _XOR_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _XOR_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    this.cpur.A = _XOR_calculate(this.cpur.A, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _XOR_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    this.cpur.A = _XOR_calculate(this.cpur.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* Miscellaneous ************************************************************/
  int _DAA() {
    assert(false, "DAA");
  }

  int _CPL() {
    this.cpur.A = (~this.cpur.A & 0xFF);
    this.cpur.h = 1;
    this.cpur.n = 1;
    return 4;
  }

  int _CCF() {
    this.cpur.cy = 1 - this.cpur.cy;
    this.n = 0;
    this.h = 0;
    return 4;
  }

  int _SCF() {
    this.cpur.cy = 1;
    this.n = 0;
    this.h = 0;
    return 4;
  }

  int _NOP() {
    this.cpur.PC += 1;
    return 4;
  }

  int _HALT() {
    assert(false, "HALT");
  }

  int _STOP() {
    assert(false, "STOP");
  }

  int _DI() {
    assert(false, "DI");
  }

  int _EI() {
    assert(false, "EI");
  }

  /* Rotates and Shifts *******************************************************/
  int _SL_calculate(int val, int newbit) {
    assert(val & ~0xFF == 0);
    assert(newbit & ~0x1 == 0);
    final int cy_new = val >> 7;
    final int val_new = ((val << 1) | newbit) & 0xFF;
    this.cpur.cy = cy_new;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = val_new;
    return val_new;
  }

  int _SR_calculate(int val, int newbit) {
    assert(val & ~0xFF == 0);
    assert(newbit & ~0x1 == 0);
    final int cy_new = val & 0x1;
    final int val_new = (val >> 1) | (newbit << 7);
    this.cpur.cy = cy_new;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = val_new;
    return val_new;
  }

  /* Accu */
  int _RLCA() {
    final val = this.cpur.pull8(Reg8.A);
    final newbit = val >> 7;
    final res = _SL_calculate(val, newbit);
    this.cpur.push8(Reg8.A, res);
    this.cpur.z = 0;
    this.cpur.PC += 1;
    return 4;
  }

  int _RLA() {
    final val = this.cpur.pull8(Reg8.A);
    final newbit = this.cpur.cy;
    final res = _SL_calculate(val, newbit);
    this.cpur.push8(Reg8.A, res);
    this.cpur.z = 0;
    this.cpur.PC += 1;
    return 4;
  }

  int _RRCA() {
    final val = this.cpur.pull8(Reg8.A);
    final newbit = val & 0x1;
    final res = _SR_calculate(val, newbit);
    this.cpur.push8(Reg8.A, res);
    this.cpur.z = 0;
    this.cpur.PC += 1;
    return 4;
  }

  int _RRA() {
    final val = this.cpur.pull8(Reg8.A);
    final newbit = this.cpur.cy;
    final res = _SR_calculate(val, newbit);
    this.cpur.push8(Reg8.A, res);
    this.cpur.z = 0;
    this.cpur.PC += 1;
    return 4;
  }

  /* Registers */
  int _RLC(Reg8 r) {
    final val = this.cpur.pull8(r);
    final newbit = val >> 7;
    final res = _SL_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _RL(Reg8 r) {
    final val = this.cpur.pull8(r);
    final newbit = this.cpur.cy;
    final res = _SL_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _RRC(Reg8 r) {
    final val = this.cpur.pull8(r);
    final newbit = val & 0x1;
    final res = _SR_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _RR(Reg8 r) {
    final val = this.cpur.pull8(r);
    final newbit = this.cpur.cy;
    final res = _SR_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _SLA(Reg8 r) { /* Shift Left: bit-0 is unset */
    final val = this.cpur.pull8(r);
    final newbit = 0;
    final res = _SL_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _SRL(Reg8 r) { /* Shift Right: bit-7 is unset */
    final val = this.cpur.pull8(r);
    final newbit = 0;
    final res = _SR_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _SRA(Reg8 r) { /* Shift Right but bit-7 is not changed */
    final val = this.cpur.pull8(r);
    final newbit = 0;
    final res = _SR_calculate(val, newbit);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  /* Memory */
  int _RLC_HL() {
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = val >> 7;
    final res = _SL_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  int _RL_HL() {
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = this.cpur.cy;
    final res = _SL_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  int _RRC_HL() {
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = val & 0x1;
    final res = _SR_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  int _RR_HL() {
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = this.cpur.cy;
    final res = _SR_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  int _SLA_HL() { /* Shift Left: bit-0 is unset */
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = 0;
    final res = _SL_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  int _SRL_HL() { /* Shift Right: bit-7 is unset */
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = 0;
    final res = _SR_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  int _SRA_HL() { /* Shift Right but bit-7 is not changed */
    final val = _mmu.pull8(this.cpur.HL);
    final newbit = 0;
    final res = _SR_calculate(val, newbit);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  /* SWAP */
  int _SWAP_calculate(int val) {
    assert(val & ~0xFF == 0);
    final int h = (val >> 4);
    final int l = (val & 0xFF);
    final int res = h | (l << 4);
    this.cpur.cy = 0;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = res;
    return res;
  }

  int _SWAP(Reg8 r){
    final int val = this.cpur.pull8(r);
    final int res = _SWAP_calculate(val);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _SWAP_HL(){
    final int val = _mmu.pull8(this.cpur.HL);
    final int res = _SWAP_calculate(val);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  /* Bit OpCode ***************************************************************/
  /* BIT */
  void _BIT_calculate(int index, int val) {
      assert(val & ~0xFF == 0);
      assert(index >= 0 && index < 8);
      final int b = ((val >> index) & 0x1);
      this.cpur.h = 1;
      this.cpur.n = 0;
      this.cpur.z = (1 - b);
      return ;
  }

  int _BIT(int index, Reg8 r) {
    final int val = this.cpur.pull8(r);
    _BIT_calculate(index, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _BIT_HL(int index) {
    final int val = _mmu.pull8(this.cpur.HL);
    _BIT_calculate(index, val);
    this.cpur.PC += 2;
    return 12;
  }

  /* SET */
  int _SET_calculate(int val, int index) {
    assert(val & ~0xFF == 0);
    assert(index >= 0 && index < 8);
    return (val | (0x1 << index));
  }

  int _SET(int index, Reg8 r) {
    final int val = this.cpur.pull8(r);
    final int res = _SET_calculate(val, index);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _SET_HL(int index) {
    final int val = _mmu.pull8(this.cpur.HL);
    final int res = _SET_calculate(val, index);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  /* RES */
  int _RES_calculate(int val, int index) {
    assert(val & ~0xFF == 0);
    assert(index >= 0 && index < 8);
    return (val & ~(0x1 << index));
  }

  int _RES(int index, Reg8 r) {
    final int val = this.cpur.pull8(r);
    final int res = _RES_calculate(val, index);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _RES_HL(int index) {
    final int val = _mmu.pull8(this.cpur.HL);
    final int res = _RES_calculate(val, index);
    _mmu.push8(this.cpur.HL, res);
    this.cpur.PC += 2;
    return 16;
  }

  /* Jumps ********************************************************************/
  /* 16 bit */
  int _JP_nn() {
    this.cpur.PC = _mmu.pull16(this.cpur.PC + 1);
    return 16;
  }

  int _JP_cc_nn(bool cc) {
    if (cc)
      return _JP_nn();
    else
    {
      this.cpur.PC += 3;
      return 12;
    }
  }

  int _JP_NZ_nn() { return  _JP_cc_nn(this.cpur.z == 0); }
  int _JP_Z_nn()  { return  _JP_cc_nn(this.cpur.z == 1); }
  int _JP_NC_nn() { return  _JP_cc_nn(this.cpur.cy == 0); }
  int _JP_C_nn()  { return  _JP_cc_nn(this.cpur.cy == 1); }

  int _JP_HL() {
    this.cpur.PC = _mmu.pull16(this.cpur.HL);
    return 4;
  }

  /* 8 bit */
  int _JR_e() {
    final int offset = _mmu.pull8(this.cpur.PC + 1).toSigned(8);
    this.cpur.PC += offset;
    return 12;
  }

  int _JR_cc_e(bool cc) {
    if (cc)
      return _JR_e();
    else
    {
      this.cpur.PC += 2;
      return 8;
    }
  }

  int _JR_NZ_e()  { return  _JR_cc_e(this.cpur.z == 0); }
  int _JR_Z_e()   { return  _JR_cc_e(this.cpur.z == 1); }
  int _JR_NC_e()  { return  _JR_cc_e(this.cpur.cy == 0); }
  int _JR_C_e()   { return  _JR_cc_e(this.cpur.cy == 1); }

  /* Calls ********************************************************************/
  int _CALL_nn()
  {
    final int addr = _mmu.pull16(this.cpur.PC + 1);
    _mmu.push16(this.cpur.SP - 2, this.cpur.PC + 3);
    this.cpur.PC = addr;
    this.cpur.SP -= 2;
    return 24;
  }

  int _CALL_cc_nn(bool cc)
  {
    if (cc)
      return _CALL_nn();
    else
    {
      this.cpur.PC += 3;
      return 12;
    }
  }

  int _CALL_NZ_nn()  { return  _CALL_cc_nn(this.cpur.z == 0); }
  int _CALL_Z_nn()   { return  _CALL_cc_nn(this.cpur.z == 1); }
  int _CALL_NC_nn()  { return  _CALL_cc_nn(this.cpur.cy == 0); }
  int _CALL_C_nn()   { return  _CALL_cc_nn(this.cpur.cy == 1); }

  /* Returns ******************************************************************/
  int _RET()
  {
    this.cpur.PC = _mmu.pull16(this.cpur.SP);
    this.cpur.SP += 2;
    return 16;
  }

  int _RET_cc(bool cc)
  {
    if (cc)
    {
      _RET();
      return 20 ;
    }
    else
    {
      this.cpur.PC += 3;
      return 8;
    }
  }

  int _RET_NZ() { return  _RET_cc(this.cpur.z == 0); }
  int _RET_Z()  { return  _RET_cc(this.cpur.z == 1); }
  int _RET_NC() { return  _RET_cc(this.cpur.cy == 0); }
  int _RET_C()  { return  _RET_cc(this.cpur.cy == 1); }

  int _RETI()
  {
    assert(false, "RETI");
  }

  /* Resets */
  int _RST_f(int low) {
    assert(low & ~0xFF == 0);
    _mmu.push16(this.cpur.SP - 2, this.cpur.PC + 1);
    this.cpur.SP -= 2;
    this.cpur.PC = low;
    return 16;
  }

  int _RST_00H() { return _RST_f(0x00); }
  int _RST_08H() { return _RST_f(0x08); }
  int _RST_10H() { return _RST_f(0x10); }
  int _RST_18H() { return _RST_f(0x18); }
  int _RST_20H() { return _RST_f(0x20); }
  int _RST_28H() { return _RST_f(0x28); }
  int _RST_30H() { return _RST_f(0x30); }
  int _RST_38H() { return _RST_f(0x38); }

}
