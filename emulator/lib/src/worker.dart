// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 15:45:19 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as math;
import 'dart:typed_data';
// import 'dart:isolate' as Is;
// import 'dart:async' as As;
import 'package:ft/wired_isolate.dart' as WI;

// import './emulator.dart' as Em;
import './public_classes.dart';
import './memory/rom.dart';
import './memory/ram.dart';
import './memory/cartmbc0.dart';



import 'cpu_registers.dart' as CPUR;
import 'gameboy.dart';

// var rng = new math.Random();
// Map _generateRandomMapFromIterable(Iterable l, int value_range)
// {
//   final size = math.max(1, rng.nextInt(l.length));
//   final m = {};
//   var v;

//   for (int i = 0; i < size; i++) {
//     v = l.elementAt(rng.nextInt(l.length));
//     m[v] = rng.nextInt(value_range);
//   }
//   return m;
// }

import 'dart:typed_data';
import 'dart:async' as As;
import 'dart:math' as math;

 // Number close to (GB_CPU_FREQ_INT / ROUTINE_PER_SEC_INT = 139810)
final int MAXIMUM_INSTR_PER_EXEC_INT = 100000;

final int       GB_CPU_FREQ_INT = 4194304; // instr / second
final double    GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();
final int       ROUTINE_PER_SEC_INT = 30; // routine /second
final double    ROUTINE_PER_SEC_DOUBLE = ROUTINE_PER_SEC_INT.toDouble();
final double    MICROSEC_PER_SECOND = 1000000.0;
final Duration  ROUTINE_PERIOD_DURATION_MS =
  new Duration(
      microseconds: (MICROSEC_PER_SECOND / ROUTINE_PER_SEC_DOUBLE).round());

DateTime now() => new DateTime.now();


class Worker {

  final WI.Ports _ports;
  DebStatus      _debuggerStatus = DebStatus.ON;  

  As.Timer  _tm;
  DateTime  _rescheduleTime = now();
  bool      _pause = false;
  double    _emulationSpeed = 0.3 / GB_CPU_FREQ_DOUBLE;
  double    _instrDeficit;
  double    _instrPerRoutineGoal;
  GameBoy   _gb;

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
    _tm = new As.Timer(d, f);
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
        instrExec = math.min(MAXIMUM_INSTR_PER_EXEC_INT, instrLimit - instrSum);
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
    final rom = new Rom(drom);
    final ram = new Ram(dram);

    //TODO: Select right constructon giving r.pullHeader(RomHeaderField.Cartridge_Type)
    // and try catch to detect errors;
    final c = new CartMbc0(rom, ram);
    _gb = new GameBoy(c);

    this.onEmulationSpeedChange(_emulationSpeed);
    _reschedule(onRoutine, new Duration(seconds:0));
    return ;
  }

}

Worker _globalWorker;

void entryPoint(WI.Ports p)
{
  print('worker:\tentryPoint($p)');
  assert(_globalWorker == null);
  _globalWorker = new Worker(p);
  return ;
}





