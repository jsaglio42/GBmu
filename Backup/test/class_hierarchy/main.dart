// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/24 11:01:36 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/24 17:02:00 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:async' as As;
import 'dart:math' as math;

enum MemReg {Mdr}
enum RomHeaderField {Mdr}

class CpuRegs {

}
class LCDScreen {


}


class GameBoy {
  final CpuRegs  _cpuRegs = new CpuRegs();
  final Mmu      _mmu;

  // Keeping Cartridge here to easily access rom header info
  final Cartridge _cartridge;
  int _instrCount = 0;

  int get instrCount => _instrCount;
  // final LCDScreen _lcd;
  // final Headset _sound;

  void _exec(int numIntr) {
    _instrCount += numIntr;
    return ;
  }

  GameBoy(Cartridge c) //TODO: pass LCDScreen and Headset
    : _cartridge = c
    , _mmu = new Mmu(c);
}

class Mmu {
  final IMbc _mbc;
  final Uint8List _wRam;
  final Uint8List _vRam;
  final Uint8List _tailRam;

  Mmu(this._mbc);

  int pullMem(int memAddr) {
    if (true)
      return _mbc.pullMem(memAddr);
    // else if (...)
    //   ...;
    // else
    //   ...;
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

class Ram {
  final Uint8List _data;
  Ram(this._data);

  int pull(int ramAddr) => 0x42;
  void push(int ramAddr, int v) {}
  int get size => _data.length;
}

abstract class Cartridge {
  final Rom rom;
  final Ram ram;
  Cartridge(this.rom, this.ram);
}
abstract class IMbc {
  int pullMem(int memAddr);
  void pushMem(int memAddr, int v);
}
class Mbc0Cart extends Cartridge implements IMbc {

  Mbc0Cart(Rom rom, Ram ram)
    : super(rom, ram);

  @override int pullMem(int memAddr)
  {
    if (true)
      this.rom.pull(memAddr + 0x42);
    return 0;
  }
  @override void pushMem(int memAddr, int v)
  {

   }
}
final int GB_CPU_FREQ_INT = 4194304; // instr / second
final double GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();

final int ROUTINE_PER_SEC_INT = 30; // routine /second
final double ROUTINE_PER_SEC_DOUBLE = ROUTINE_PER_SEC_INT.toDouble();

final double MICROSEC_PER_SECOND = 1000000.0;

final double ROUTINE_PERIOD_DOUBLE = 1.0 / (ROUTINE_PER_SEC_DOUBLE); // second
final Duration ROUTINE_PERIOD_DURATION =
  new Duration(
      microseconds: (ROUTINE_PERIOD_DOUBLE * MICROSEC_PER_SECOND).round());

// Pick a number close to (GB_CPU_FREQ_INT / ROUTINE_PER_SEC_INT = 139810)
final int MAXIMUM_INSTR_PER_EXEC_INT = 100000;

DateTime now() => new DateTime.now();

class Worker {
  DateTime _emulationStartTime = now();
  DateTime _rescheduleTime = now();
  bool _pause = false;
  double _emulationSpeed = 1000.0;
  double _instrDeficit;
  double _instrPerRoutineGoal;
  GameBoy _gb;

  As.Timer _tm;
  _reschedule(var f, Duration d) {
    _tm = new As.Timer(d, f);
  }

  onEmulationSpeedChange(double speed)
  {
    assert(!(speed < 0));
    _emulationSpeed = speed;
    _instrPerRoutineGoal =
      GB_CPU_FREQ_INT * ROUTINE_PERIOD_DOUBLE * _emulationSpeed;
    _instrDeficit = 0.0;
  }

  void _debug() {
    final Duration emulationElapsedTime = _rescheduleTime.difference(_emulationStartTime);
    final double elapsed = emulationElapsedTime.inMicroseconds.toDouble() / MICROSEC_PER_SECOND;
    final double routineId = elapsed / ROUTINE_PERIOD_DOUBLE;

    print('Worker.onRoutine('
        'elapsed:$emulationElapsedTime, '
        'routineId:$routineId, '
        'clocks:${_gb.instrCount} (deficit:$_instrDeficit)'
        ')');
  }

  onRoutine()
  {
    _debug();
    int instrSum = 0;
    int instrExec;
    final DateTime timeLimit = _rescheduleTime.add(ROUTINE_PERIOD_DURATION);
    final double instrDebt = _instrPerRoutineGoal + _instrDeficit;
    final int instrLimit = instrDebt.floor();

    if (_pause)
      _instrDeficit = 0.0;
    else {
      while (true) {
        if (now().compareTo(timeLimit) >= 0)
          break ;
        if (instrSum >= instrLimit)
          break ;
        instrExec = math.min(MAXIMUM_INSTR_PER_EXEC_INT, instrLimit - instrSum);
        _gb._exec(instrExec);
        instrSum += instrExec;
      }
      _instrDeficit = instrDebt - instrSum.toDouble();
    }
    _rescheduleTime = timeLimit;
    _reschedule(onRoutine, _rescheduleTime.difference(now()));
    return ;
  }

  void onEmulationStart(String gameName)
  {
    final drom = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final dram = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final rom = new Rom(drom);
    final ram = new Ram(dram);

    //TODO: Select right constructon giving r.pullHeader(RomHeaderField.Cartridge_Type)
    // and try catch to detect errors;
    final c = new Mbc0Cart(rom, ram);
    _gb = new GameBoy(c);

    this.onEmulationSpeedChange(_emulationSpeed);
    _reschedule(onRoutine, new Duration(seconds:0));
    return ;
  }

}

  // Debug:
main () {
  print('Hello World');

  var w = new Worker();

  w.onEmulationStart('lol');

}
