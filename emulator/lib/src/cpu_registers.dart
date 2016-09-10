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

/* http://bgb.bircd.org/pandocs.htm
 * Registers
 * 16bit Hi   Lo   Name/Function
 * AF    A    F    Accumulator & Flags
 * BC    B    C    BC
 * DE    D    E    DE
 * HL    H    L    HL
 * SP    -    -    Stack Pointer
 * PC    -    -    Program Counter/Pointer
 *
 * The Flag Register (lower 8bit of AF register)
 * Bit  Name  Set Clr  Expl.
 * 7    zf    Z   NZ   Zero Flag
 * 6    n     -   -    Add/Sub-Flag (BCD)
 * 5    h     -   -    Half Carry Flag (BCD)
 * 4    cy    C   NC   Carry Flag
 * 3-0  -     -   -    Not used (always zero)
 */

enum Reg16 {
  AF, BC, DE, HL, SP, PC
}
enum Reg8 {
  F, A, C, B, E, D, L, H,
}
enum Reg1 {
  cy, n, h, zf
}

class CpuRegs {

  final Uint8List _data;
  final Uint16List _view16;

  /*
  ** Constructors **************************************************************
  */

  CpuRegs.buffer(Uint8List d)
    : _data = d
    , _view16 = d.buffer.asUint16List();

  CpuRegs() : this.buffer(new Uint8List(6 * 2));

  /*
  ** API ***********************************************************************
  */

  void init()
  {
    this.AF = 0x01B0;
    this.BC = 0x0013;
    this.DE = 0x00D8;
    this.HL = 0x014D;
    this.SP = 0xFFFE;
    this.PC = 0x0100;
  }

  void load(CpuRegs src)
  {
    for (Reg16 r in Reg16.Value) {
      this.update16(r, src.value16(r));
    }
  }

  /* Set */

  int get AF => this.value16(Reg16.AF);
  int get BC => this.value16(Reg16.BC);
  int get DE => this.value16(Reg16.DE);
  int get HL => this.value16(Reg16.HL);
  int get SP => this.value16(Reg16.SP);
  int get PC => this.value16(Reg16.PC);
  int get F => this.value8(Reg8.F);
  int get A => this.value8(Reg8.A);
  int get C => this.value8(Reg8.C);
  int get B => this.value8(Reg8.B);
  int get E => this.value8(Reg8.E);
  int get D => this.value8(Reg8.D);
  int get L => this.value8(Reg8.L);
  int get H => this.value8(Reg8.H);
  bool get cy => this.value1(Reg1.cy);
  bool get n => this.value1(Reg1.n);
  bool get h => this.value1(Reg1.h);
  bool get zf => this.value1(Reg1.zf);

  int value16(Reg16 r) => this._view16[r.index];
  int value8(Reg8 r) => this._data[r.index];
  bool value1(Reg1 r) => (this._data[0] >> (r.index + 4) & 1) == 1;

  /* Set */

  void set AF(int v) {this.update16(Reg16.AF, v);}
  void set BC(int v) {this.update16(Reg16.BC, v);}
  void set DE(int v) {this.update16(Reg16.DE, v);}
  void set HL(int v) {this.update16(Reg16.HL, v);}
  void set SP(int v) {this.update16(Reg16.SP, v);}
  void set PC(int v) {this.update16(Reg16.PC, v);}
  void set F(int v) {this.update8(Reg8.F, v);}
  void set A(int v) {this.update8(Reg8.A, v);}
  void set C(int v) {this.update8(Reg8.C, v);}
  void set B(int v) {this.update8(Reg8.B, v);}
  void set E(int v) {this.update8(Reg8.E, v);}
  void set D(int v) {this.update8(Reg8.D, v);}
  void set L(int v) {this.update8(Reg8.L, v);}
  void set H(int v) {this.update8(Reg8.H, v);}
  void set cy(bool v) {this.update1(Reg1.cy, v);}
  void set n(bool v) {this.update1(Reg1.n, v);}
  void set h(bool v) {this.update1(Reg1.h, v);}
  void set zf(bool v) {this.update1(Reg1.zf, v);}

  void update16(Reg16 r, int word) {
    assert(word & ~0xFFFF == 0);
    this._view16[r.index] = word;
  }

  void update8(Reg8 r, int byte) {
    assert(byte & ~0xFF == 0);
    this._data[r.index] = byte;
  }

  void update1(Reg1 r, bool value) {
    final mask = 1 << (4 + r.index);
    if (value)
      this._data[0] = this._data[0] | mask;
    else
      this._data[0] = this._data[0] & (~mask);
  }

  /*
  ** Debug *********************************************************************
  */

  void assertCorrectness() {
    for (int i = 0; i < 12 ; i++)
      _data[i] = i;

    assert(this.value1(Reg1.cy) == false);
    assert(this.value1(Reg1.n) == false);
    assert(this.value1(Reg1.h) == false);
    assert(this.value1(Reg1.zf) == false);
    assert(this.value8(Reg8.A) == 0x1);
    assert(this.value16(Reg16.AF) == 0x0100);

    assert(this.value8(Reg8.C) == 0x2);
    assert(this.value8(Reg8.B) == 0x3);
    assert(this.value16(Reg16.BC) == 0x0302);

    assert(this.value8(Reg8.E) == 0x4);
    assert(this.value8(Reg8.D) == 0x5);
    assert(this.value16(Reg16.DE) == 0x0504);

    assert(this.value8(Reg8.L) == 0x6);
    assert(this.value8(Reg8.H) == 0x7);
    assert(this.value16(Reg16.HL) == 0x0706);

    assert(this.value16(Reg16.SP) == 0x0908);
    assert(this.value16(Reg16.PC) == 0x0B0A);

    for (int i = 0; i < 12 ; i++)
      _data[i] = 0;

    this.update1(Reg1.cy, true);
    this.update1(Reg1.n, false);
    this.update1(Reg1.h, false);
    this.update1(Reg1.zf, true);
    this.update8(Reg8.A, 0x5);

    this.update8(Reg8.C, 0x6);
    this.update8(Reg8.B, 0x7);

    this.update8(Reg8.E, 0x8);
    this.update8(Reg8.D, 0x9);

    this.update8(Reg8.L, 0xA);
    this.update8(Reg8.H, 0xB);

    this.update16(Reg16.SP, 0x0C0D);
    this.update16(Reg16.PC, 0x0E0F);

    assert(_data[0] == (1 << 7) | (1 << 4));
    assert(_data[1] == 0x5);
    assert(_view16[0] == (_data[0] << 0) | (_data[1] << 8));
    assert(_data[2] == 0x6);
    assert(_data[3] == 0x7);
    assert(_view16[1] == _data[2] | (_data[3] << 8));
    assert(_data[4] == 0x8);
    assert(_data[5] == 0x9);
    assert(_view16[2] == _data[4] | (_data[5] << 8));
    assert(_data[6] == 0xA);
    assert(_data[7] == 0xB);
    assert(_view16[3] == _data[6] | (_data[7] << 8));
    assert(_data[8] == 0xD);
    assert(_data[9] == 0xC);
    assert(_view16[4] == _data[8] | (_data[9] << 8));
    assert(_data[10] == 0xF);
    assert(_data[11] == 0xE);
    assert(_view16[5] == _data[10] | (_data[11] << 8));
    print('CpuRegs.assertCorrectness passed!');
  }
}
