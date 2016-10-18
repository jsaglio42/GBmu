// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cpu_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/15 19:17:54 by jsaglio          ###   ########.fr       //
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
  cy, h, n, zf
}

class CpuRegs {

  final Uint8List _data;
  final Uint16List _view16;

  bool ime;
  bool halt;
  bool stop;

  /* Constructors *************************************************************/
  CpuRegs.ofUint8List(Uint8List d)
    : _data = d
    , _view16 = d.buffer.asUint16List();

  CpuRegs() : this.ofUint8List(new Uint8List(6 * 2));

  /* API **********************************************************************/
  void reset() {
    this.ime = true;
    this.halt = false;
    this.stop = false;
    this.AF = 0x01B0;
    this.BC = 0x0013;
    this.DE = 0x00D8;
    this.HL = 0x014D;
    this.SP = 0xFFFE;
    this.PC = 0x0100; 
  }

  /* Get */
  int get AF => this.pull16(Reg16.AF);
  int get BC => this.pull16(Reg16.BC);
  int get DE => this.pull16(Reg16.DE);
  int get HL => this.pull16(Reg16.HL);
  int get SP => this.pull16(Reg16.SP);
  int get PC => this.pull16(Reg16.PC);
  int get F => this.pull8(Reg8.F);
  int get A => this.pull8(Reg8.A);
  int get C => this.pull8(Reg8.C);
  int get B => this.pull8(Reg8.B);
  int get E => this.pull8(Reg8.E);
  int get D => this.pull8(Reg8.D);
  int get L => this.pull8(Reg8.L);
  int get H => this.pull8(Reg8.H);
  int get cy => this.pull1(Reg1.cy);
  int get h => this.pull1(Reg1.h);
  int get n => this.pull1(Reg1.n);
  int get z => this.pull1(Reg1.zf);

  int pull16(Reg16 r) => this._view16[r.index];
  int pull8(Reg8 r) => this._data[r.index];
  int pull1(Reg1 r) => (this._data[0] >> (r.index + 4)) & 0x1;

  /* Set */
  void set AF(int v) {this.push16(Reg16.AF, v);}
  void set BC(int v) {this.push16(Reg16.BC, v);}
  void set DE(int v) {this.push16(Reg16.DE, v);}
  void set HL(int v) {this.push16(Reg16.HL, v);}
  void set SP(int v) {this.push16(Reg16.SP, v);}
  void set PC(int v) {this.push16(Reg16.PC, v);}
  /* No setter for flag F */
  void set A(int v) {this.push8(Reg8.A, v);}
  void set C(int v) {this.push8(Reg8.C, v);}
  void set B(int v) {this.push8(Reg8.B, v);}
  void set E(int v) {this.push8(Reg8.E, v);}
  void set D(int v) {this.push8(Reg8.D, v);}
  void set L(int v) {this.push8(Reg8.L, v);}
  void set H(int v) {this.push8(Reg8.H, v);}
  void set cy(int v) {this.push1(Reg1.cy, v);}
  void set n(int v) {this.push1(Reg1.n, v);}
  void set h(int v) {this.push1(Reg1.h, v);}
  void set z(int v) {this.push1(Reg1.zf, v);}

  void push16(Reg16 r, int word) {
    assert(word & ~0xFFFF == 0);
    this._view16[r.index] = word;
  }

  void push8(Reg8 r, int byte) {
    assert(byte & ~0xFF == 0);
    this._data[r.index] = byte;
  }

  void push1(Reg1 r, int val) {
    final mask = 1 << (4 + r.index);
    if (val == 0)
      this._data[0] = this._data[0] & (~mask);
    else
      this._data[0] = this._data[0] | mask;
   }

}

/* Debug **********************************************************************/

// void assertCorrectness(CpuRegs cpu) {
//   for (int i = 0; i < 12 ; i++)
//     cpu._data[i] = i;

//   assert(cpu.pull1(Reg1.cy) == 0);
//   assert(cpu.pull1(Reg1.n) == 0);
//   assert(cpu.pull1(Reg1.h) == 0);
//   assert(cpu.pull1(Reg1.zf) == 0);
//   assert(cpu.pull8(Reg8.A) == 0x1);
//   assert(cpu.pull16(Reg16.AF) == 0x0100);

//   assert(cpu.pull8(Reg8.C) == 0x2);
//   assert(cpu.pull8(Reg8.B) == 0x3);
//   assert(cpu.pull16(Reg16.BC) == 0x0302);

//   assert(cpu.pull8(Reg8.E) == 0x4);
//   assert(cpu.pull8(Reg8.D) == 0x5);
//   assert(cpu.pull16(Reg16.DE) == 0x0504);

//   assert(cpu.pull8(Reg8.L) == 0x6);
//   assert(cpu.pull8(Reg8.H) == 0x7);
//   assert(cpu.pull16(Reg16.HL) == 0x0706);

//   assert(cpu.pull16(Reg16.SP) == 0x0908);
//   assert(cpu.pull16(Reg16.PC) == 0x0B0A);

//   for (int i = 0; i < 12 ; i++)
//     cpu._data[i] = 0;

//   cpu.push1(Reg1.cy, 1);
//   cpu.push1(Reg1.n, 0);
//   cpu.push1(Reg1.h, 0);
//   cpu.push1(Reg1.zf, 1);
//   cpu.push8(Reg8.A, 0x5);

//   cpu.push8(Reg8.C, 0x6);
//   cpu.push8(Reg8.B, 0x7);

//   cpu.push8(Reg8.E, 0x8);
//   cpu.push8(Reg8.D, 0x9);

//   cpu.push8(Reg8.L, 0xA);
//   cpu.push8(Reg8.H, 0xB);

//   cpu.push16(Reg16.SP, 0x0C0D);
//   cpu.push16(Reg16.PC, 0x0E0F);

//   assert(cpu._data[0] == (1 << 7) | (1 << 4));
//   assert(cpu._data[1] == 0x5);
//   assert(cpu._view16[0] == (cpu._data[0] << 0) | (cpu._data[1] << 8));
//   assert(cpu._data[2] == 0x6);
//   assert(cpu._data[3] == 0x7);
//   assert(cpu._view16[1] == cpu._data[2] | (cpu._data[3] << 8));
//   assert(cpu._data[4] == 0x8);
//   assert(cpu._data[5] == 0x9);
//   assert(cpu._view16[2] == cpu._data[4] | (cpu._data[5] << 8));
//   assert(cpu._data[6] == 0xA);
//   assert(cpu._data[7] == 0xB);
//   assert(cpu._view16[3] == cpu._data[6] | (cpu._data[7] << 8));
//   assert(cpu._data[8] == 0xD);
//   assert(cpu._data[9] == 0xC);
//   assert(cpu._view16[4] == cpu._data[8] | (cpu._data[9] << 8));
//   assert(cpu._data[10] == 0xF);
//   assert(cpu._data[11] == 0xE);
//   assert(cpu._view16[5] == cpu._data[10] | (cpu._data[11] << 8));
//   print('CpuRegs.assertCorrectness passed!');
// }

// void main() {
//   assertCorrectness(new CpuRegs());
// }
