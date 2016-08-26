// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 20:55:34 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;

DateTime now() => new DateTime.now();

class Worker {

  final Wiso.Ports _ports;
  Ft.Option<Gameboy.GameBoy> _gb = new Ft.Option.none();

  // Emulation variables
  bool _pause = false;
  Async.Timer _emulationTimer;
  DateTime _rescheduleTime;
  double _emulationSpeed = 1.0 / GB_CPU_FREQ_DOUBLE * 2.0;
  double _clockDeficit;
  double _clockPerRoutineGoal;

  // Debugger variables
  DebStatus _debuggerStatus = DebStatus.ON;
  DateTime _emulationStartTime = now();
  Async.Timer _debuggerTimer;
  final int _debuggerMemoryLen = 144; // <- bad, should be initialised by dom
  int _debuggerMemoryAddr = 0;

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationSpeed').listen(onEmulationSpeedChange);
    _ports.listener('DebStatusRequest').listen(_onDebuggerStateChange);
    _ports.listener('DebMemAddrChange').listen(_onMemoryAddrChange);
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
    print('worker:\tonEmulationSpeedChange($speed)');
    // if (!(speed < 100.0))
      // speed = 1000000000000.0;
    assert(!(speed < 0));
    _emulationSpeed = speed;
    _clockPerRoutineGoal =
      GB_CPU_FREQ_DOUBLE / EMULATION_PER_SEC_DOUBLE * _emulationSpeed;
    _clockDeficit = 0.0;
  }

  void onEmulation()
  {
    int clockSum = 0;
    int clockExec;
    final DateTime timeLimit = _rescheduleTime.add(EMULATION_PERIOD_DURATION);
    final double clockDebt = _clockPerRoutineGoal + _clockDeficit;
    final int clockLimit = clockDebt.floor();

    if (clockDebt >= 1.0)
      print('debt: $clockDebt');
    if (_pause)
      _clockDeficit = 0.0;
    else {
      while (true) {
        if (now().compareTo(timeLimit) >= 0)
          break ;
        if (clockSum >= clockLimit)
          break ;
        clockExec = Math.min(MAXIMUM_CLOCK_PER_EXEC_INT, clockLimit - clockSum);
        _gb.data.exec(clockExec);
        clockSum += clockExec;
      }
      _clockDeficit = clockDebt - clockSum.toDouble();
    }
    _rescheduleTime = timeLimit;
    _emulationTimer =
      new Async.Timer(_rescheduleTime.difference(now()), onEmulation);
    return ;
  }

  void onDebug(_)
  {
    print(now());
    if (_gb.isSome && _debuggerStatus == DebStatus.ON) {
      final l = new Uint8List(MemReg.values.length);
      final it = new Ft.DoubleIterable(MemReg.values, Memregisters.memRegInfos);

      _ports.send('RegInfo', _gb.data.cpuRegs);
      it.forEach((r, i) {
        l[r.index] = _gb.data.mmu.pullMemReg(r);
      });
      _ports.send('MemRegInfo', l);
      _ports.send('ClockInfo', _gb.data.clockCount);
    }
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
    _emulationStartTime = now();
    _rescheduleTime = _emulationStartTime.add(FIRST_EMULATION_SCHEDULE_LAG);
    _emulationTimer =
      new Async.Timer(_rescheduleTime.difference(now()), onEmulation);
    return ;
  }

  void _onMemoryAddrChange(int addr)
  {
    print('worker:\tonMemoryAddrChange($addr)');
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
      , '_onMemoryAddrChange: addr not valid');
    _debuggerMemoryAddr = addr;
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
