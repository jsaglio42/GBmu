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
  OpPrefix _prefix;
  int _clockWait;

  /*
  ** Constructors **************************************************************
  */

  Z80(Mmu.Mmu m) :
    this._mmu = m,
    this.cpur = new Cpuregs.CpuRegs(),
    _prefix = OpPrefix.None,
    _clockCount = 0,
    _clockWait = 0;
  
  Z80.clone(Z80 src) :
    this.mmu = src.mmu,
    this.cpur = new Cpuregs.clone(src.cpur),
    _prefix = src.prefix,
    _clockCount = src._clockCount,
    _clockWait = src._clockWait;

  /*
  ** API ***********************************************************************
  */

  int get clockCount => this._clockCount;

  void reset() {
    this.cpur.reset();
    _prefix = OpPrefix.None;
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
      {
        switch (_prefix)
        {
          case (OpPrefix.None) : _execInst(); break;
          case (OpPrefix.CB) : _execInst_CB(); break;
          default : assert(false);
        }
      }
    }
    return ;
  }

  /*
  ** Private ***********************************************************************
  */

  int _execInst() {
    final inst = _mmu.pullMem(cpur.PC, DataType.BYTE);
    final info = Instructions.instInfos[inst];
    bool s = true;
    switch (info.opCode)
    {
      case (0x00) : // (0x00, OpPrefix.None, 'NOP', 1, 4, 4, '- - - -')
        break;
      case (0x01) : // (0x01, OpPrefix.None, 'LD BC,d16', 3, 12, 12, '- - - -')
        break;
      case (0x02) : // (0x02, OpPrefix.None, 'LD (BC),A', 1, 8, 8, '- - - -')
        break;
      case (0x03) : // (0x03, OpPrefix.None, 'INC BC', 1, 8, 8, '- - - -')
        break;
      case (0x04) : // (0x04, OpPrefix.None, 'INC B', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x05) : // (0x05, OpPrefix.None, 'DEC B', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x06) : // (0x06, OpPrefix.None, 'LD B,d8', 2, 8, 8, '- - - -')
        break;
      case (0x07) : // (0x07, OpPrefix.None, 'RLCA', 1, 4, 4, '0 0 0 C')
        break;
      case (0x08) : // (0x08, OpPrefix.None, 'LD (a16),SP', 3, 20, 20, '- - - -')
        break;
      case (0x09) : // (0x09, OpPrefix.None, 'ADD HL,BC', 1, 8, 8, '- 0 H C')
        break;
      case (0x0A) : // (0x0A, OpPrefix.None, 'LD A,(BC)', 1, 8, 8, '- - - -')
        break;
      case (0x0B) : // (0x0B, OpPrefix.None, 'DEC BC', 1, 8, 8, '- - - -')
        break;
      case (0x0C) : // (0x0C, OpPrefix.None, 'INC C', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x0D) : // (0x0D, OpPrefix.None, 'DEC C', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x0E) : // (0x0E, OpPrefix.None, 'LD C,d8', 2, 8, 8, '- - - -')
        break;
      case (0x0F) : // (0x0F, OpPrefix.None, 'RRCA', 1, 4, 4, '0 0 0 C')
        break;
      case (0x10) : // (0x10, OpPrefix.None, 'STOP 0', 2, 4, 4, '- - - -')
        break;
      case (0x11) : // (0x11, OpPrefix.None, 'LD DE,d16', 3, 12, 12, '- - - -')
        break;
      case (0x12) : // (0x12, OpPrefix.None, 'LD (DE),A', 1, 8, 8, '- - - -')
        break;
      case (0x13) : // (0x13, OpPrefix.None, 'INC DE', 1, 8, 8, '- - - -')
        break;
      case (0x14) : // (0x14, OpPrefix.None, 'INC D', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x15) : // (0x15, OpPrefix.None, 'DEC D', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x16) : // (0x16, OpPrefix.None, 'LD D,d8', 2, 8, 8, '- - - -')
        break;
      case (0x17) : // (0x17, OpPrefix.None, 'RLA', 1, 4, 4, '0 0 0 C')
        break;
      case (0x18) : // (0x18, OpPrefix.None, 'JR r8', 2, 12, 12, '- - - -')
        break;
      case (0x19) : // (0x19, OpPrefix.None, 'ADD HL,DE', 1, 8, 8, '- 0 H C')
        break;
      case (0x1A) : // (0x1A, OpPrefix.None, 'LD A,(DE)', 1, 8, 8, '- - - -')
        break;
      case (0x1B) : // (0x1B, OpPrefix.None, 'DEC DE', 1, 8, 8, '- - - -')
        break;
      case (0x1C) : // (0x1C, OpPrefix.None, 'INC E', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x1D) : // (0x1D, OpPrefix.None, 'DEC E', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x1E) : // (0x1E, OpPrefix.None, 'LD E,d8', 2, 8, 8, '- - - -')
        break;
      case (0x1F) : // (0x1F, OpPrefix.None, 'RRA', 1, 4, 4, '0 0 0 C')
        break;
      case (0x20) : // (0x20, OpPrefix.None, 'JR NZ,r8', 2, 12, 8, '- - - -')
        break;
      case (0x21) : // (0x21, OpPrefix.None, 'LD HL,d16', 3, 12, 12, '- - - -')
        break;
      case (0x22) : // (0x22, OpPrefix.None, 'LD (HL+),A', 1, 8, 8, '- - - -')
        break;
      case (0x23) : // (0x23, OpPrefix.None, 'INC HL', 1, 8, 8, '- - - -')
        break;
      case (0x24) : // (0x24, OpPrefix.None, 'INC H', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x25) : // (0x25, OpPrefix.None, 'DEC H', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x26) : // (0x26, OpPrefix.None, 'LD H,d8', 2, 8, 8, '- - - -')
        break;
      case (0x27) : // (0x27, OpPrefix.None, 'DAA', 1, 4, 4, 'Z - 0 C')
        break;
      case (0x28) : // (0x28, OpPrefix.None, 'JR Z,r8', 2, 12, 8, '- - - -')
        break;
      case (0x29) : // (0x29, OpPrefix.None, 'ADD HL,HL', 1, 8, 8, '- 0 H C')
        break;
      case (0x2A) : // (0x2A, OpPrefix.None, 'LD A,(HL+)', 1, 8, 8, '- - - -')
        break;
      case (0x2B) : // (0x2B, OpPrefix.None, 'DEC HL', 1, 8, 8, '- - - -')
        break;
      case (0x2C) : // (0x2C, OpPrefix.None, 'INC L', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x2D) : // (0x2D, OpPrefix.None, 'DEC L', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x2E) : // (0x2E, OpPrefix.None, 'LD L,d8', 2, 8, 8, '- - - -')
        break;
      case (0x2F) : // (0x2F, OpPrefix.None, 'CPL', 1, 4, 4, '- 1 1 -')
        break;
      case (0x30) : // (0x30, OpPrefix.None, 'JR NC,r8', 2, 12, 8, '- - - -')
        break;
      case (0x31) : // (0x31, OpPrefix.None, 'LD SP,d16', 3, 12, 12, '- - - -')
        break;
      case (0x32) : // (0x32, OpPrefix.None, 'LD (HL-),A', 1, 8, 8, '- - - -')
        break;
      case (0x33) : // (0x33, OpPrefix.None, 'INC SP', 1, 8, 8, '- - - -')
        break;
      case (0x34) : // (0x34, OpPrefix.None, 'INC (HL)', 1, 12, 12, 'Z 0 H -')
        break;
      case (0x35) : // (0x35, OpPrefix.None, 'DEC (HL)', 1, 12, 12, 'Z 1 H -')
        break;
      case (0x36) : // (0x36, OpPrefix.None, 'LD (HL),d8', 2, 12, 12, '- - - -')
        break;
      case (0x37) : // (0x37, OpPrefix.None, 'SCF', 1, 4, 4, '- 0 0 1')
        break;
      case (0x38) : // (0x38, OpPrefix.None, 'JR C,r8', 2, 12, 8, '- - - -')
        break;
      case (0x39) : // (0x39, OpPrefix.None, 'ADD HL,SP', 1, 8, 8, '- 0 H C')
        break;
      case (0x3A) : // (0x3A, OpPrefix.None, 'LD A,(HL-)', 1, 8, 8, '- - - -')
        break;
      case (0x3B) : // (0x3B, OpPrefix.None, 'DEC SP', 1, 8, 8, '- - - -')
        break;
      case (0x3C) : // (0x3C, OpPrefix.None, 'INC A', 1, 4, 4, 'Z 0 H -')
        break;
      case (0x3D) : // (0x3D, OpPrefix.None, 'DEC A', 1, 4, 4, 'Z 1 H -')
        break;
      case (0x3E) : // (0x3E, OpPrefix.None, 'LD A,d8', 2, 8, 8, '- - - -')
        break;
      case (0x3F) : // (0x3F, OpPrefix.None, 'CCF', 1, 4, 4, '- 0 0 C')
        break;
      case (0x40) : // (0x40, OpPrefix.None, 'LD B,B', 1, 4, 4, '- - - -')
        break;
      case (0x41) : // (0x41, OpPrefix.None, 'LD B,C', 1, 4, 4, '- - - -')
        break;
      case (0x42) : // (0x42, OpPrefix.None, 'LD B,D', 1, 4, 4, '- - - -')
        break;
      case (0x43) : // (0x43, OpPrefix.None, 'LD B,E', 1, 4, 4, '- - - -')
        break;
      case (0x44) : // (0x44, OpPrefix.None, 'LD B,H', 1, 4, 4, '- - - -')
        break;
      case (0x45) : // (0x45, OpPrefix.None, 'LD B,L', 1, 4, 4, '- - - -')
        break;
      case (0x46) : // (0x46, OpPrefix.None, 'LD B,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x47) : // (0x47, OpPrefix.None, 'LD B,A', 1, 4, 4, '- - - -')
        break;
      case (0x48) : // (0x48, OpPrefix.None, 'LD C,B', 1, 4, 4, '- - - -')
        break;
      case (0x49) : // (0x49, OpPrefix.None, 'LD C,C', 1, 4, 4, '- - - -')
        break;
      case (0x4A) : // (0x4A, OpPrefix.None, 'LD C,D', 1, 4, 4, '- - - -')
        break;
      case (0x4B) : // (0x4B, OpPrefix.None, 'LD C,E', 1, 4, 4, '- - - -')
        break;
      case (0x4C) : // (0x4C, OpPrefix.None, 'LD C,H', 1, 4, 4, '- - - -')
        break;
      case (0x4D) : // (0x4D, OpPrefix.None, 'LD C,L', 1, 4, 4, '- - - -')
        break;
      case (0x4E) : // (0x4E, OpPrefix.None, 'LD C,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x4F) : // (0x4F, OpPrefix.None, 'LD C,A', 1, 4, 4, '- - - -')
        break;
      case (0x50) : // (0x50, OpPrefix.None, 'LD D,B', 1, 4, 4, '- - - -')
        break;
      case (0x51) : // (0x51, OpPrefix.None, 'LD D,C', 1, 4, 4, '- - - -')
        break;
      case (0x52) : // (0x52, OpPrefix.None, 'LD D,D', 1, 4, 4, '- - - -')
        break;
      case (0x53) : // (0x53, OpPrefix.None, 'LD D,E', 1, 4, 4, '- - - -')
        break;
      case (0x54) : // (0x54, OpPrefix.None, 'LD D,H', 1, 4, 4, '- - - -')
        break;
      case (0x55) : // (0x55, OpPrefix.None, 'LD D,L', 1, 4, 4, '- - - -')
        break;
      case (0x56) : // (0x56, OpPrefix.None, 'LD D,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x57) : // (0x57, OpPrefix.None, 'LD D,A', 1, 4, 4, '- - - -')
        break;
      case (0x58) : // (0x58, OpPrefix.None, 'LD E,B', 1, 4, 4, '- - - -')
        break;
      case (0x59) : // (0x59, OpPrefix.None, 'LD E,C', 1, 4, 4, '- - - -')
        break;
      case (0x5A) : // (0x5A, OpPrefix.None, 'LD E,D', 1, 4, 4, '- - - -')
        break;
      case (0x5B) : // (0x5B, OpPrefix.None, 'LD E,E', 1, 4, 4, '- - - -')
        break;
      case (0x5C) : // (0x5C, OpPrefix.None, 'LD E,H', 1, 4, 4, '- - - -')
        break;
      case (0x5D) : // (0x5D, OpPrefix.None, 'LD E,L', 1, 4, 4, '- - - -')
        break;
      case (0x5E) : // (0x5E, OpPrefix.None, 'LD E,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x5F) : // (0x5F, OpPrefix.None, 'LD E,A', 1, 4, 4, '- - - -')
        break;
      case (0x60) : // (0x60, OpPrefix.None, 'LD H,B', 1, 4, 4, '- - - -')
        break;
      case (0x61) : // (0x61, OpPrefix.None, 'LD H,C', 1, 4, 4, '- - - -')
        break;
      case (0x62) : // (0x62, OpPrefix.None, 'LD H,D', 1, 4, 4, '- - - -')
        break;
      case (0x63) : // (0x63, OpPrefix.None, 'LD H,E', 1, 4, 4, '- - - -')
        break;
      case (0x64) : // (0x64, OpPrefix.None, 'LD H,H', 1, 4, 4, '- - - -')
        break;
      case (0x65) : // (0x65, OpPrefix.None, 'LD H,L', 1, 4, 4, '- - - -')
        break;
      case (0x66) : // (0x66, OpPrefix.None, 'LD H,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x67) : // (0x67, OpPrefix.None, 'LD H,A', 1, 4, 4, '- - - -')
        break;
      case (0x68) : // (0x68, OpPrefix.None, 'LD L,B', 1, 4, 4, '- - - -')
        break;
      case (0x69) : // (0x69, OpPrefix.None, 'LD L,C', 1, 4, 4, '- - - -')
        break;
      case (0x6A) : // (0x6A, OpPrefix.None, 'LD L,D', 1, 4, 4, '- - - -')
        break;
      case (0x6B) : // (0x6B, OpPrefix.None, 'LD L,E', 1, 4, 4, '- - - -')
        break;
      case (0x6C) : // (0x6C, OpPrefix.None, 'LD L,H', 1, 4, 4, '- - - -')
        break;
      case (0x6D) : // (0x6D, OpPrefix.None, 'LD L,L', 1, 4, 4, '- - - -')
        break;
      case (0x6E) : // (0x6E, OpPrefix.None, 'LD L,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x6F) : // (0x6F, OpPrefix.None, 'LD L,A', 1, 4, 4, '- - - -')
        break;
      case (0x70) : // (0x70, OpPrefix.None, 'LD (HL),B', 1, 8, 8, '- - - -')
        break;
      case (0x71) : // (0x71, OpPrefix.None, 'LD (HL),C', 1, 8, 8, '- - - -')
        break;
      case (0x72) : // (0x72, OpPrefix.None, 'LD (HL),D', 1, 8, 8, '- - - -')
        break;
      case (0x73) : // (0x73, OpPrefix.None, 'LD (HL),E', 1, 8, 8, '- - - -')
        break;
      case (0x74) : // (0x74, OpPrefix.None, 'LD (HL),H', 1, 8, 8, '- - - -')
        break;
      case (0x75) : // (0x75, OpPrefix.None, 'LD (HL),L', 1, 8, 8, '- - - -')
        break;
      case (0x76) : // (0x76, OpPrefix.None, 'HALT', 1, 4, 4, '- - - -')
        break;
      case (0x77) : // (0x77, OpPrefix.None, 'LD (HL),A', 1, 8, 8, '- - - -')
        break;
      case (0x78) : // (0x78, OpPrefix.None, 'LD A,B', 1, 4, 4, '- - - -')
        break;
      case (0x79) : // (0x79, OpPrefix.None, 'LD A,C', 1, 4, 4, '- - - -')
        break;
      case (0x7A) : // (0x7A, OpPrefix.None, 'LD A,D', 1, 4, 4, '- - - -')
        break;
      case (0x7B) : // (0x7B, OpPrefix.None, 'LD A,E', 1, 4, 4, '- - - -')
        break;
      case (0x7C) : // (0x7C, OpPrefix.None, 'LD A,H', 1, 4, 4, '- - - -')
        break;
      case (0x7D) : // (0x7D, OpPrefix.None, 'LD A,L', 1, 4, 4, '- - - -')
        break;
      case (0x7E) : // (0x7E, OpPrefix.None, 'LD A,(HL)', 1, 8, 8, '- - - -')
        break;
      case (0x7F) : // (0x7F, OpPrefix.None, 'LD A,A', 1, 4, 4, '- - - -')
        break;
      case (0x80) : // (0x80, OpPrefix.None, 'ADD A,B', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x81) : // (0x81, OpPrefix.None, 'ADD A,C', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x82) : // (0x82, OpPrefix.None, 'ADD A,D', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x83) : // (0x83, OpPrefix.None, 'ADD A,E', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x84) : // (0x84, OpPrefix.None, 'ADD A,H', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x85) : // (0x85, OpPrefix.None, 'ADD A,L', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x86) : // (0x86, OpPrefix.None, 'ADD A,(HL)', 1, 8, 8, 'Z 0 H C')
        break;
      case (0x87) : // (0x87, OpPrefix.None, 'ADD A,A', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x88) : // (0x88, OpPrefix.None, 'ADC A,B', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x89) : // (0x89, OpPrefix.None, 'ADC A,C', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x8A) : // (0x8A, OpPrefix.None, 'ADC A,D', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x8B) : // (0x8B, OpPrefix.None, 'ADC A,E', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x8C) : // (0x8C, OpPrefix.None, 'ADC A,H', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x8D) : // (0x8D, OpPrefix.None, 'ADC A,L', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x8E) : // (0x8E, OpPrefix.None, 'ADC A,(HL)', 1, 8, 8, 'Z 0 H C')
        break;
      case (0x8F) : // (0x8F, OpPrefix.None, 'ADC A,A', 1, 4, 4, 'Z 0 H C')
        break;
      case (0x90) : // (0x90, OpPrefix.None, 'SUB B', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x91) : // (0x91, OpPrefix.None, 'SUB C', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x92) : // (0x92, OpPrefix.None, 'SUB D', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x93) : // (0x93, OpPrefix.None, 'SUB E', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x94) : // (0x94, OpPrefix.None, 'SUB H', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x95) : // (0x95, OpPrefix.None, 'SUB L', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x96) : // (0x96, OpPrefix.None, 'SUB (HL)', 1, 8, 8, 'Z 1 H C')
        break;
      case (0x97) : // (0x97, OpPrefix.None, 'SUB A', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x98) : // (0x98, OpPrefix.None, 'SBC A,B', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x99) : // (0x99, OpPrefix.None, 'SBC A,C', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x9A) : // (0x9A, OpPrefix.None, 'SBC A,D', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x9B) : // (0x9B, OpPrefix.None, 'SBC A,E', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x9C) : // (0x9C, OpPrefix.None, 'SBC A,H', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x9D) : // (0x9D, OpPrefix.None, 'SBC A,L', 1, 4, 4, 'Z 1 H C')
        break;
      case (0x9E) : // (0x9E, OpPrefix.None, 'SBC A,(HL)', 1, 8, 8, 'Z 1 H C')
        break;
      case (0x9F) : // (0x9F, OpPrefix.None, 'SBC A,A', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xA0) : // (0xA0, OpPrefix.None, 'AND B', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA1) : // (0xA1, OpPrefix.None, 'AND C', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA2) : // (0xA2, OpPrefix.None, 'AND D', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA3) : // (0xA3, OpPrefix.None, 'AND E', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA4) : // (0xA4, OpPrefix.None, 'AND H', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA5) : // (0xA5, OpPrefix.None, 'AND L', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA6) : // (0xA6, OpPrefix.None, 'AND (HL)', 1, 8, 8, 'Z 0 1 0')
        break;
      case (0xA7) : // (0xA7, OpPrefix.None, 'AND A', 1, 4, 4, 'Z 0 1 0')
        break;
      case (0xA8) : // (0xA8, OpPrefix.None, 'XOR B', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xA9) : // (0xA9, OpPrefix.None, 'XOR C', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xAA) : // (0xAA, OpPrefix.None, 'XOR D', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xAB) : // (0xAB, OpPrefix.None, 'XOR E', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xAC) : // (0xAC, OpPrefix.None, 'XOR H', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xAD) : // (0xAD, OpPrefix.None, 'XOR L', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xAE) : // (0xAE, OpPrefix.None, 'XOR (HL)', 1, 8, 8, 'Z 0 0 0')
        break;
      case (0xAF) : // (0xAF, OpPrefix.None, 'XOR A', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB0) : // (0xB0, OpPrefix.None, 'OR B', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB1) : // (0xB1, OpPrefix.None, 'OR C', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB2) : // (0xB2, OpPrefix.None, 'OR D', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB3) : // (0xB3, OpPrefix.None, 'OR E', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB4) : // (0xB4, OpPrefix.None, 'OR H', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB5) : // (0xB5, OpPrefix.None, 'OR L', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB6) : // (0xB6, OpPrefix.None, 'OR (HL)', 1, 8, 8, 'Z 0 0 0')
        break;
      case (0xB7) : // (0xB7, OpPrefix.None, 'OR A', 1, 4, 4, 'Z 0 0 0')
        break;
      case (0xB8) : // (0xB8, OpPrefix.None, 'CP B', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xB9) : // (0xB9, OpPrefix.None, 'CP C', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xBA) : // (0xBA, OpPrefix.None, 'CP D', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xBB) : // (0xBB, OpPrefix.None, 'CP E', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xBC) : // (0xBC, OpPrefix.None, 'CP H', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xBD) : // (0xBD, OpPrefix.None, 'CP L', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xBE) : // (0xBE, OpPrefix.None, 'CP (HL)', 1, 8, 8, 'Z 1 H C')
        break;
      case (0xBF) : // (0xBF, OpPrefix.None, 'CP A', 1, 4, 4, 'Z 1 H C')
        break;
      case (0xC0) : // (0xC0, OpPrefix.None, 'RET NZ', 1, 20, 8, '- - - -')
        break;
      case (0xC1) : // (0xC1, OpPrefix.None, 'POP BC', 1, 12, 12, '- - - -')
        break;
      case (0xC2) : // (0xC2, OpPrefix.None, 'JP NZ,a16', 3, 16, 12, '- - - -')
        break;
      case (0xC3) : // (0xC3, OpPrefix.None, 'JP a16', 3, 16, 16, '- - - -')
        break;
      case (0xC4) : // (0xC4, OpPrefix.None, 'CALL NZ,a16', 3, 24, 12, '- - - -')
        break;
      case (0xC5) : // (0xC5, OpPrefix.None, 'PUSH BC', 1, 16, 16, '- - - -')
        break;
      case (0xC6) : // (0xC6, OpPrefix.None, 'ADD A,d8', 2, 8, 8, 'Z 0 H C')
        break;
      case (0xC7) : // (0xC7, OpPrefix.None, 'RST 00H', 1, 16, 16, '- - - -')
        break;
      case (0xC8) : // (0xC8, OpPrefix.None, 'RET Z', 1, 20, 8, '- - - -')
        break;
      case (0xC9) : // (0xC9, OpPrefix.None, 'RET', 1, 16, 16, '- - - -')
        break;
      case (0xCA) : // (0xCA, OpPrefix.None, 'JP Z,a16', 3, 16, 12, '- - - -')
        break;
      case (0xCB) : // (0xCB, OpPrefix.None, '0xCB: PREFIX', 1, 4, 4, '- - - -')
        break;
      case (0xCC) : // (0xCC, OpPrefix.None, 'CALL Z,a16', 3, 24, 12, '- - - -')
        break;
      case (0xCD) : // (0xCD, OpPrefix.None, 'CALL a16', 3, 24, 24, '- - - -')
        break;
      case (0xCE) : // (0xCE, OpPrefix.None, 'ADC A,d8', 2, 8, 8, 'Z 0 H C')
        break;
      case (0xCF) : // (0xCF, OpPrefix.None, 'RST 08H', 1, 16, 16, '- - - -')
        break;
      case (0xD0) : // (0xD0, OpPrefix.None, 'RET NC', 1, 20, 8, '- - - -')
        break;
      case (0xD1) : // (0xD1, OpPrefix.None, 'POP DE', 1, 12, 12, '- - - -')
        break;
      case (0xD2) : // (0xD2, OpPrefix.None, 'JP NC,a16', 3, 16, 12, '- - - -')
        break;
      case (0xD3) : // (0xD3, OpPrefix.None, '0xD3: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xD4) : // (0xD4, OpPrefix.None, 'CALL NC,a16', 3, 24, 12, '- - - -')
        break;
      case (0xD5) : // (0xD5, OpPrefix.None, 'PUSH DE', 1, 16, 16, '- - - -')
        break;
      case (0xD6) : // (0xD6, OpPrefix.None, 'SUB d8', 2, 8, 8, 'Z 1 H C')
        break;
      case (0xD7) : // (0xD7, OpPrefix.None, 'RST 10H', 1, 16, 16, '- - - -')
        break;
      case (0xD8) : // (0xD8, OpPrefix.None, 'RET C', 1, 20, 8, '- - - -')
        break;
      case (0xD9) : // (0xD9, OpPrefix.None, 'RETI', 1, 16, 16, '- - - -')
        break;
      case (0xDA) : // (0xDA, OpPrefix.None, 'JP C,a16', 3, 16, 12, '- - - -')
        break;
      case (0xDB) : // (0xDB, OpPrefix.None, '0xDB: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xDC) : // (0xDC, OpPrefix.None, 'CALL C,a16', 3, 24, 12, '- - - -')
        break;
      case (0xDD) : // (0xDD, OpPrefix.None, '0xDD: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xDE) : // (0xDE, OpPrefix.None, 'SBC A,d8', 2, 8, 8, 'Z 1 H C')
        break;
      case (0xDF) : // (0xDF, OpPrefix.None, 'RST 18H', 1, 16, 16, '- - - -')
        break;
      case (0xE0) : // (0xE0, OpPrefix.None, 'LDH (a8),A', 2, 12, 12, '- - - -')
        break;
      case (0xE1) : // (0xE1, OpPrefix.None, 'POP HL', 1, 12, 12, '- - - -')
        break;
      case (0xE2) : // (0xE2, OpPrefix.None, 'LD (C),A', 2, 8, 8, '- - - -')
        break;
      case (0xE3) : // (0xE3, OpPrefix.None, '0xE3: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xE4) : // (0xE4, OpPrefix.None, '0xE4: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xE5) : // (0xE5, OpPrefix.None, 'PUSH HL', 1, 16, 16, '- - - -')
        break;
      case (0xE6) : // (0xE6, OpPrefix.None, 'AND d8', 2, 8, 8, 'Z 0 1 0')
        break;
      case (0xE7) : // (0xE7, OpPrefix.None, 'RST 20H', 1, 16, 16, '- - - -')
        break;
      case (0xE8) : // (0xE8, OpPrefix.None, 'ADD SP,r8', 2, 16, 16, '0 0 H C')
        break;
      case (0xE9) : // (0xE9, OpPrefix.None, 'JP (HL)', 1, 4, 4, '- - - -')
        break;
      case (0xEA) : // (0xEA, OpPrefix.None, 'LD (a16),A', 3, 16, 16, '- - - -')
        break;
      case (0xEB) : // (0xEB, OpPrefix.None, '0xEB: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xEC) : // (0xEC, OpPrefix.None, '0xEC: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xED) : // (0xED, OpPrefix.None, '0xED: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xEE) : // (0xEE, OpPrefix.None, 'XOR d8', 2, 8, 8, 'Z 0 0 0')
        break;
      case (0xEF) : // (0xEF, OpPrefix.None, 'RST 28H', 1, 16, 16, '- - - -')
        break;
      case (0xF0) : // (0xF0, OpPrefix.None, 'LDH A,(a8)', 2, 12, 12, '- - - -')
        break;
      case (0xF1) : // (0xF1, OpPrefix.None, 'POP AF', 1, 12, 12, 'Z N H C')
        break;
      case (0xF2) : // (0xF2, OpPrefix.None, 'LD A,(C)', 2, 8, 8, '- - - -')
        break;
      case (0xF3) : // (0xF3, OpPrefix.None, 'DI', 1, 4, 4, '- - - -')
        break;
      case (0xF4) : // (0xF4, OpPrefix.None, '0xF4: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xF5) : // (0xF5, OpPrefix.None, 'PUSH AF', 1, 16, 16, '- - - -')
        break;
      case (0xF6) : // (0xF6, OpPrefix.None, 'OR d8', 2, 8, 8, 'Z 0 0 0')
        break;
      case (0xF7) : // (0xF7, OpPrefix.None, 'RST 30H', 1, 16, 16, '- - - -')
        break;
      case (0xF8) : // (0xF8, OpPrefix.None, 'LD HL,SP+r8', 2, 12, 12, '0 0 H C')
        break;
      case (0xF9) : // (0xF9, OpPrefix.None, 'LD SP,HL', 1, 8, 8, '- - - -')
        break;
      case (0xFA) : // (0xFA, OpPrefix.None, 'LD A,(a16)', 3, 16, 16, '- - - -')
        break;
      case (0xFB) : // (0xFB, OpPrefix.None, 'EI', 1, 4, 4, '- - - -')
        break;
      case (0xFC) : // (0xFC, OpPrefix.None, '0xFC: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xFD) : // (0xFD, OpPrefix.None, '0xFD: N/A', 1, 4, 4, '- - - -')
        break;
      case (0xFE) : // (0xFE, OpPrefix.None, 'CP d8', 2, 8, 8, 'Z 1 H C')
        break;
      case (0xFF) : // (0xFF, OpPrefix.None, 'RST 38H', 1, 16, 16, '- - - -'
        break;
      default: throw new Exception('Gameboy: exec: Unexpected instruction');
    }
    this.cpur.PC += info.byteSize;
    return (s) ? info.durationSuccess : info.durationFail;
  }

  int _execInst_CB() {
    this.cpur.PC++;
    final inst = _mmu.pullMem(cpur.PC, DataType.BYTE);
    final info = Instructions.instInfos_CB[inst];
    switch (info.opCode)
    {
      default: break;
    }
    this.cpur.PC += info.byteSize;
    return info.durationSuccess;
  }

}