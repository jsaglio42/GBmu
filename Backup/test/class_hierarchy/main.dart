// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/24 11:01:36 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/24 14:48:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:math' as math;

enum MemReg {Mdr}
enum RomHeaderField {Mdr}

class CpuRegs {

}
class LCDScreen {


}


class GameBoy {
  final CpuRegs cpuRegs;
  final Mmu      mmu;
  Cartridge cartridge;
  final LCDScreen lcd;
  final Headset sound;

  // loop () {


  // }

  void onEmulationStart(string gameName)
  {
    final rom = ...;
    final ram_option = ...;


    var mbc0cart = new CartMbc1(rom, ram_option);
    mmu.init(mbc0cart as IMbc);
    cpuRegs.init();

  }

  // _cartridge.rom.pullHeader(RomHeaderField.checksum);
  // _mmu.cartridge.rom.pullHeader(RomHeaderField.checksum);
}


class Mmu {
  final IMbc _mbc;
  final Uint8List _wRam;
  final Uint8List _vRam;
  final Uint8List _tailRam;


  Mmu(this._mbc);

  int pullMem(int memAddr) {
    if (memAddr < 0x4242)
      return _mbc.pullMem(memAddr);
    else if (...)
      ...;
    else
      ...;
  }
  void pushMem(int memAddr, int v) {}
  int pullMemReg(MemReg r) => 0x42; //sucre
  void pushMemReg(MemReg r, int v) {} //sucre
}

class Rom {
  final Uint8List _data;
  Rom(this._data);

  int pull(int romAddr) => 0x42;
  dynamic pullHeader(RomHeaderField f) {} //sucr
  int get size => _data.length;
}

abstract class Cartridge {
  final Rom rom;
  Cartridge(this.rom);
}
abstract class IMbc {
  int pullMem(int memAddr);
  void pushMem(int memAddr, int v);
}
class Mbc0Cart extends Cartridge implements IMbc {

  Mbc0Cart(Rom r)
    : super(r);

  @override int pullMem(int memAddr)
  {
    return 0;
  }
  @override void pushMem(int memAddr, int v)
  {

   }
}

final int GB_CPU_FREQ_INT = 7000000; // instr / second
final double GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();

final int ROUTINE_PER_SEC_INT = 30; // routine / second
final double ROUTINE_PER_SEC_DOUBLE = ROUTINE_PER_SEC_INT.toDouble();

final double ROUTINE_PERIOD_DOUBLE = 1.0 / (ROUTINE_PER_SEC_DOUBLE); // second

final int MAXIMUM_INSTR_PER_EXEC_INT = 100;

double now() => 42.0;

class Lol {
  double _rescheduleTime = now();
  double _emulationSpeed;
  double _instrDeficit;
  double _instrPerRoutineGoal;

  _reschedule(var f, double duration) {

  }

  _exec(int numIntr) {
    return ;
  }

  onEmulationSpeedChange(double speed)
  {
    _emulationSpeed = speed;
    _instrPerRoutineGoal =
      GB_CPU_FREQ_INT * ROUTINE_PERIOD_DOUBLE * _emulationSpeed;
    _instrDeficit = 0.0;
  }

  onRoutine(_)
  {
    int instrSum = 0;
    int instrExec;
    final double timeLimit = _rescheduleTime + ROUTINE_PERIOD_DOUBLE;
    final double instrDebt = _instrPerRoutineGoal + _instrDeficit;
    final int instrLimit = instrDebt.floor();

    while (true) {
      if (now() > timeLimit)
        break ;
      if (instrSum >= instrLimit)
        break ;
      instrExec = math.min(MAXIMUM_INSTR_PER_EXEC_INT, instrLimit - instrSum);
      _exec(instrExec);
      instrSum += instrExec;
    }
    _instrDeficit = instrDebt - instrSum.toDouble();
    _rescheduleTime = timeLimit;
    _reschedule(onRoutine, _rescheduleTime - now());
    return 42;
  }
}


  // Debug:
main () {
  print('Hello World');
  final d = new Uint8List.fromList([42, 43]);
  final r = new Rom(d);
  final c = new Mbc0Cart(r);
  final m = new Mmu(c);

  final l = new Lol();
  l.onEmulationSpeedChange(1.0);
  l.onRoutine(42);
  l.onRoutine(42);
  l.onRoutine(42);

}
