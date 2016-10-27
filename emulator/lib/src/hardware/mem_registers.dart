// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 23:40:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/mem_registers_info.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

/* MemRegs ********************************************************************/
class MemRegs extends Ser.RecursivelySerializable {
// class MemRegs {

  Uint8List _data;

  /* Constructors *************************************************************/
  MemRegs.ofList(Uint8List l) : _data = l;

  MemRegs() : this.ofList(new Uint8List(g_memRegInfos.length));

  /* API **********************************************************************/
  RegisterP1 rP1 = new RegisterP1();
  RegisterDIV rDIV = new RegisterDIV();
  RegisterTIMA rTIMA = new RegisterTIMA();
  RegisterLCDC rLCDC = new RegisterLCDC();
  RegisterSTAT rSTAT = new RegisterSTAT();
  RegisterTAC rTAC = new RegisterTAC();

  void reset() {
   for (MemRegInfo mrinfo in g_memRegInfos) {
      this.push8(mrinfo.reg, mrinfo.initValue);
    }
    return ;
  }

  /* Getters */
  int get P1 => this.rP1.value;
  int get DIV => this.rDIV.value;
  int get TIMA => this.rTIMA.value;
  int get TAC => this.rTAC.value;
  int get LCDC => this.rLCDC.value;
  int get STAT => this.rSTAT.value;

  int get SB => _data[MemReg.SB.index];
  int get SC => _data[MemReg.SC.index];
  int get TMA => _data[MemReg.TMA.index];
  int get IF => _data[MemReg.IF.index];
  int get SCY => _data[MemReg.SCY.index];
  int get SCX => _data[MemReg.SCX.index];
  int get LY => _data[MemReg.LY.index];
  int get LYC => _data[MemReg.LYC.index];
  int get DMA => _data[MemReg.DMA.index];
  int get BGP => _data[MemReg.BGP.index];
  int get OBP0 => _data[MemReg.OBP0.index];
  int get OBP1 => _data[MemReg.OBP1.index];
  int get WY => _data[MemReg.WY.index];
  int get WX => _data[MemReg.WX.index];
  int get KEY1 => _data[MemReg.KEY1.index];
  int get VBK => _data[MemReg.VBK.index];
  int get HDMA1 => _data[MemReg.HDMA1.index];
  int get HDMA2 => _data[MemReg.HDMA2.index];
  int get HDMA3 => _data[MemReg.HDMA3.index];
  int get HDMA4 => _data[MemReg.HDMA4.index];
  int get HDMA5 => _data[MemReg.HDMA5.index];
  int get RP => _data[MemReg.RP.index];
  int get BGPI => _data[MemReg.BGPI.index];
  int get BGPD => _data[MemReg.BGPD.index];
  int get OBPI => _data[MemReg.OBPI.index];
  int get OBPD => _data[MemReg.OBPD.index];
  int get SVBK => _data[MemReg.SVBK.index];
  int get IE => _data[MemReg.IE.index];

  /* Setters */
  void set P1(int v) { this.rP1.value = v; }
  void set DIV(int v) { this.rDIV.value = v; }
  void set TIMA(int v) { this.rTIMA.value = v; }
  void set TAC(int v) { this.rTAC.value = v; }
  void set LCDC(int v) { this.rLCDC.value = v; }
  void set STAT(int v) { this.rSTAT.value = v; }

  void set SB(int v) { _data[MemReg.SB.index] = v; }
  void set SC(int v) { _data[MemReg.SC.index] = v; }
  void set TMA(int v) { _data[MemReg.TMA.index] = v; }
  void set IF(int v) { _data[MemReg.IF.index] = v; }
  void set SCY(int v) { _data[MemReg.SCY.index] = v; }
  void set SCX(int v) { _data[MemReg.SCX.index] = v; }
  void set LY(int v) { _data[MemReg.LY.index] = v; }
  void set LYC(int v) { _data[MemReg.LYC.index] = v; }
  void set DMA(int v) { _data[MemReg.DMA.index] = v; }
  void set BGP(int v) { _data[MemReg.BGP.index] = v; }
  void set OBP0(int v) { _data[MemReg.OBP0.index] = v; }
  void set OBP1(int v) { _data[MemReg.OBP1.index] = v; }
  void set WY(int v) { _data[MemReg.WY.index] = v; }
  void set WX(int v) { _data[MemReg.WX.index] = v; }
  void set KEY1(int v) { _data[MemReg.KEY1.index] = v; }
  void set VBK(int v) { _data[MemReg.VBK.index] = v; }
  void set HDMA1(int v) { _data[MemReg.HDMA1.index] = v; }
  void set HDMA2(int v) { _data[MemReg.HDMA2.index] = v; }
  void set HDMA3(int v) { _data[MemReg.HDMA3.index] = v; }
  void set HDMA4(int v) { _data[MemReg.HDMA4.index] = v; }
  void set HDMA5(int v) { _data[MemReg.HDMA5.index] = v; }
  void set RP(int v) { _data[MemReg.RP.index] = v; }
  void set BGPI(int v) { _data[MemReg.BGPI.index] = v; }
  void set BGPD(int v) { _data[MemReg.BGPD.index] = v; }
  void set OBPI(int v) { _data[MemReg.OBPI.index] = v; }
  void set OBPD(int v) { _data[MemReg.OBPD.index] = v; }
  void set SVBK(int v) { _data[MemReg.SVBK.index] = v; }
  void set IE(int v) { _data[MemReg.IE.index] = v; }

  int pull8(MemReg r) {
    switch (r) {
      case (MemReg.P1) : return this.P1;
      case (MemReg.DIV) : return this.DIV;
      case (MemReg.TIMA) : return this.TIMA;
      case (MemReg.TAC) : return this.TAC;
      case (MemReg.LCDC) : return this.LCDC;
      case (MemReg.STAT) : return this.STAT;
      default : return _data[r.index];
    }
  }

  int push8(MemReg r, int v) {
    switch (r) {
      case (MemReg.P1) : this.P1 = v; break ;
      case (MemReg.DIV) : this.DIV = v; break ;
      case (MemReg.TIMA) : this.TIMA = v; break ;
      case (MemReg.TAC) : this.TAC = v; break ;
      case (MemReg.LCDC) : this.LCDC = v; break ;
      case (MemReg.STAT) : this.STAT = v; break ;
      default : _data[r.index] = v; break ;
    }
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[rP1, rDIV, rTIMA, rLCDC, rSTAT, rTAC];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_data', () => new Uint8List.fromList(_data), (v) {
            _data = new Uint8List.fromList(v);
          }),
   ];
  }

}

/* Specific Registers *********************************************************/

/*
* Depending on last writen value in b4 and b5, reading to FF00 will return the
* states of either buttons or directions.
* The attribute joypadState stores the state of all keys.
* Reading from FF00 will build the answer based on joypadState.
* !!! Reading to the Joypad return the complementary of the states (ie 0 = set)
*
* Wiring of Joypad input:              Implementation via joypadState:
*
*   FF00H                                  joypadState
*   +---+                                   +---+
*   | 7 |                                   | 7 +--- Start
*   |   |                                   |   |
*   | 6 |                                   | 6 +--- Select
*   |   |                                   |   |
*   | 5 +-------------------+               | 5 +--- B
*   |   |                   |               |   |
*   | 4 +---------+         |               | 4 +--- A
*   |   |    Down |   Start |               |   |
*   | 3 +---------+---------+ - R3          | 3 +--- Down
*   |   |      Up |  Select |               |   |
*   | 2 +---------+---------+ - R2          | 2 +--- Up
*   |   |    Left |       B |               |   |
*   | 1 +---------+---------+ - R1          | 1 +--- Left
*   |   |   Right |       A |               |   |
*   | 0 +---------+---------+ - R0          | 0 +--- Right
*   +---+         |         |               +---+
*                C0        C1
*/
class RegisterP1 extends Ser.RecursivelySerializable {

  RegisterP1();

  bool returnDirections = false;
  int joypadState = 0;

  int get value {
    if (returnDirections)
      return ~((0x0F & (this.joypadState >> 0)) | 0x10) & 0x3F;
    else
      return ~((0x0F & (this.joypadState >> 4)) | 0x20) & 0x3F;
  }

  int set value (int v) {
    if (v & 0x10 == 0x0)
      this.returnDirections = true;
    else
      this.returnDirections = false;
  }

  int getKey(JoypadKey k) {
    return (this.joypadState >> k.index) & 0x1;
  }

  void setKey(JoypadKey k) {
    this.joypadState |= (1 << k.index);
    return ;
  }

  void unsetKey(JoypadKey k) {
    this.joypadState &= ~(1 << k.index);
    return ;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('returnDirections', () => returnDirections, (v) => returnDirections = v),
      new Ser.Field('joypadState', () => joypadState, (v) => joypadState = v),
    ];
  }

}

/* LCDC ***********************************************************************/
class RegisterLCDC extends Ser.RecursivelySerializable {

  RegisterLCDC();

  int _value;
  bool _isLCDEnabled;
  bool _isWindowDisplayEnabled;
  bool _isSpriteDisplayEnabled;
  bool _isBackgroundDisplayEnabled;
  int _tileDataSelectID;
  int _tileMapID_BG;
  int _tileMapID_WIN;
  int _spriteSize;

  int get value => _value;
  bool get isLCDEnabled => _isLCDEnabled;
  bool get isWindowDisplayEnabled => _isWindowDisplayEnabled;
  bool get isSpriteDisplayEnabled => _isSpriteDisplayEnabled;
  bool get isBackgroundDisplayEnabled => _isBackgroundDisplayEnabled;
  int get tileDataSelectID => _tileDataSelectID;
  int get tileMapID_BG => _tileMapID_BG;
  int get tileMapID_WIN => _tileMapID_WIN;
  int get spriteSize => _spriteSize;

  void set value(int v) {
    _isLCDEnabled = (v >> 7) & 0x1 == 1;
    _isBackgroundDisplayEnabled = (v >> 0) & 0x1 == 1;
    _isWindowDisplayEnabled = (v >> 5) & 0x1 == 1;
    _isSpriteDisplayEnabled = (v >> 1) & 0x1 == 1;
    _tileDataSelectID = (v >> 4) & 0x1;
    _tileMapID_BG = (v >> 3) & 0x1;
    _tileMapID_WIN = (v >> 6) & 0x1;
    _spriteSize = (v >> 2) & 0x1 == 1 ? 16 : 8;
    _value = v;
    return ;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_value', () => _value, (v) => _value = v),
      new Ser.Field('_isLCDEnabled', () => _isLCDEnabled, (v) => _isLCDEnabled = v),
      new Ser.Field('_isWindowDisplayEnabled', () => _isWindowDisplayEnabled, (v) => _isWindowDisplayEnabled = v),
      new Ser.Field('_isSpriteDisplayEnabled', () => _isSpriteDisplayEnabled, (v) => _isSpriteDisplayEnabled = v),
      new Ser.Field('_isBackgroundDisplayEnabled', () => _isBackgroundDisplayEnabled, (v) => _isBackgroundDisplayEnabled = v),
      new Ser.Field('_tileDataSelectID', () => _tileDataSelectID, (v) => _tileDataSelectID = v),
      new Ser.Field('_tileMapID_BG', () => _tileMapID_BG, (v) => _tileMapID_BG = v),
      new Ser.Field('_tileMapID_WIN', () => _tileMapID_WIN, (v) => _tileMapID_WIN = v),
      new Ser.Field('_spriteSize', () => _spriteSize, (v) => _spriteSize = v),
    ];
  }

}

/* STAT ***********************************************************************/
class RegisterSTAT extends Ser.RecursivelySerializable {

  RegisterSTAT();

  int counter = 0;

  int _value = 0;
  int get value => _value;
  int set value(int v) {
    final int lowbits = _value & 0x7;
    _value = (v & ~0x7) | lowbits;
  } /* Set value to avoid messing with modes/coincidence ???*/

  GraphicMode get mode => GraphicMode.values[_value & 0x3];
  void set mode(GraphicMode gm) {
    _value = (_value & ~0x3) | gm.index;
  }

  void set coincidence (bool coincidence) {
    if (coincidence)
      _value = (_value | (1 << 2));
    else
      _value = (_value & ~(1 << 2));
  }

  bool isInterruptMonitored(GraphicInterrupt i) {
    return (_value >> (i.index + 3)) & 0x1 == 1;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('counter', () => counter, (v) => counter = v),
      new Ser.Field('_value', () => _value, (v) => _value = v),
    ];
  }

}

/* TIMERS *********************************************************************/
class RegisterDIV extends Ser.RecursivelySerializable {

  RegisterDIV();

  int value;
  int counter = 0;

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('value', () => value, (v) => value = v),
      new Ser.Field('counter', () => counter, (v) => counter = v),
    ];
  }

}

class RegisterTIMA extends Ser.RecursivelySerializable {

  RegisterTIMA();

  int value;

  int counter = 0;
  int threshold = 1024;

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('value', () => value, (v) => value = v),
      new Ser.Field('counter', () => counter, (v) => counter = v),
      new Ser.Field('threshold', () => threshold, (v) => threshold = v),
    ];
  }

}

class RegisterTAC extends Ser.RecursivelySerializable {

  int _value;

  int get value => _value;
  int set value(int v) { _value = v & 0x7; }

  int get frequency {
    switch(_value & 0x3) {
      case (0): return 1024;
      case (1): return 16;
      case (2): return 64;
      case (3): return 256;
      default : assert(false, '_getTimerFrequency: switch failure');
    }
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_value', () => _value, (v) => _value = v),
    ];
  }

}
