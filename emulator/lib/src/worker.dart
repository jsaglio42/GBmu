// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 14:49:50 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
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

// Number should be close to (GB_CPU_FREQ_INT / EMULATION_PER_SEC_INT = 139810)
const int MAXIMUM_INSTR_PER_EXEC_INT = 100000;
const double MICROSEC_PER_SECOND = 1000000.0;

const int GB_CPU_FREQ_INT = 4194304; // instr / second
const int EMULATION_PER_SEC_INT = 120; // emulation /second
const int DEBUG_PER_SEC_INT = 3; // debug / second
const int FRAME_PER_SEC_INT = 60; // frame / second

final double GB_CPU_FREQ_DOUBLE = GB_CPU_FREQ_INT.toDouble();
final double EMULATION_PER_SEC_DOUBLE = EMULATION_PER_SEC_INT.toDouble();
final double DEBUG_PER_SEC_DOUBLE = DEBUG_PER_SEC_INT.toDouble();
final double FRAME_PER_SEC_DOUBLE = FRAME_PER_SEC_INT.toDouble();

final Duration EMULATION_PERIOD_DURATION = new Duration(
    microseconds: (MICROSEC_PER_SECOND / EMULATION_PER_SEC_DOUBLE).round());
final Duration DEBUG_PERIOD_DURATION = new Duration(
    microseconds: (MICROSEC_PER_SECOND / DEBUG_PER_SEC_DOUBLE).round());
final Duration FRAME_PERIOD_DURATION = new Duration(
    microseconds: (MICROSEC_PER_SECOND / FRAME_PER_SEC_DOUBLE).round());

DateTime now() => new DateTime.now();

class Worker {

  final Wiso.Ports _ports;
  Ft.Option<Gameboy.GameBoy> _gb = new Ft.Option.none();

  // Emulation variables
  bool _pause = false;
  Async.Timer _emulationTimer;
  DateTime _rescheduleTime = now();
  double _emulationSpeed = 1.0;
  double _instrDeficit;
  double _instrPerRoutineGoal;

  // Debugger variables
  DebStatus _debuggerStatus = DebStatus.ON;
  DateTime _emulationStartTime = now();
  Async.Timer _debuggerTimer;

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationMode').listen(_onEmulationMode);
    _ports.listener('DebStatusRequest').listen(_onDebuggerStateChange);
    _debuggerTimer = new Async.Timer.periodic(DEBUG_PERIOD_DURATION, onDebug);
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

  void onEmulationSpeedChange(double speed)
  {
    assert(!(speed < 0));
    _emulationSpeed = speed;
    _instrPerRoutineGoal =
      GB_CPU_FREQ_DOUBLE / EMULATION_PER_SEC_DOUBLE * _emulationSpeed;
    _instrDeficit = 0.0;
  }

  void onEmulation()
  {
    int instrSum = 0;
    int instrExec;
    final DateTime timeLimit = _rescheduleTime.add(EMULATION_PERIOD_DURATION);
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
        _gb.data.exec(instrExec);
        instrSum += instrExec;
      }
      _instrDeficit = instrDebt - instrSum.toDouble();
    }
    _rescheduleTime = timeLimit;
    _emulationTimer =
      new Async.Timer(_rescheduleTime.difference(now()), onEmulation);
    return ;
  }

  void onDebug(_)
  {
    if (_gb.isSome && _debuggerStatus == DebStatus.ON) {
      final l = new Uint8List(MemReg.values.length);
      final it = new Ft.DoubleIterable(MemReg.values, Memregisters.memRegInfos);

      _ports.send('RegInfo', _gb.data.cpuRegs);
      it.forEach((r, i) {
        l[r.index] = _gb.data.mmu.pullMemReg(r);
      });
      _ports.send('MemRegInfo', l);
    }

    print('A LA BOUFFE!');
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
    _gb = new Ft.Option<Gameboy.GameBoy>.some(new Gameboy.GameBoy(c));
    this.onEmulationSpeedChange(_emulationSpeed);
    this.onEmulation();
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

  // void _debug() {
  //   final Duration emulationElapsedTime = _rescheduleTime.difference(_emulationStartTime);
  //   final double elapsed = emulationElapsedTime.inMicroseconds.toDouble() / MICROSEC_PER_SECOND;
  //   final double emulationId = elapsed * EMULATION_PER_SEC_DOUBLE;

  //   print('Worker.onEmulation('
  //       'elapsed:$emulationElapsedTime, '
  //       'emulationId:$emulationId, '
  //       'clocks:${_gb.instrCount} (deficit:$_instrDeficit)'
  //       ')');
  // }
