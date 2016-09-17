// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   z80.dart                                           :+:      :+:    :+:   //
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

  int _execInst() {
    final op = _mmu.pull8(this.cpur.PC);
    switch (op) {
      case (0x00) : _NOP();                       return 1; // return _NOP();                             //  NOP
      case (0x01) : _LD_rr_nn(Reg16.BC);          return 1; // return _LD_rr_nn(Reg16.BC);                //  LD BC, nn
      case (0x02) : _LD_rr_A(Reg16.BC);           return 1; // return _LD_rr_A(Reg16.BC);                 //  LD (BC), A
      case (0x03) : _INC_rr(Reg16.BC);            return 1; // return _INC_rr(Reg16.BC);                  //  INC BC
      case (0x04) : _INC_r(Reg8.B);               return 1; // return _INC_r(Reg8.B);                     //  INC B
      case (0x05) : _DEC_r(Reg8.B);               return 1; // return _DEC_r(Reg8.B);                     //  DEC B
      case (0x06) : _LD_r_n(Reg8.B);              return 1; // return _LD_r_n(Reg8.B);                    //  LD B, n
      case (0x07) : _RLCA() ;                     return 1; // return _RLCA() ;                           //  RLCA

      case (0x08) : _LD_nn_SP();                  return 1; // return _LD_nn_SP();                        //  LD (nn), SP
      case (0x09) : _ADD_HL_rr(Reg16.BC);         return 1; // return _ADD_HL_rr(Reg16.BC);               //  ADD HL, BC
      case (0x0A) : _LD_A_rr(Reg16.BC);           return 1; // return _LD_A_rr(Reg16.BC);                 //  LD A, (BC)
      case (0x0B) : _DEC_rr(Reg16.BC);            return 1; // return _DEC_rr(Reg16.BC);                  //  DEC BC
      case (0x0C) : _INC_r(Reg8.C);               return 1; // return _INC_r(Reg8.C);                     //  INC C
      case (0x0D) : _DEC_r(Reg8.C);               return 1; // return _DEC_r(Reg8.C);                     //  DEC C
      case (0x0E) : _LD_r_n(Reg8.C);              return 1; // return _LD_r_n(Reg8.C);                    //  LD C, n
      case (0x0F) : _RRCA() ;                     return 1; // return _RRCA() ;                           //  RRCA

      case (0x10) : _STOP();                      return 1; // return _STOP();                            //  STOP
      case (0x11) : _LD_rr_nn(Reg16.DE);          return 1; // return _LD_rr_nn(Reg16.DE);                //  LD DE, nn
      case (0x12) : _LD_rr_A(Reg16.DE);           return 1; // return _LD_rr_A(Reg16.DE);                 //  LD (DE), A
      case (0x13) : _INC_rr(Reg16.DE);            return 1; // return _INC_rr(Reg16.DE);                  //  INC DE
      case (0x14) : _INC_r(Reg8.D);               return 1; // return _INC_r(Reg8.D);                     //  INC D
      case (0x15) : _DEC_r(Reg8.D);               return 1; // return _DEC_r(Reg8.D);                     //  DEC D
      case (0x16) : _LD_r_n(Reg8.D);              return 1; // return _LD_r_n(Reg8.D);                    //  LD D, n
      case (0x17) : _RLA();                       return 1; // return _RLA();                             //  RLA

      case (0x18) : _JR_e();                      return 1; // return _JR_e();                            //  JR e
      case (0x19) : _ADD_HL_rr(Reg16.DE);         return 1; // return _ADD_HL_rr(Reg16.DE);               //  ADD HL, DE
      case (0x1A) : _LD_A_rr(Reg16.DE);           return 1; // return _LD_A_rr(Reg16.DE);                 //  LD A, (DE)
      case (0x1B) : _DEC_rr(Reg16.DE);            return 1; // return _DEC_rr(Reg16.DE);                  //  DEC DE
      case (0x1C) : _INC_r(Reg8.E);               return 1; // return _INC_r(Reg8.E);                     //  INC E
      case (0x1D) : _DEC_r(Reg8.E);               return 1; // return _DEC_r(Reg8.E);                     //  DEC E
      case (0x1E) : _LD_r_n(Reg8.E);              return 1; // return _LD_r_n(Reg8.E);                    //  LD E, n
      case (0x1F) : _RRA();                       return 1; // return _RRA();                             //  RRA

      case (0x20) : _JR_NZ_e();                   return 1; // return _JR_NZ_e();                         //  JR NZ, e
      case (0x21) : _LD_rr_nn(Reg16.HL);          return 1; // return _LD_rr_nn(Reg16.HL);                //  LD HL, nn
      case (0x22) : _LDI_HL_A();                  return 1; // return _LDI_HL_A();                        //  LD (HL+), A
      case (0x23) : _INC_rr(Reg16.HL);            return 1; // return _INC_rr(Reg16.HL);                  //  INC HL
      case (0x24) : _INC_r(Reg8.H);               return 1; // return _INC_r(Reg8.H);                     //  INC H
      case (0x25) : _DEC_r(Reg8.H);               return 1; // return _DEC_r(Reg8.H);                     //  DEC H
      case (0x26) : _LD_r_n(Reg8.H);              return 1; // return _LD_r_n(Reg8.H);                    //  LD H, n
      case (0x27) : _DAA();                       return 1; // return _DAA();                             //  DAA

      case (0x28) : _JR_Z_e();                    return 1; // return _JR_Z_e();                          //  JR Z, e
      case (0x29) : _ADD_HL_rr(Reg16.HL);         return 1; // return _ADD_HL_rr(Reg16.HL);               //  ADD HL, HL
      case (0x2A) : _LDI_A_HL();                  return 1; // return _LDI_A_HL();                        //  LD A, (HL+)
      case (0x2B) : _DEC_rr(Reg16.HL);            return 1; // return _DEC_rr(Reg16.HL);                  //  DEC HL
      case (0x2C) : _INC_r(Reg8.L);               return 1; // return _INC_r(Reg8.L);                     //  INC L
      case (0x2D) : _DEC_r(Reg8.L);               return 1; // return _DEC_r(Reg8.L);                     //  DEC L
      case (0x2E) : _LD_r_n(Reg8.L);              return 1; // return _LD_r_n(Reg8.L);                    //  LD L, n
      case (0x2F) : _CPL();                       return 1; // return _CPL();                             //  CPL

      case (0x30) : _JR_NC_e();                   return 1; // return _JR_NC_e();                         //  JR NC, e
      case (0x31) : _LD_rr_nn(Reg16.SP);          return 1; // return _LD_rr_nn(Reg16.SP);                //  LD SP, nn
      case (0x32) : _LDD_HL_A();                  return 1; // return _LDD_HL_A();                        //  LD (HL-), A
      case (0x33) : _INC_rr(Reg16.SP);            return 1; // return _INC_rr(Reg16.SP);                  //  INC SP
      case (0x34) : _INC_HL();                    return 1; // return _INC_HL();                          //  INC (HL)
      case (0x35) : _INC_HL();                    return 1; // return _INC_HL();                          //  DEC (HL)
      case (0x36) : _LD_HL_n();                   return 1; // return _LD_HL_n();                         //  LD (HL), n
      case (0x37) : _SCF();                       return 1; // return _SCF();                             //  SCF

      case (0x38) : _JR_C_e();                    return 1; // return _JR_C_e();                          //  JR C, e
      case (0x39) : _ADD_HL_rr(Reg16.SP);         return 1; // return _ADD_HL_rr(Reg16.SP);               //  ADD HL, SP
      case (0x3A) : _LDD_A_HL();                  return 1; // return _LDD_A_HL();                        //  LD A, (HL-)
      case (0x3B) : _DEC_rr(Reg16.SP);            return 1; // return _DEC_rr(Reg16.SP);                  //  DEC SP
      case (0x3C) : _INC_r(Reg8.A);               return 1; // return _INC_r(Reg8.A);                     //  INC A
      case (0x3D) : _DEC_r(Reg8.A);               return 1; // return _DEC_r(Reg8.A);                     //  DEC A
      case (0x3E) : _LD_r_n(Reg8.A);              return 1; // return _LD_r_n(Reg8.A);                      //  LD A, n
      case (0x3F) : _CCF();                       return 1; // return _CCF();                             //  CCF

      case (0x40) : _LD_r_r(Reg8.B, Reg8.B);      return 1; // return _LD_r_r(Reg8.B, Reg8.B);            //  LD B, B
      case (0x41) : _LD_r_r(Reg8.B, Reg8.C);      return 1; // return _LD_r_r(Reg8.B, Reg8.C);            //  LD B, C
      case (0x42) : _LD_r_r(Reg8.B, Reg8.D);      return 1; // return _LD_r_r(Reg8.B, Reg8.D);            //  LD B, D
      case (0x43) : _LD_r_r(Reg8.B, Reg8.E);      return 1; // return _LD_r_r(Reg8.B, Reg8.E);            //  LD B, E
      case (0x44) : _LD_r_r(Reg8.B, Reg8.H);      return 1; // return _LD_r_r(Reg8.B, Reg8.H);            //  LD B, H
      case (0x45) : _LD_r_r(Reg8.B, Reg8.L);      return 1; // return _LD_r_r(Reg8.B, Reg8.L);            //  LD B, L
      case (0x46) : _LD_r_HL(Reg8.B);             return 1; // return _LD_r_HL(Reg8.B);                   //  LD B, (HL)
      case (0x47) : _LD_r_r(Reg8.B, Reg8.A);      return 1; // return _LD_r_r(Reg8.B, Reg8.A);            //  LD B, A

      case (0x48) : _LD_r_r(Reg8.C, Reg8.B);      return 1; // return _LD_r_r(Reg8.C, Reg8.B);            //  LD C, B
      case (0x49) : _LD_r_r(Reg8.C, Reg8.C);      return 1; // return _LD_r_r(Reg8.C, Reg8.C);            //  LD C, C
      case (0x4A) : _LD_r_r(Reg8.C, Reg8.D);      return 1; // return _LD_r_r(Reg8.C, Reg8.D);            //  LD C, D
      case (0x4B) : _LD_r_r(Reg8.C, Reg8.E);      return 1; // return _LD_r_r(Reg8.C, Reg8.E);            //  LD C, E
      case (0x4C) : _LD_r_r(Reg8.C, Reg8.H);      return 1; // return _LD_r_r(Reg8.C, Reg8.H);            //  LD C, H
      case (0x4D) : _LD_r_r(Reg8.C, Reg8.L);      return 1; // return _LD_r_r(Reg8.C, Reg8.L);            //  LD C, L
      case (0x4E) : _LD_r_HL(Reg8.C);             return 1; // return _LD_r_HL(Reg8.C);                   //  LD C, (HL)
      case (0x4F) : _LD_r_r(Reg8.C, Reg8.A);      return 1; // return _LD_r_r(Reg8.C, Reg8.A);            //  LD C, A

      case (0x50) : _LD_r_r(Reg8.D, Reg8.B);      return 1; // return _LD_r_r(Reg8.D, Reg8.B);            //  LD D, B
      case (0x51) : _LD_r_r(Reg8.D, Reg8.C);      return 1; // return _LD_r_r(Reg8.D, Reg8.C);            //  LD D, C
      case (0x52) : _LD_r_r(Reg8.D, Reg8.D);      return 1; // return _LD_r_r(Reg8.D, Reg8.D);            //  LD D, D
      case (0x53) : _LD_r_r(Reg8.D, Reg8.E);      return 1; // return _LD_r_r(Reg8.D, Reg8.E);            //  LD D, E
      case (0x54) : _LD_r_r(Reg8.D, Reg8.H);      return 1; // return _LD_r_r(Reg8.D, Reg8.H);            //  LD D, H
      case (0x55) : _LD_r_r(Reg8.D, Reg8.L);      return 1; // return _LD_r_r(Reg8.D, Reg8.L);            //  LD D, L
      case (0x56) : _LD_r_HL(Reg8.D);             return 1; // return _LD_r_HL(Reg8.D);                   //  LD D, (HL)
      case (0x57) : _LD_r_r(Reg8.D, Reg8.A);      return 1; // return _LD_r_r(Reg8.D, Reg8.A);            //  LD D, A

      case (0x58) : _LD_r_r(Reg8.E, Reg8.B);      return 1; // return _LD_r_r(Reg8.E, Reg8.B);            //  LD E, B
      case (0x59) : _LD_r_r(Reg8.E, Reg8.C);      return 1; // return _LD_r_r(Reg8.E, Reg8.C);            //  LD E, C
      case (0x5A) : _LD_r_r(Reg8.E, Reg8.D);      return 1; // return _LD_r_r(Reg8.E, Reg8.D);            //  LD E, D
      case (0x5B) : _LD_r_r(Reg8.E, Reg8.E);      return 1; // return _LD_r_r(Reg8.E, Reg8.E);            //  LD E, E
      case (0x5C) : _LD_r_r(Reg8.E, Reg8.H);      return 1; // return _LD_r_r(Reg8.E, Reg8.H);            //  LD E, H
      case (0x5D) : _LD_r_r(Reg8.E, Reg8.L);      return 1; // return _LD_r_r(Reg8.E, Reg8.L);            //  LD E, L
      case (0x5E) : _LD_r_HL(Reg8.E);             return 1; // return _LD_r_HL(Reg8.E);                   //  LD E, (HL)
      case (0x5F) : _LD_r_r(Reg8.E, Reg8.A);      return 1; // return _LD_r_r(Reg8.E, Reg8.A);            //  LD E, A

      case (0x60) : _LD_r_r(Reg8.H, Reg8.B);      return 1; // return _LD_r_r(Reg8.H, Reg8.B);            //  LD H, B
      case (0x61) : _LD_r_r(Reg8.H, Reg8.C);      return 1; // return _LD_r_r(Reg8.H, Reg8.C);            //  LD H, C
      case (0x62) : _LD_r_r(Reg8.H, Reg8.D);      return 1; // return _LD_r_r(Reg8.H, Reg8.D);            //  LD H, D
      case (0x63) : _LD_r_r(Reg8.H, Reg8.E);      return 1; // return _LD_r_r(Reg8.H, Reg8.E);            //  LD H, E
      case (0x64) : _LD_r_r(Reg8.H, Reg8.H);      return 1; // return _LD_r_r(Reg8.H, Reg8.H);            //  LD H, H
      case (0x65) : _LD_r_r(Reg8.H, Reg8.L);      return 1; // return _LD_r_r(Reg8.H, Reg8.L);            //  LD H, L
      case (0x66) : _LD_r_HL(Reg8.H);             return 1; // return _LD_r_HL(Reg8.H);                   //  LD H, (HL)
      case (0x67) : _LD_r_r(Reg8.H, Reg8.A);      return 1; // return _LD_r_r(Reg8.H, Reg8.A);            //  LD H, A

      case (0x68) : _LD_r_r(Reg8.L, Reg8.B);      return 1; // return _LD_r_r(Reg8.L, Reg8.B);            //  LD L, B
      case (0x69) : _LD_r_r(Reg8.L, Reg8.C);      return 1; // return _LD_r_r(Reg8.L, Reg8.C);            //  LD L, C
      case (0x6A) : _LD_r_r(Reg8.L, Reg8.D);      return 1; // return _LD_r_r(Reg8.L, Reg8.D);            //  LD L, D
      case (0x6B) : _LD_r_r(Reg8.L, Reg8.E);      return 1; // return _LD_r_r(Reg8.L, Reg8.E);            //  LD L, E
      case (0x6C) : _LD_r_r(Reg8.L, Reg8.H);      return 1; // return _LD_r_r(Reg8.L, Reg8.H);            //  LD L, H
      case (0x6D) : _LD_r_r(Reg8.L, Reg8.L);      return 1; // return _LD_r_r(Reg8.L, Reg8.L);            //  LD L, L
      case (0x6E) : _LD_r_HL(Reg8.L);             return 1; // return _LD_r_HL(Reg8.L);                   //  LD L, (HL)
      case (0x6F) : _LD_r_r(Reg8.L, Reg8.A);      return 1; // return _LD_r_r(Reg8.L, Reg8.A);            //  LD L, A

      case (0x70) : _LD_HL_r(Reg8.B);             return 1; // return _LD_HL_r(Reg8.B);                   //  LD (HL), B
      case (0x71) : _LD_HL_r(Reg8.C);             return 1; // return _LD_HL_r(Reg8.C);                   //  LD (HL), C
      case (0x72) : _LD_HL_r(Reg8.D);             return 1; // return _LD_HL_r(Reg8.D);                   //  LD (HL), D
      case (0x73) : _LD_HL_r(Reg8.E);             return 1; // return _LD_HL_r(Reg8.E);                   //  LD (HL), E
      case (0x74) : _LD_HL_r(Reg8.H);             return 1; // return _LD_HL_r(Reg8.H);                   //  LD (HL), H
      case (0x75) : _LD_HL_r(Reg8.L);             return 1; // return _LD_HL_r(Reg8.L);                   //  LD (HL), L
      case (0x76) : _HALT();                      return 1; // return _HALT();                            //  HALT
      case (0x77) : _LD_HL_r(Reg8.A);             return 1; // return _LD_HL_r(Reg8.A);                   //  LD (HL), A

      case (0x78) : _LD_r_r(Reg8.A, Reg8.B);      return 1; // return _LD_r_r(Reg8.A, Reg8.B);            //  LD A, B
      case (0x79) : _LD_r_r(Reg8.A, Reg8.C);      return 1; // return _LD_r_r(Reg8.A, Reg8.C);            //  LD A, C
      case (0x7A) : _LD_r_r(Reg8.A, Reg8.D);      return 1; // return _LD_r_r(Reg8.A, Reg8.D);            //  LD A, D
      case (0x7B) : _LD_r_r(Reg8.A, Reg8.E);      return 1; // return _LD_r_r(Reg8.A, Reg8.E);            //  LD A, E
      case (0x7C) : _LD_r_r(Reg8.A, Reg8.H);      return 1; // return _LD_r_r(Reg8.A, Reg8.H);            //  LD A, H
      case (0x7D) : _LD_r_r(Reg8.A, Reg8.L);      return 1; // return _LD_r_r(Reg8.A, Reg8.L);            //  LD A, L
      case (0x7E) : _LD_r_HL(Reg8.A);             return 1; // return _LD_r_HL(Reg8.A);                   //  LD A, (HL)
      case (0x7F) : _LD_r_r(Reg8.A, Reg8.A);      return 1; // return _LD_r_r(Reg8.A, Reg8.A);            //  LD A, A

      case (0x80) : _ADD_r(Reg8.B);               return 1; // return _ADD_r(Reg8.B);                     //  ADD A, B
      case (0x81) : _ADD_r(Reg8.C);               return 1; // return _ADD_r(Reg8.C);                     //  ADD A, C
      case (0x82) : _ADD_r(Reg8.D);               return 1; // return _ADD_r(Reg8.D);                     //  ADD A, D
      case (0x83) : _ADD_r(Reg8.E);               return 1; // return _ADD_r(Reg8.E);                     //  ADD A, E
      case (0x84) : _ADD_r(Reg8.H);               return 1; // return _ADD_r(Reg8.H);                     //  ADD A, H
      case (0x85) : _ADD_r(Reg8.L);               return 1; // return _ADD_r(Reg8.L);                     //  ADD A, L
      case (0x86) : _ADD_HL();                    return 1; // return _ADD_HL();                          //  ADD A, (HL)
      case (0x87) : _ADD_r(Reg8.A);               return 1; // return _ADD_r(Reg8.A);                     //  ADD A, A

      case (0x88) : _ADC_r(Reg8.B);               return 1; // return _ADC_r(Reg8.B);                     //  ADC A, B
      case (0x89) : _ADC_r(Reg8.C);               return 1; // return _ADC_r(Reg8.C);                     //  ADC A, C
      case (0x8A) : _ADC_r(Reg8.D);               return 1; // return _ADC_r(Reg8.D);                     //  ADC A, D
      case (0x8B) : _ADC_r(Reg8.E);               return 1; // return _ADC_r(Reg8.E);                     //  ADC A, E
      case (0x8C) : _ADC_r(Reg8.H);               return 1; // return _ADC_r(Reg8.H);                     //  ADC A, H
      case (0x8D) : _ADC_r(Reg8.L);               return 1; // return _ADC_r(Reg8.L);                     //  ADC A, L
      case (0x8E) : _ADC_HL();                    return 1; // return _ADC_HL();                          //  ADC A, (HL)
      case (0x8F) : _ADC_r(Reg8.A);               return 1; // return _ADC_r(Reg8.A);                     //  ADC A, A

      case (0x90) : _SUB_r(Reg8.B);               return 1; // return _SUB_r(Reg8.B);                     //  SUB B
      case (0x91) : _SUB_r(Reg8.C);               return 1; // return _SUB_r(Reg8.C);                     //  SUB C
      case (0x92) : _SUB_r(Reg8.D);               return 1; // return _SUB_r(Reg8.D);                     //  SUB D
      case (0x93) : _SUB_r(Reg8.E);               return 1; // return _SUB_r(Reg8.E);                     //  SUB E
      case (0x94) : _SUB_r(Reg8.H);               return 1; // return _SUB_r(Reg8.H);                     //  SUB H
      case (0x95) : _SUB_r(Reg8.L);               return 1; // return _SUB_r(Reg8.L);                     //  SUB L
      case (0x96) : _SUB_HL();                    return 1; // return _SUB_HL();                          //  SUB (HL)
      case (0x97) : _SUB_r(Reg8.A);               return 1; // return _SUB_r(Reg8.A);                     //  SUB A

      case (0x98) : _SBC_r(Reg8.B);               return 1; // return _SBC_r(Reg8.B);                     //  SBC A, B
      case (0x99) : _SBC_r(Reg8.C);               return 1; // return _SBC_r(Reg8.C);                     //  SBC A, C
      case (0x9A) : _SBC_r(Reg8.D);               return 1; // return _SBC_r(Reg8.D);                     //  SBC A, D
      case (0x9B) : _SBC_r(Reg8.E);               return 1; // return _SBC_r(Reg8.E);                     //  SBC A, E
      case (0x9C) : _SBC_r(Reg8.H);               return 1; // return _SBC_r(Reg8.H);                     //  SBC A, H
      case (0x9D) : _SBC_r(Reg8.L);               return 1; // return _SBC_r(Reg8.L);                     //  SBC A, L
      case (0x9E) : _SBC_HL();                    return 1; // return _SBC_HL();                          //  SBC A, (HL)
      case (0x9F) : _SBC_r(Reg8.A);               return 1; // return _SBC_r(Reg8.A);                     //  SBC A, A

      case (0xA0) : _AND_r(Reg8.B);               return 1; // return _AND_r(Reg8.B);                     //  AND B
      case (0xA1) : _AND_r(Reg8.C);               return 1; // return _AND_r(Reg8.C);                     //  AND C
      case (0xA2) : _AND_r(Reg8.D);               return 1; // return _AND_r(Reg8.D);                     //  AND D
      case (0xA3) : _AND_r(Reg8.E);               return 1; // return _AND_r(Reg8.E);                     //  AND E
      case (0xA4) : _AND_r(Reg8.H);               return 1; // return _AND_r(Reg8.H);                     //  AND H
      case (0xA5) : _AND_r(Reg8.L);               return 1; // return _AND_r(Reg8.L);                     //  AND L
      case (0xA6) : _AND_HL();                    return 1; // return _AND_HL();                          //  AND (HL)
      case (0xA7) : _AND_r(Reg8.A);               return 1; // return _AND_r(Reg8.A);                     //  AND A

      case (0xA8) : _XOR_r(Reg8.B);               return 1; // return _XOR_r(Reg8.B);                     //  XOR B
      case (0xA9) : _XOR_r(Reg8.C);               return 1; // return _XOR_r(Reg8.C);                     //  XOR C
      case (0xAA) : _XOR_r(Reg8.D);               return 1; // return _XOR_r(Reg8.D);                     //  XOR D
      case (0xAB) : _XOR_r(Reg8.E);               return 1; // return _XOR_r(Reg8.E);                     //  XOR E
      case (0xAC) : _XOR_r(Reg8.H);               return 1; // return _XOR_r(Reg8.H);                     //  XOR H
      case (0xAD) : _XOR_r(Reg8.L);               return 1; // return _XOR_r(Reg8.L);                     //  XOR L
      case (0xAE) : _XOR_HL();                    return 1; // return _XOR_HL();                          //  XOR (HL)
      case (0xAF) : _XOR_r(Reg8.A);               return 1; // return _XOR_r(Reg8.A);                     //  XOR A

      case (0xB0) : _OR_r(Reg8.B);                return 1; // return _OR_r(Reg8.B);                      //  OR B
      case (0xB1) : _OR_r(Reg8.C);                return 1; // return _OR_r(Reg8.C);                      //  OR C
      case (0xB2) : _OR_r(Reg8.D);                return 1; // return _OR_r(Reg8.D);                      //  OR D
      case (0xB3) : _OR_r(Reg8.E);                return 1; // return _OR_r(Reg8.E);                      //  OR E
      case (0xB4) : _OR_r(Reg8.H);                return 1; // return _OR_r(Reg8.H);                      //  OR H
      case (0xB5) : _OR_r(Reg8.L);                return 1; // return _OR_r(Reg8.L);                      //  OR L
      case (0xB6) : _OR_HL();                     return 1; // return _OR_HL();                           //  OR (HL)
      case (0xB7) : _OR_r(Reg8.A);                return 1; // return _OR_r(Reg8.A);                      //  OR A

      case (0xB8) : _CP_r(Reg8.B);                return 1; // return _CP_r(Reg8.B);                      //  CP B
      case (0xB9) : _CP_r(Reg8.C);                return 1; // return _CP_r(Reg8.C);                      //  CP C
      case (0xBA) : _CP_r(Reg8.D);                return 1; // return _CP_r(Reg8.D);                      //  CP D
      case (0xBB) : _CP_r(Reg8.E);                return 1; // return _CP_r(Reg8.E);                      //  CP E
      case (0xBC) : _CP_r(Reg8.H);                return 1; // return _CP_r(Reg8.H);                      //  CP H
      case (0xBD) : _CP_r(Reg8.L);                return 1; // return _CP_r(Reg8.L);                      //  CP L
      case (0xBE) : _CP_HL();                     return 1; // return _CP_HL();                           //  CP (HL)
      case (0xBF) : _CP_r(Reg8.A);                return 1; // return _CP_r(Reg8.A);                      //  CP A

      case (0xC0) : _RET_NZ();                    return 1; // return _RET_NZ();                          //  RET NZ
      case (0xC1) : _POP(Reg16.BC);               return 1; // return _POP(Reg16.BC);                     //  POP BC
      case (0xC2) : _JP_NZ_nn();                  return 1; // return _JP_NZ_nn();                        //  JP NZ, nn
      case (0xC3) : _JP_nn();                     return 1; // return _JP_nn();                           //  JP nn
      case (0xC4) : _CALL_NZ_nn();                return 1; // return _CALL_NZ_nn();                      //  CALL NZ, nn
      case (0xC5) : _PUSH(Reg16.BC);              return 1; // return _PUSH(Reg16.BC);                    //  PUSH BC
      case (0xC6) : _ADD_n();                     return 1; // return _ADD_n();                           //  ADD A, d8
      case (0xC7) : _RST_00H();                   return 1; // return _RST_00H();                         //  RST 00H

      case (0xC8) : _RET_Z();                     return 1; // return _RET_Z();                           //  RET Z
      case (0xC9) : _RET();                       return 1; // return _RET();                             //  RET
      case (0xCA) : _JP_Z_nn();                   return 1; // return _JP_Z_nn();                         //  JP Z, nn
      case (0xCB) : _execInst_CB();               return 1; // return _execInst_CB();                     //  0xCB: PREFIX
      case (0xCC) : _CALL_Z_nn();                 return 1; // return _CALL_Z_nn();                       //  CALL Z, nn
      case (0xCD) : _CALL_nn();                   return 1; // return _CALL_nn();                         //  CALL nn
      case (0xCE) : _ADC_n();                     return 1; // return _ADC_n();                           //  ADC A, d8
      case (0xCF) : _RST_08H();                   return 1; // return _RST_08H();                         //  RST 08H

      case (0xD0) : _RET_NC();                    return 1; // return _RET_NC();                          //  RET NC
      case (0xD1) : _POP(Reg16.DE);               return 1; // return _POP(Reg16.DE);                     //  POP DE
      case (0xD2) : _JP_NC_nn();                  return 1; // return _JP_NC_nn();                        //  JP NC, nn
      case (0xD3) : _NOP();                       return 1; // return _NOP();                             //  0xD3: N/A
      case (0xD4) : _CALL_NC_nn();                return 1; // return _CALL_NC_nn();                      //  CALL NC, nn
      case (0xD5) : _PUSH(Reg16.DE);              return 1; // return _PUSH(Reg16.DE);                    //  PUSH DE
      case (0xD6) : _SUB_n();                     return 1; // return _SUB_n();                           //  SUB n
      case (0xD7) : _RST_10H();                   return 1; // return _RST_10H();                         //  RST 10H

      case (0xD8) : _RET_C();                     return 1; // return _RET_C();                           //  RET C
      case (0xD9) : _RETI();                      return 1; // return _RETI();                            //  RETI
      case (0xDA) : _JP_C_nn();                   return 1; // return _JP_C_nn();                         //  JP C, nn
      case (0xDB) : _NOP();                       return 1; // return _NOP();                             //  0xDB: N/A
      case (0xDC) : _CALL_C_nn();                 return 1; // return _CALL_C_nn();                       //  CALL C, nn
      case (0xDD) : _NOP();                       return 1; // return _NOP();                             //  0xDD: N/A
      case (0xDE) : _SBC_n();                     return 1; // return _SBC_n();                           //  SBC A, d8
      case (0xDF) : _RST_18H();                   return 1; // return _RST_18H();                         //  RST 18H

      case (0xE0) : _LD_n_A();                    return 1; // return _LD_n_A();                          //  LD (0xFF+n), A
      case (0xE1) : _POP(Reg16.HL);               return 1; // return _POP(Reg16.HL);                     //  POP HL
      case (0xE2) : _LD_C_A();                    return 1; // return _LD_C_A();                          //  LD (0xFF+C), A
      case (0xE3) : _NOP();                       return 1; // return _NOP();                             //  0xE3: N/A
      case (0xE4) : _NOP();                       return 1; // return _NOP();                             //  0xE4: N/A
      case (0xE5) : _PUSH(Reg16.HL);              return 1; // return _PUSH(Reg16.HL);                    //  PUSH HL
      case (0xE6) : _AND_n();                     return 1; // return _AND_n();                           //  AND n
      case (0xE7) : _RST_20H();                   return 1; // return _RST_20H();                         //  RST 20H

      case (0xE8) : _ADD_SP_e();                  return 1; // return _ADD_SP_e();                        //  ADD SP, e
      case (0xE9) : _JP_HL();                     return 1; // return _JP_HL();                           //  JP (HL)
      case (0xEA) : _LD_nn_A();                   return 1; // return _LD_nn_A();                         //  LD (nn), A
      case (0xEB) : _NOP();                       return 1; // return _NOP();                             //  0xEB: N/A
      case (0xEC) : _NOP();                       return 1; // return _NOP();                             //  0xEC: N/A
      case (0xED) : _NOP();                       return 1; // return _NOP();                             //  0xED: N/A
      case (0xEE) : _XOR_n();                     return 1; // return _XOR_n();                           //  XOR n
      case (0xEF) : _RST_28H();                   return 1; // return _RST_28H();                         //  RST 28H

      case (0xF0) : _LD_A_n();                    return 1; // return _LD_A_n();                          //  LD A, (0xFF+n)
      case (0xF1) : _POP(Reg16.AF);               return 1; // return _POP(Reg16.AF);                     //  POP AF
      case (0xF2) : _LD_A_C();                    return 1; // return _LD_A_C();                          //  LD A, (0xFF+C)
      case (0xF3) : _DI();                        return 1; // return _DI();                              //  DI
      case (0xF4) : _NOP();                       return 1; // return _NOP();                             //  0xF4: N/A
      case (0xF5) : _PUSH(Reg16.AF);              return 1; // return _PUSH(Reg16.AF);                    //  PUSH AF
      case (0xF6) : _OR_n();                      return 1; // return _OR_n();                            //  OR n
      case (0xF7) : _RST_30H();                   return 1; // return _RST_30H();                         //  RST 30H

      case (0xF8) : _LD_HL_SP_e();                return 1; // return _LD_HL_SP_e();                      //  LD HL, SP+e
      case (0xF9) : _LD_SP_HL();                  return 1; // return _LD_SP_HL();                        //  LD SP, HL
      case (0xFA) : _LD_A_nn();                   return 1; // return _LD_A_nn();                         //  LD A, (nn)
      case (0xFB) : _EI();                        return 1; // return _EI();                              //  EI
      case (0xFC) : _NOP();                       return 1; // return _NOP();                             //  0xFC: N/A
      case (0xFD) : _NOP();                       return 1; // return _NOP();                             //  0xFD: N/A
      case (0xFE) : _CP_n();                      return 1; // return _CP_n();                            //  CP n
      case (0xFF) : _RST_38H();                   return 1; // return _RST_38H();                         //  RST 38H
      default : break;
    }
    throw new Exception('z80: Opcode ${Ft.toAddressString(op, 4)} not suported');
  }

  /* Extended Instructions */

  int _execInst_CB() {
    final op = _mmu.pull8(this.cpur.PC + 1);
    switch (op) {
      case (0x00) : _RLC(Reg8.B);         return 1; //      return _RLC(Reg8.B);         //  RLC B
      case (0x01) : _RLC(Reg8.C);         return 1; //      return _RLC(Reg8.C);         //  RLC C
      case (0x02) : _RLC(Reg8.D);         return 1; //      return _RLC(Reg8.D);         //  RLC D
      case (0x03) : _RLC(Reg8.E);         return 1; //      return _RLC(Reg8.E);         //  RLC E
      case (0x04) : _RLC(Reg8.H);         return 1; //      return _RLC(Reg8.H);         //  RLC H
      case (0x05) : _RLC(Reg8.L);         return 1; //      return _RLC(Reg8.L);         //  RLC L
      case (0x06) : _RLC_HL();            return 1; //      return _RLC_HL();            //  RLC (HL)
      case (0x07) : _RLC(Reg8.A);         return 1; //      return _RLC(Reg8.A);         //  RLC A

      case (0x08) : _RRC(Reg8.B);         return 1; //      return _RRC(Reg8.B);         //  RRC B
      case (0x09) : _RRC(Reg8.C);         return 1; //      return _RRC(Reg8.C);         //  RRC C
      case (0x0A) : _RRC(Reg8.D);         return 1; //      return _RRC(Reg8.D);         //  RRC D
      case (0x0B) : _RRC(Reg8.E);         return 1; //      return _RRC(Reg8.E);         //  RRC E
      case (0x0C) : _RRC(Reg8.H);         return 1; //      return _RRC(Reg8.H);         //  RRC H
      case (0x0D) : _RRC(Reg8.L);         return 1; //      return _RRC(Reg8.L);         //  RRC L
      case (0x0E) : _RRC_HL();            return 1; //      return _RRC_HL();            //  RRC (HL)
      case (0x0F) : _RRC(Reg8.A);         return 1; //      return _RRC(Reg8.A);         //  RRC A

      case (0x10) : _RL(Reg8.B);          return 1; //      return _RL(Reg8.B);          //  RL B
      case (0x11) : _RL(Reg8.C);          return 1; //      return _RL(Reg8.C);          //  RL C
      case (0x12) : _RL(Reg8.D);          return 1; //      return _RL(Reg8.D);          //  RL D
      case (0x13) : _RL(Reg8.E);          return 1; //      return _RL(Reg8.E);          //  RL E
      case (0x14) : _RL(Reg8.H);          return 1; //      return _RL(Reg8.H);          //  RL H
      case (0x15) : _RL(Reg8.L);          return 1; //      return _RL(Reg8.L);          //  RL L
      case (0x16) : _RL_HL();             return 1; //      return _RL_HL();             //  RL (HL)
      case (0x17) : _RL(Reg8.A);          return 1; //      return _RL(Reg8.A);          //  RL A

      case (0x18) : _RR(Reg8.B);          return 1; //      return _RR(Reg8.B);          //  RR B
      case (0x19) : _RR(Reg8.C);          return 1; //      return _RR(Reg8.C);          //  RR C
      case (0x1A) : _RR(Reg8.D);          return 1; //      return _RR(Reg8.D);          //  RR D
      case (0x1B) : _RR(Reg8.E);          return 1; //      return _RR(Reg8.E);          //  RR E
      case (0x1C) : _RR(Reg8.H);          return 1; //      return _RR(Reg8.H);          //  RR H
      case (0x1D) : _RR(Reg8.L);          return 1; //      return _RR(Reg8.L);          //  RR L
      case (0x1E) : _RR_HL();             return 1; //      return _RR_HL();             //  RR (HL)
      case (0x1F) : _RR(Reg8.A);          return 1; //      return _RR(Reg8.A);          //  RR A

      case (0x20) : _SLA(Reg8.B);         return 1; //      return _SLA(Reg8.B);         //  SLA B
      case (0x21) : _SLA(Reg8.C);         return 1; //      return _SLA(Reg8.C);         //  SLA C
      case (0x22) : _SLA(Reg8.D);         return 1; //      return _SLA(Reg8.D);         //  SLA D
      case (0x23) : _SLA(Reg8.E);         return 1; //      return _SLA(Reg8.E);         //  SLA E
      case (0x24) : _SLA(Reg8.H);         return 1; //      return _SLA(Reg8.H);         //  SLA H
      case (0x25) : _SLA(Reg8.L);         return 1; //      return _SLA(Reg8.L);         //  SLA L
      case (0x26) : _SLA_HL();            return 1; //      return _SLA_HL();            //  SLA (HL)
      case (0x27) : _SLA(Reg8.A);         return 1; //      return _SLA(Reg8.A);         //  SLA A

      case (0x28) : _SRA(Reg8.B);         return 1; //      return _SRA(Reg8.B);         //  SRA B
      case (0x29) : _SRA(Reg8.C);         return 1; //      return _SRA(Reg8.C);         //  SRA C
      case (0x2A) : _SRA(Reg8.D);         return 1; //      return _SRA(Reg8.D);         //  SRA D
      case (0x2B) : _SRA(Reg8.E);         return 1; //      return _SRA(Reg8.E);         //  SRA E
      case (0x2C) : _SRA(Reg8.H);         return 1; //      return _SRA(Reg8.H);         //  SRA H
      case (0x2D) : _SRA(Reg8.L);         return 1; //      return _SRA(Reg8.L);         //  SRA L
      case (0x2E) : _SRA_HL();            return 1; //      return _SRA_HL();            //  SRA (HL)
      case (0x2F) : _SRA(Reg8.A);         return 1; //      return _SRA(Reg8.A);         //  SRA A

      case (0x30) : _SWAP(Reg8.B);        return 1; //      return _SWAP(Reg8.B);        //  SWAP B
      case (0x31) : _SWAP(Reg8.C);        return 1; //      return _SWAP(Reg8.C);        //  SWAP C
      case (0x32) : _SWAP(Reg8.D);        return 1; //      return _SWAP(Reg8.D);        //  SWAP D
      case (0x33) : _SWAP(Reg8.E);        return 1; //      return _SWAP(Reg8.E);        //  SWAP E
      case (0x34) : _SWAP(Reg8.H);        return 1; //      return _SWAP(Reg8.H);        //  SWAP H
      case (0x35) : _SWAP(Reg8.L);        return 1; //      return _SWAP(Reg8.L);        //  SWAP L
      case (0x36) : _SWAP_HL();           return 1; //      return _SWAP_HL();           //  SWAP (HL)
      case (0x37) : _SWAP(Reg8.A);        return 1; //      return _SWAP(Reg8.A);        //  SWAP A

      case (0x38) : _SRL(Reg8.B);         return 1; //      return _SRL(Reg8.B);         //  SRL B
      case (0x39) : _SRL(Reg8.C);         return 1; //      return _SRL(Reg8.C);         //  SRL C
      case (0x3A) : _SRL(Reg8.D);         return 1; //      return _SRL(Reg8.D);         //  SRL D
      case (0x3B) : _SRL(Reg8.E);         return 1; //      return _SRL(Reg8.E);         //  SRL E
      case (0x3C) : _SRL(Reg8.H);         return 1; //      return _SRL(Reg8.H);         //  SRL H
      case (0x3D) : _SRL(Reg8.L);         return 1; //      return _SRL(Reg8.L);         //  SRL L
      case (0x3E) : _SRL_HL();            return 1; //      return _SRL_HL();            //  SRL (HL)
      case (0x3F) : _SRL(Reg8.A);         return 1; //      return _SRL(Reg8.A);         //  SRL A

      case (0x40) : _BIT(   0, Reg8.B);   return 1; //      return _BIT(   0, Reg8.B);   //  BIT 0, B
      case (0x41) : _BIT(   0, Reg8.C);   return 1; //      return _BIT(   0, Reg8.C);   //  BIT 0, C
      case (0x42) : _BIT(   0, Reg8.D);   return 1; //      return _BIT(   0, Reg8.D);   //  BIT 0, D
      case (0x43) : _BIT(   0, Reg8.E);   return 1; //      return _BIT(   0, Reg8.E);   //  BIT 0, E
      case (0x44) : _BIT(   0, Reg8.H);   return 1; //      return _BIT(   0, Reg8.H);   //  BIT 0, H
      case (0x45) : _BIT(   0, Reg8.L);   return 1; //      return _BIT(   0, Reg8.L);   //  BIT 0, L
      case (0x46) : _BIT_HL(0);           return 1; //      return _BIT_HL(0);           //  BIT 0, (HL)
      case (0x47) : _BIT(   0, Reg8.A);   return 1; //      return _BIT(   0, Reg8.A);   //  BIT 0, A

      case (0x48) : _BIT(   1, Reg8.B);   return 1; //      return _BIT(   1, Reg8.B);   //  BIT 1, B
      case (0x49) : _BIT(   1, Reg8.C);   return 1; //      return _BIT(   1, Reg8.C);   //  BIT 1, C
      case (0x4A) : _BIT(   1, Reg8.D);   return 1; //      return _BIT(   1, Reg8.D);   //  BIT 1, D
      case (0x4B) : _BIT(   1, Reg8.E);   return 1; //      return _BIT(   1, Reg8.E);   //  BIT 1, E
      case (0x4C) : _BIT(   1, Reg8.H);   return 1; //      return _BIT(   1, Reg8.H);   //  BIT 1, H
      case (0x4D) : _BIT(   1, Reg8.L);   return 1; //      return _BIT(   1, Reg8.L);   //  BIT 1, L
      case (0x4E) : _BIT_HL(1);           return 1; //      return _BIT_HL(1);           //  BIT 1, (HL)
      case (0x4F) : _BIT(   1, Reg8.A);   return 1; //      return _BIT(   1, Reg8.A);   //  BIT 1, A

      case (0x50) : _BIT(   2, Reg8.B);   return 1; //      return _BIT(   2, Reg8.B);   //  BIT 2, B
      case (0x51) : _BIT(   2, Reg8.C);   return 1; //      return _BIT(   2, Reg8.C);   //  BIT 2, C
      case (0x52) : _BIT(   2, Reg8.D);   return 1; //      return _BIT(   2, Reg8.D);   //  BIT 2, D
      case (0x53) : _BIT(   2, Reg8.E);   return 1; //      return _BIT(   2, Reg8.E);   //  BIT 2, E
      case (0x54) : _BIT(   2, Reg8.H);   return 1; //      return _BIT(   2, Reg8.H);   //  BIT 2, H
      case (0x55) : _BIT(   2, Reg8.L);   return 1; //      return _BIT(   2, Reg8.L);   //  BIT 2, L
      case (0x56) : _BIT_HL(2);           return 1; //      return _BIT_HL(2);           //  BIT 2, (HL)
      case (0x57) : _BIT(   2, Reg8.A);   return 1; //      return _BIT(   2, Reg8.A);   //  BIT 2, A

      case (0x58) : _BIT(   3, Reg8.B);   return 1; //      return _BIT(   3, Reg8.B);   //  BIT 3, B
      case (0x59) : _BIT(   3, Reg8.C);   return 1; //      return _BIT(   3, Reg8.C);   //  BIT 3, C
      case (0x5A) : _BIT(   3, Reg8.D);   return 1; //      return _BIT(   3, Reg8.D);   //  BIT 3, D
      case (0x5B) : _BIT(   3, Reg8.E);   return 1; //      return _BIT(   3, Reg8.E);   //  BIT 3, E
      case (0x5C) : _BIT(   3, Reg8.H);   return 1; //      return _BIT(   3, Reg8.H);   //  BIT 3, H
      case (0x5D) : _BIT(   3, Reg8.L);   return 1; //      return _BIT(   3, Reg8.L);   //  BIT 3, L
      case (0x5E) : _BIT_HL(3);           return 1; //      return _BIT_HL(3);           //  BIT 3, (HL)
      case (0x5F) : _BIT(   3, Reg8.A);   return 1; //      return _BIT(   3, Reg8.A);   //  BIT 3, A

      case (0x60) : _BIT(   4, Reg8.B);   return 1; //      return _BIT(   4, Reg8.B);   //  BIT 4, B
      case (0x61) : _BIT(   4, Reg8.C);   return 1; //      return _BIT(   4, Reg8.C);   //  BIT 4, C
      case (0x62) : _BIT(   4, Reg8.D);   return 1; //      return _BIT(   4, Reg8.D);   //  BIT 4, D
      case (0x63) : _BIT(   4, Reg8.E);   return 1; //      return _BIT(   4, Reg8.E);   //  BIT 4, E
      case (0x64) : _BIT(   4, Reg8.H);   return 1; //      return _BIT(   4, Reg8.H);   //  BIT 4, H
      case (0x65) : _BIT(   4, Reg8.L);   return 1; //      return _BIT(   4, Reg8.L);   //  BIT 4, L
      case (0x66) : _BIT_HL(4);           return 1; //      return _BIT_HL(4);           //  BIT 4, (HL)
      case (0x67) : _BIT(   4, Reg8.A);   return 1; //      return _BIT(   4, Reg8.A);   //  BIT 4, A

      case (0x68) : _BIT(   5, Reg8.B);   return 1; //      return _BIT(   5, Reg8.B);   //  BIT 5, B
      case (0x69) : _BIT(   5, Reg8.C);   return 1; //      return _BIT(   5, Reg8.C);   //  BIT 5, C
      case (0x6A) : _BIT(   5, Reg8.D);   return 1; //      return _BIT(   5, Reg8.D);   //  BIT 5, D
      case (0x6B) : _BIT(   5, Reg8.E);   return 1; //      return _BIT(   5, Reg8.E);   //  BIT 5, E
      case (0x6C) : _BIT(   5, Reg8.H);   return 1; //      return _BIT(   5, Reg8.H);   //  BIT 5, H
      case (0x6D) : _BIT(   5, Reg8.L);   return 1; //      return _BIT(   5, Reg8.L);   //  BIT 5, L
      case (0x6E) : _BIT_HL(5);           return 1; //      return _BIT_HL(5);           //  BIT 5, (HL)
      case (0x6F) : _BIT(   5, Reg8.A);   return 1; //      return _BIT(   5, Reg8.A);   //  BIT 5, A

      case (0x70) : _BIT(   6, Reg8.B);   return 1; //      return _BIT(   6, Reg8.B);   //  BIT 6, B
      case (0x71) : _BIT(   6, Reg8.C);   return 1; //      return _BIT(   6, Reg8.C);   //  BIT 6, C
      case (0x72) : _BIT(   6, Reg8.D);   return 1; //      return _BIT(   6, Reg8.D);   //  BIT 6, D
      case (0x73) : _BIT(   6, Reg8.E);   return 1; //      return _BIT(   6, Reg8.E);   //  BIT 6, E
      case (0x74) : _BIT(   6, Reg8.H);   return 1; //      return _BIT(   6, Reg8.H);   //  BIT 6, H
      case (0x75) : _BIT(   6, Reg8.L);   return 1; //      return _BIT(   6, Reg8.L);   //  BIT 6, L
      case (0x76) : _BIT_HL(6);           return 1; //      return _BIT_HL(6);           //  BIT 6, (HL)
      case (0x77) : _BIT(   6, Reg8.A);   return 1; //      return _BIT(   6, Reg8.A);   //  BIT 6, A

      case (0x78) : _BIT(   7, Reg8.B);   return 1; //      return _BIT(   7, Reg8.B);   //  BIT 7, B
      case (0x79) : _BIT(   7, Reg8.C);   return 1; //      return _BIT(   7, Reg8.C);   //  BIT 7, C
      case (0x7A) : _BIT(   7, Reg8.D);   return 1; //      return _BIT(   7, Reg8.D);   //  BIT 7, D
      case (0x7B) : _BIT(   7, Reg8.E);   return 1; //      return _BIT(   7, Reg8.E);   //  BIT 7, E
      case (0x7C) : _BIT(   7, Reg8.H);   return 1; //      return _BIT(   7, Reg8.H);   //  BIT 7, H
      case (0x7D) : _BIT(    7, Reg8.L);  return 1; //      return _BIT(    7, Reg8.L);  //  BIT 7, L
      case (0x7E) : _BIT_HL(7);           return 1; //      return _BIT_HL(7);           //  BIT 7, (HL)
      case (0x7F) : _BIT(   7, Reg8.A);   return 1; //      return _BIT(   7, Reg8.A);   //  BIT 7, A

      case (0x80) : _RES(   0, Reg8.B);   return 1; //      return _RES(   0, Reg8.B);   //  RES 0, B
      case (0x81) : _RES(   0, Reg8.C);   return 1; //      return _RES(   0, Reg8.C);   //  RES 0, C
      case (0x82) : _RES(   0, Reg8.D);   return 1; //      return _RES(   0, Reg8.D);   //  RES 0, D
      case (0x83) : _RES(   0, Reg8.E);   return 1; //      return _RES(   0, Reg8.E);   //  RES 0, E
      case (0x84) : _RES(   0, Reg8.H);   return 1; //      return _RES(   0, Reg8.H);   //  RES 0, H
      case (0x85) : _RES(   0, Reg8.L);   return 1; //      return _RES(   0, Reg8.L);   //  RES 0, L
      case (0x86) : _RES_HL(0);           return 1; //      return _RES_HL(0);           //  RES 0, (HL)
      case (0x87) : _RES(   0, Reg8.A);   return 1; //      return _RES(   0, Reg8.A);   //  RES 0, A

      case (0x88) : _RES(   1, Reg8.B);   return 1; //      return _RES(   1, Reg8.B);   //  RES 1, B
      case (0x89) : _RES(   1, Reg8.C);   return 1; //      return _RES(   1, Reg8.C);   //  RES 1, C
      case (0x8A) : _RES(   1, Reg8.D);   return 1; //      return _RES(   1, Reg8.D);   //  RES 1, D
      case (0x8B) : _RES(   1, Reg8.E);   return 1; //      return _RES(   1, Reg8.E);   //  RES 1, E
      case (0x8C) : _RES(   1, Reg8.H);   return 1; //      return _RES(   1, Reg8.H);   //  RES 1, H
      case (0x8D) : _RES(   1, Reg8.L);   return 1; //      return _RES(   1, Reg8.L);   //  RES 1, L
      case (0x8E) : _RES_HL(1);           return 1; //      return _RES_HL(1);           //  RES 1, (HL)
      case (0x8F) : _RES(   1, Reg8.A);   return 1; //      return _RES(   1, Reg8.A);   //  RES 1, A

      case (0x90) : _RES(   2, Reg8.B);   return 1; //      return _RES(   2, Reg8.B);   //  RES 2, B
      case (0x91) : _RES(   2, Reg8.C);   return 1; //      return _RES(   2, Reg8.C);   //  RES 2, C
      case (0x92) : _RES(   2, Reg8.D);   return 1; //      return _RES(   2, Reg8.D);   //  RES 2, D
      case (0x93) : _RES(   2, Reg8.E);   return 1; //      return _RES(   2, Reg8.E);   //  RES 2, E
      case (0x94) : _RES(   2, Reg8.H);   return 1; //      return _RES(   2, Reg8.H);   //  RES 2, H
      case (0x95) : _RES(   2, Reg8.L);   return 1; //      return _RES(   2, Reg8.L);   //  RES 2, L
      case (0x96) : _RES_HL(2);           return 1; //      return _RES_HL(2);           //  RES 2, (HL)
      case (0x97) : _RES(   2, Reg8.A);   return 1; //      return _RES(   2, Reg8.A);   //  RES 2, A

      case (0x98) : _RES(   3, Reg8.B);   return 1; //      return _RES(   3, Reg8.B);   //  RES 3, B
      case (0x99) : _RES(   3, Reg8.C);   return 1; //      return _RES(   3, Reg8.C);   //  RES 3, C
      case (0x9A) : _RES(   3, Reg8.D);   return 1; //      return _RES(   3, Reg8.D);   //  RES 3, D
      case (0x9B) : _RES(   3, Reg8.E);   return 1; //      return _RES(   3, Reg8.E);   //  RES 3, E
      case (0x9C) : _RES(   3, Reg8.H);   return 1; //      return _RES(   3, Reg8.H);   //  RES 3, H
      case (0x9D) : _RES(   3, Reg8.L);   return 1; //      return _RES(   3, Reg8.L);   //  RES 3, L
      case (0x9E) : _RES_HL(3);           return 1; //      return _RES_HL(3);           //  RES 3, (HL)
      case (0x9F) : _RES(   3, Reg8.A);   return 1; //      return _RES(   3, Reg8.A);   //  RES 3, A

      case (0xA0) : _RES(   4, Reg8.B);   return 1; //      return _RES(   4, Reg8.B);   //  RES 4, B
      case (0xA1) : _RES(   4, Reg8.C);   return 1; //      return _RES(   4, Reg8.C);   //  RES 4, C
      case (0xA2) : _RES(   4, Reg8.D);   return 1; //      return _RES(   4, Reg8.D);   //  RES 4, D
      case (0xA3) : _RES(   4, Reg8.E);   return 1; //      return _RES(   4, Reg8.E);   //  RES 4, E
      case (0xA4) : _RES(   4, Reg8.H);   return 1; //      return _RES(   4, Reg8.H);   //  RES 4, H
      case (0xA5) : _RES(   4, Reg8.L);   return 1; //      return _RES(   4, Reg8.L);   //  RES 4, L
      case (0xA6) : _RES_HL(4);           return 1; //      return _RES_HL(4);           //  RES 4, (HL)
      case (0xA7) : _RES(   4, Reg8.A);   return 1; //      return _RES(   4, Reg8.A);   //  RES 4, A

      case (0xA8) : _RES(   5, Reg8.B);   return 1; //      return _RES(   5, Reg8.B);   //  RES 5, B
      case (0xA9) : _RES(   5, Reg8.C);   return 1; //      return _RES(   5, Reg8.C);   //  RES 5, C
      case (0xAA) : _RES(   5, Reg8.D);   return 1; //      return _RES(   5, Reg8.D);   //  RES 5, D
      case (0xAB) : _RES(   5, Reg8.E);   return 1; //      return _RES(   5, Reg8.E);   //  RES 5, E
      case (0xAC) : _RES(   5, Reg8.H);   return 1; //      return _RES(   5, Reg8.H);   //  RES 5, H
      case (0xAD) : _RES(   5, Reg8.L);   return 1; //      return _RES(   5, Reg8.L);   //  RES 5, L
      case (0xAE) : _RES_HL(5);           return 1; //      return _RES_HL(5);           //  RES 5, (HL)
      case (0xAF) : _RES(   5, Reg8.A);   return 1; //      return _RES(   5, Reg8.A);   //  RES 5, A

      case (0xB0) : _RES(   6, Reg8.B);   return 1; //      return _RES(   6, Reg8.B);   //  RES 6, B
      case (0xB1) : _RES(   6, Reg8.C);   return 1; //      return _RES(   6, Reg8.C);   //  RES 6, C
      case (0xB2) : _RES(   6, Reg8.D);   return 1; //      return _RES(   6, Reg8.D);   //  RES 6, D
      case (0xB3) : _RES(   6, Reg8.E);   return 1; //      return _RES(   6, Reg8.E);   //  RES 6, E
      case (0xB4) : _RES(   6, Reg8.H);   return 1; //      return _RES(   6, Reg8.H);   //  RES 6, H
      case (0xB5) : _RES(   6, Reg8.L);   return 1; //      return _RES(   6, Reg8.L);   //  RES 6, L
      case (0xB6) : _RES_HL(6);           return 1; //      return _RES_HL(6);           //  RES 6, (HL)
      case (0xB7) : _RES(   6, Reg8.A);   return 1; //      return _RES(   6, Reg8.A);   //  RES 6, A

      case (0xB8) : _RES(   7, Reg8.B);   return 1; //      return _RES(   7, Reg8.B);   //  RES 7, B
      case (0xB9) : _RES(   7, Reg8.C);   return 1; //      return _RES(   7, Reg8.C);   //  RES 7, C
      case (0xBA) : _RES(   7, Reg8.D);   return 1; //      return _RES(   7, Reg8.D);   //  RES 7, D
      case (0xBB) : _RES(   7, Reg8.E);   return 1; //      return _RES(   7, Reg8.E);   //  RES 7, E
      case (0xBC) : _RES(   7, Reg8.H);   return 1; //      return _RES(   7, Reg8.H);   //  RES 7, H
      case (0xBD) : _RES(   7, Reg8.L);   return 1; //      return _RES(   7, Reg8.L);   //  RES 7, L
      case (0xBE) : _RES_HL(7);           return 1; //      return _RES_HL(7);           //  RES 7, (HL)
      case (0xBF) : _RES(   7, Reg8.A);   return 1; //      return _RES(   7, Reg8.A);   //  RES 7, A

      case (0xC0) : _SET(   0, Reg8.B);   return 1; //      return _SET(   0, Reg8.B);   //  SET 0, B
      case (0xC1) : _SET(   0, Reg8.C);   return 1; //      return _SET(   0, Reg8.C);   //  SET 0, C
      case (0xC2) : _SET(   0, Reg8.D);   return 1; //      return _SET(   0, Reg8.D);   //  SET 0, D
      case (0xC3) : _SET(   0, Reg8.E);   return 1; //      return _SET(   0, Reg8.E);   //  SET 0, E
      case (0xC4) : _SET(   0, Reg8.H);   return 1; //      return _SET(   0, Reg8.H);   //  SET 0, H
      case (0xC5) : _SET(   0, Reg8.L);   return 1; //      return _SET(   0, Reg8.L);   //  SET 0, L
      case (0xC6) : _SET_HL(0);           return 1; //      return _SET_HL(0);           //  SET 6, (HL)
      case (0xC7) : _SET(   0, Reg8.A);   return 1; //      return _SET(   0, Reg8.A);   //  SET 0, A

      case (0xC8) : _SET(   1, Reg8.B);   return 1; //      return _SET(   1, Reg8.B);   //  SET 1, B
      case (0xC9) : _SET(   1, Reg8.C);   return 1; //      return _SET(   1, Reg8.C);   //  SET 1, C
      case (0xCA) : _SET(   1, Reg8.D);   return 1; //      return _SET(   1, Reg8.D);   //  SET 1, D
      case (0xCB) : _SET(   1, Reg8.E);   return 1; //      return _SET(   1, Reg8.E);   //  SET 1, E
      case (0xCC) : _SET(   1, Reg8.H);   return 1; //      return _SET(   1, Reg8.H);   //  SET 1, H
      case (0xCD) : _SET(   1, Reg8.L);   return 1; //      return _SET(   1, Reg8.L);   //  SET 1, L
      case (0xCE) : _SET_HL(1);           return 1; //      return _SET_HL(1);           //  SET 6, (HL)
      case (0xCF) : _SET(   1, Reg8.A);   return 1; //      return _SET(   1, Reg8.A);   //  SET 1, A

      case (0xD0) : _SET(   2, Reg8.B);   return 1; //      return _SET(   2, Reg8.B);   //  SET 2, B
      case (0xD1) : _SET(   2, Reg8.C);   return 1; //      return _SET(   2, Reg8.C);   //  SET 2, C
      case (0xD2) : _SET(   2, Reg8.D);   return 1; //      return _SET(   2, Reg8.D);   //  SET 2, D
      case (0xD3) : _SET(   2, Reg8.E);   return 1; //      return _SET(   2, Reg8.E);   //  SET 2, E
      case (0xD4) : _SET(   2, Reg8.H);   return 1; //      return _SET(   2, Reg8.H);   //  SET 2, H
      case (0xD5) : _SET(   2, Reg8.L);   return 1; //      return _SET(   2, Reg8.L);   //  SET 2, L
      case (0xD6) : _SET_HL(2);           return 1; //      return _SET_HL(2);           //  SET 6, (HL)
      case (0xD7) : _SET(   2, Reg8.A);   return 1; //      return _SET(   2, Reg8.A);   //  SET 2, A

      case (0xD8) : _SET(   3, Reg8.B);   return 1; //      return _SET(   3, Reg8.B);   //  SET 3, B
      case (0xD9) : _SET(   3, Reg8.C);   return 1; //      return _SET(   3, Reg8.C);   //  SET 3, C
      case (0xDA) : _SET(   3, Reg8.D);   return 1; //      return _SET(   3, Reg8.D);   //  SET 3, D
      case (0xDB) : _SET(   3, Reg8.E);   return 1; //      return _SET(   3, Reg8.E);   //  SET 3, E
      case (0xDC) : _SET(   3, Reg8.H);   return 1; //      return _SET(   3, Reg8.H);   //  SET 3, H
      case (0xDD) : _SET(   3, Reg8.L);   return 1; //      return _SET(   3, Reg8.L);   //  SET 3, L
      case (0xDE) : _SET_HL(3);           return 1; //      return _SET_HL(3);           //  SET 6, (HL)
      case (0xDF) : _SET(   3, Reg8.A);   return 1; //      return _SET(   3, Reg8.A);   //  SET 3, A

      case (0xE0) : _SET(   4, Reg8.B);   return 1; //      return _SET(   4, Reg8.B);   //  SET 4, B
      case (0xE1) : _SET(   4, Reg8.C);   return 1; //      return _SET(   4, Reg8.C);   //  SET 4, C
      case (0xE2) : _SET(   4, Reg8.D);   return 1; //      return _SET(   4, Reg8.D);   //  SET 4, D
      case (0xE3) : _SET(   4, Reg8.E);   return 1; //      return _SET(   4, Reg8.E);   //  SET 4, E
      case (0xE4) : _SET(   4, Reg8.H);   return 1; //      return _SET(   4, Reg8.H);   //  SET 4, H
      case (0xE5) : _SET(   4, Reg8.L);   return 1; //      return _SET(   4, Reg8.L);   //  SET 4, L
      case (0xE6) : _SET_HL(4);           return 1; //      return _SET_HL(4);           //  SET 6, (HL)
      case (0xE7) : _SET(   4, Reg8.A);   return 1; //      return _SET(   4, Reg8.A);   //  SET 4, A

      case (0xE8) : _SET(   5, Reg8.B);   return 1; //      return _SET(   5, Reg8.B);   //  SET 5, B
      case (0xE9) : _SET(   5, Reg8.C);   return 1; //      return _SET(   5, Reg8.C);   //  SET 5, C
      case (0xEA) : _SET(   5, Reg8.D);   return 1; //      return _SET(   5, Reg8.D);   //  SET 5, D
      case (0xEB) : _SET(   5, Reg8.E);   return 1; //      return _SET(   5, Reg8.E);   //  SET 5, E
      case (0xEC) : _SET(   5, Reg8.H);   return 1; //      return _SET(   5, Reg8.H);   //  SET 5, H
      case (0xED) : _SET(   5, Reg8.L);   return 1; //      return _SET(   5, Reg8.L);   //  SET 5, L
      case (0xEE) : _SET_HL(5);           return 1; //      return _SET_HL(5);           //  SET 6, (HL)
      case (0xEF) : _SET(   5, Reg8.A);   return 1; //      return _SET(   5, Reg8.A);   //  SET 5, A

      case (0xF0) : _SET(   6, Reg8.B);   return 1; //      return _SET(   6, Reg8.B);   //  SET 6, B
      case (0xF1) : _SET(   6, Reg8.C);   return 1; //      return _SET(   6, Reg8.C);   //  SET 6, C
      case (0xF2) : _SET(   6, Reg8.D);   return 1; //      return _SET(   6, Reg8.D);   //  SET 6, D
      case (0xF3) : _SET(   6, Reg8.E);   return 1; //      return _SET(   6, Reg8.E);   //  SET 6, E
      case (0xF4) : _SET(   6, Reg8.H);   return 1; //      return _SET(   6, Reg8.H);   //  SET 6, H
      case (0xF5) : _SET(   6, Reg8.L);   return 1; //      return _SET(   6, Reg8.L);   //  SET 6, L
      case (0xF6) : _SET_HL(6);           return 1; //      return _SET_HL(6);           //  SET 6, (HL)
      case (0xF7) : _SET(   6, Reg8.A);   return 1; //      return _SET(   6, Reg8.A);   //  SET 6, A

      case (0xF8) : _SET(   7, Reg8.B);   return 1; //      return _SET(   7, Reg8.B);   //  SET 7, B
      case (0xF9) : _SET(   7, Reg8.C);   return 1; //      return _SET(   7, Reg8.C);   //  SET 7, C
      case (0xFA) : _SET(   7, Reg8.D);   return 1; //      return _SET(   7, Reg8.D);   //  SET 7, D
      case (0xFB) : _SET(   7, Reg8.E);   return 1; //      return _SET(   7, Reg8.E);   //  SET 7, E
      case (0xFC) : _SET(   7, Reg8.H);   return 1; //      return _SET(   7, Reg8.H);   //  SET 7, H
      case (0xFD) : _SET(   7, Reg8.L);   return 1; //      return _SET(   7, Reg8.L);   //  SET 7, L
      case (0xFE) : _SET_HL(7);           return 1; //      return _SET_HL(7);           //  SET 6, (HL)
      case (0xFF) : _SET(   7, Reg8.A);   return 1; //      return _SET(   7, Reg8.A);   //  SET 7, A
      default : break;
    }
    throw new Exception('z80: CB Prefix: Opcode ${Ft.toAddressString(op, 4)} not suported');
  }

  /* 8-bits Loads *************************************************************/
  void _LD_r(Reg8 r, int val) {
    assert(val & ~0xFF == 0);
    this.cpur.push8(r, val);
  }

  void _LD_n(int addr, int val) {
    assert(val & ~0xFF == 0);
    _mmu.push8(addr, val);
  }

  /* Registers */
  int _LD_r_r(Reg8 r1, Reg8 r2) {
    final int val = this.cpur.pull8(r2);
    _LD_r(r1, val);
    this.cpur.PC += 1;
    return 4;
  }

  int _LD_r_n(Reg8 r) {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    _LD_r(r, val);
    this.cpur.PC += 2;
    return 8;
  }

  int _LD_r_HL(Reg8 r) {
    final int val = _mmu.pull8(this.cpur.HL);
    _LD_r(r, val);
    this.cpur.PC += 1;
    return 8;
  }

  /* Register Accu */
  int _LD_A_rr(Reg16 r) {
    final int addr = this.cpur.pull16(r);
    final int val = _mmu.pull8(addr);
    _LD_r(Reg8.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  int _LD_A_nn() {
    final int addr = _mmu.pull16(this.cpur.PC + 1);
    final int val = _mmu.pull8(addr);
    _LD_r(Reg8.A, val);
    this.cpur.PC += 3;
    return 16;
  }

  int _LD_A_C() {
    final int val = _mmu.pull8(0xFF00 | this.cpur.C);
    _LD_r(Reg8.A, val);
    this.cpur.PC += 1;
    return 8;
  }

  int _LDI_A_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    _LD_r(Reg8.A, val);
    this.cpur.HL += 1;
    this.cpur.PC += 1;
    return 8;
  }

  int _LDD_A_HL() {
    final int val = _mmu.pull8(this.cpur.HL);
    _LD_r(Reg8.A, val);
    this.cpur.HL -= 1;
    this.cpur.PC += 1;
    return 8;
  }

  int _LD_A_n() {
    final int addr = 0xFF00 | _mmu.pull8(this.cpur.PC + 1);
    final int val = _mmu.pull8(addr);
    _LD_r(Reg8.A, val);
    this.cpur.PC += 2;
    return 12;
  }

  /* Memory */
  int _LD_HL_r(Reg8 r) {
    final int val = this.cpur.pull8(r);
    _LD_n(this.cpur.HL, val);
    this.cpur.PC += 1;
    return 8;
  }

  int _LD_HL_n() {
    final int val = _mmu.pull8(this.cpur.PC + 1);
    _LD_n(this.cpur.HL, val);
    this.cpur.PC += 2;
    return 12;
  }

  /* Memory Accu */
  int _LD_rr_A(Reg16 r) {
    final int addr = this.cpur.pull16(r);
    _LD_n(addr, this.cpur.A);
    this.cpur.PC += 1;
    return 8;
  }

  int _LD_nn_A() {
    final int addr = _mmu.pull16(this.cpur.PC + 1);
    _LD_n(addr, this.cpur.A);
    this.cpur.PC += 3;
    return 16;
  }

  int _LD_C_A() {
    final int addr = 0xFF00 | this.cpur.C;
    _LD_n(addr, this.cpur.A);
    this.cpur.PC += 1;
    return 8;
  }

  int _LDI_HL_A() {
    final int addr = this.cpur.HL;
    _LD_n(addr, this.cpur.A);
    this.cpur.HL += 1;
    this.cpur.PC += 1;
    return 8;
  }

  int _LDD_HL_A() {
    final int addr = this.cpur.HL;
    _LD_n(addr, this.cpur.A);
    this.cpur.HL -= 1;
    this.cpur.PC += 1;
    return 8;
  }

  int _LD_n_A() {
    final int addr = 0xFF00 | _mmu.pull8(this.cpur.PC + 1);
    _LD_n(addr, this.cpur.A);
    this.cpur.PC += 2;
    return 12;
  }

  /* 16-bits Loads ************************************************************/
  int _LD_rr_nn(Reg16 r) {
    final int val = _mmu.pull16(this.cpur.PC + 1);
    this.cpur.push16(r, val);
    this.cpur.PC += 3;
    return 12;
  }

  int _LD_nn_SP() {
    final int addr = _mmu.pull16(this.cpur.PC + 1);
    _mmu.push16(addr, this.cpur.SP);
    this.cpur.PC += 3;
    return 20;
  }

  int _LD_SP_HL() {
    this.cpur.SP = this.cpur.HL;
    this.cpur.PC += 1;
    return 8;
  }

  int _LD_HL_SP_e() {
    final int l = this.cpur.SP;
    final int r = _mmu.pull8(this.cpur.PC + 1).toSigned(16);
    this.cpur.cy = ((l + r) > 0xFFFF) ? 1 : 0;
    this.cpur.h = ((l & 0xFF) + (r & 0xFF) > 0xF) ? 1 : 0;
    this.cpur.n = 0;
    this.cpur.z = 0;
    this.cpur.HL = (l + r) & 0xFFFF;
    this.cpur.PC += 2;
    return 12;
  }

  int _PUSH(Reg16 r) {
    final int val = this.cpur.pull16(r);
    _mmu.push16(this.cpur.SP - 2, val);
    this.cpur.SP -= 2;
    this.cpur.PC += 1;
    return 16;
  }

  int _POP(Reg16 r) {
    final int val = _mmu.pull16(this.cpur.SP);
    this.cpur.push16(r, val);
    this.cpur.SP += 2;
    this.cpur.PC += 1;
    return 12;
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
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
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
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
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
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
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
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
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
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
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

  /* 16-bits ALU **************************************************************/
  int _ADD16_calculate(int l, int r) {
    assert((l & ~0xFFFF == 0) && (r & ~0xFFFF == 0));
    final int calculated = l + r;
    final int result = calculated & 0xFFFF;
    this.cpur.cy = ((l + r) > 0xFFFF) ? 1 : 0;
    this.cpur.h = ((l & 0xFF) + (r & 0xFF) > 0xFF) ? 1 : 0;
    return result;
  }

  int _ADD_HL_rr(Reg16 r) {
    final int val = this.cpur.pull16(r);
    this.cpur.HL = _ADD16_calculate(this.cpur.HL, val);
    this.cpur.n = 0;
    this.cpur.PC += 1;
    return 8;
  }

  int _ADD_SP_e() {
    final int val = _mmu.pull8(this.cpur.PC + 1).toSigned(16);
    this.cpur.HL = _ADD16_calculate(this.cpur.HL, val);
    this.cpur.n = 0;
    this.cpur.z = 0;
    this.cpur.PC += 2;
    return 16;
  }

  int _INC_rr(Reg16 r) {
    final int val = this.cpur.pull16(r);
    final int res = (val + 1) & 0xFFFF;
    this.cpur.push16(r, res);
    this.cpur.PC += 1;
    return 8;
  }

  int _DEC_rr(Reg16 r) {
    final int val = this.cpur.pull16(r);
    final int res = (val - 1) & 0xFFFF;
    this.cpur.push16(r, res);
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
    this.cpur.n = 0;
    this.cpur.h = 0;
    return 4;
  }

  int _SCF() {
    this.cpur.cy = 1;
    this.cpur.n = 0;
    this.cpur.h = 0;
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
    final int result = ((val << 1) | newbit) & 0xFF;
    this.cpur.cy = cy_new;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
    return result;
  }

  int _SR_calculate(int val, int newbit) {
    assert(val & ~0xFF == 0);
    assert(newbit & ~0x1 == 0);
    final int cy_new = val & 0x1;
    final int result = (val >> 1) | (newbit << 7);
    this.cpur.cy = cy_new;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
    return result;
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
    final int result = h | (l << 4);
    this.cpur.cy = 0;
    this.cpur.h = 0;
    this.cpur.n = 0;
    this.cpur.z = (result == 0) ? 0x1 : 0x0;
    return result;
  }

  int _SWAP(Reg8 r) {
    final int val = this.cpur.pull8(r);
    final int res = _SWAP_calculate(val);
    this.cpur.push8(r, res);
    this.cpur.PC += 2;
    return 8;
  }

  int _SWAP_HL() {
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
    final int offset = _mmu.pull8(this.cpur.PC + 1).toSigned(16);
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
