// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:46:13 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;

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

final int       GB_CPU_FREQ_INT = 4194304; // instr / second
final double    GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();
final int       ROUTINE_PER_SEC_INT = 30; // routine /second
final double    ROUTINE_PER_SEC_DOUBLE = ROUTINE_PER_SEC_INT.toDouble();
final double    MICROSEC_PER_SECOND = 1000000.0;
final Duration  ROUTINE_PERIOD_DURATION_MS = new Duration(
    microseconds: (MICROSEC_PER_SECOND / ROUTINE_PER_SEC_DOUBLE).round());

 // Number should be close to (GB_CPU_FREQ_INT / ROUTINE_PER_SEC_INT = 139810)
final int MAXIMUM_INSTR_PER_EXEC_INT = 100000;

DateTime now() => new DateTime.now();


class Worker {

  final Wiso.Ports _ports;
  DebStatus      _debuggerStatus = DebStatus.ON;

  Async.Timer  _tm;
  DateTime  _rescheduleTime = now();
  bool      _pause = false;
  double    _emulationSpeed = 0.3 / GB_CPU_FREQ_DOUBLE;
  double    _instrDeficit;
  double    _instrPerRoutineGoal;
  Gameboy.GameBoy   _gb;

  // For Debug
  DateTime _emulationStartTime = now();

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationMode').listen(_onEmulationMode);
    _ports.listener('DebStatusRequest').listen(_onDebuggerStateChange);
  }

  void _disableDebugger()
  {
    _debuggerStatus = DebStatus.OFF;
    _ports.send('DebStatusUpdate', _debuggerStatus);
  }

  void _enableDebugger()
  {
    _debuggerStatus = DebStatus.ON;
    _ports.send('DebStatusUpdate', _debuggerStatus);
  }


  void _onEmulationMode(String p)
  {
    print('worker:\tonEmulationMode($p)');
    return ;
  }

  void _onDebuggerStateChange(DebStatusRequest p)
  {
    print('worker:\tonDebuggerStateChange($p ${p.index})');

    // Enum equality fails after passing through a SendPort
    if (p.index == DebStatusRequest.TOGGLE.index) {
        if (_debuggerStatus == DebStatus.ON)
          _disableDebugger();
        else
          _enableDebugger();
    }
    else if (p.index == DebStatusRequest.DISABLE.index) {
      if (_debuggerStatus == DebStatus.ON)
        _disableDebugger();
    }
    else if (p.index == DebStatusRequest.ENABLE.index) {
        if (_debuggerStatus == DebStatus.OFF)
          _enableDebugger();
    }
    return ;
  }

  _reschedule(var f, Duration d) {
    _tm = new Async.Timer(d, f);
  }

  onEmulationSpeedChange(double speed)
  {
    assert(!(speed < 0));
    _emulationSpeed = speed;
    _instrPerRoutineGoal =
      GB_CPU_FREQ_DOUBLE / ROUTINE_PER_SEC_DOUBLE * _emulationSpeed;
    _instrDeficit = 0.0;
  }

  void _debug() {
    final Duration emulationElapsedTime = _rescheduleTime.difference(_emulationStartTime);
    final double elapsed = emulationElapsedTime.inMicroseconds.toDouble() / MICROSEC_PER_SECOND;
    final double routineId = elapsed * ROUTINE_PER_SEC_DOUBLE;

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
    final DateTime timeLimit = _rescheduleTime.add(ROUTINE_PERIOD_DURATION_MS);
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
        instrExec = Math.min(MAXIMUM_INSTR_PER_EXEC_INT, instrLimit - instrSum);
        _gb.exec(instrExec);
        instrSum += instrExec;
      }
      _instrDeficit = instrDebt - instrSum.toDouble();
    }
    _rescheduleTime = timeLimit;
    _reschedule(onRoutine, _rescheduleTime.difference(now()));
    return ;
  }

  void _onEmulationStart(Uint8List l)
  {
    final drom = l; //TODO: Retrieve from indexedDB
    final dram = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final irom = new Rom.Rom(drom);
    final iram = new Ram.Ram(dram);

    //TODO: Select right constructon giving r.pullHeader(RomHeaderField.Cartridge_Type)
    // and try catch to detect errors;
    final c = new Cartmbc0.CartMbc0(irom, iram);
    _gb = new Gameboy.GameBoy(c);

    this.onEmulationSpeedChange(_emulationSpeed);
    _reschedule(onRoutine, new Duration(seconds:0));
    return ;
  }

}

Worker _globalWorker;

void entryPoint(Wiso.Ports p)
{
  print('worker:\tentryPoint($p)');
  assert(_globalWorker == null);
  _globalWorker = new Worker(p);
  return ;
}
