// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_emulation.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 20:34:15 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

final Map<AutoBreakMode, int> _autoBreakClocks = {
  AutoBreakMode.Instruction: 1,
  AutoBreakMode.Frame: GB_FRAME_PER_CLOCK_INT,
  AutoBreakMode.Second: GB_CPU_FREQ_INT,
};

abstract class Emulation implements Worker.AWorker {

  Ft.Routine<GameBoyExternalMode> _rout;
  Async.Timer _timerOrNull = null;

  bool _simulateCrash = false;

  double _emulationSpeed = 1.0;
  double _clockDeficit;
  double _clockPerRoutineGoal;

  int _emulationCount;
  DateTime _emulationStartTime;
  DateTime _rescheduleTime;

  AutoBreakMode _autoBreak = AutoBreakMode.None;
  int _autoBreakIn;

  // EXTERNAL CONTROL ******************************************************* **

  void _onAutoBreakReq(AutoBreakMode abRaw)
  {
    final AutoBreakMode ab = AutoBreakMode.values[abRaw.index];

    Ft.log('worker_emu', '_onAutoBreakReq', abRaw);
    assert(ab != _autoBreak, '_onAutoBreakReq($ab)');
    // _autoBreak = ab;
    // if (ab != AutoBreakMode.None)
    //   _autoBreakIn = _autoBreakClocks[ab];
  }

  // Allowing extMode == Pause because of auto-breaks
  // Not allowing pause if gb absent
  // Not allowing pause if gb crashed
  void _onPauseReq(_)
  {
    // Ft.log('worker_emu', '_onPauseReq');
    // if (_rout.externalMode == GameBoyExternalMode.Emulating) {
    //   _updateMode(GameBoyExternalMode.Paused);
    //   this.ports.send('EmulationPause', 42);
    // }
  }

  void _onResumeReq(_)
  {
    // Ft.log('worker_emu', '_onResumeReq');
    // assert(_rout.externalMode == GameBoyExternalMode.Paused,
    //        "_onResumeReq() while not paused");
    // if (_autoBreak != AutoBreakMode.None)
    //   _autoBreakIn = _autoBreakClocks[_autoBreak];
    // _updateMode(GameBoyExternalMode.Emulating);
    // this.ports.send('EmulationResume', 42);
  }

  void _onEmulationSpeedChangeReq(map)
  {
    Ft.log('worker_emu', '_onEmulationSpeedChangeReq', map);
    assert(map['speed'] != null && map['speed'] is double,
        "_onEmulationSpeedChangeReq($map)");
    _updateEmulationSpeed(map['speed']);
  }

  void _onEmulationStartReq(Uint8List l) //TODO: Retrieve string from indexDB
  {
    var gb;

    Ft.log('worker_emu', '_onEmulationStartReq');
    try {
      gb = _assembleGameBoy(l);
    }
    catch (e) {
      // TODO: broadcast error
      return ;
    }
    _updateEmulationSpeed(_emulationSpeed);
    this.gbOpt = new Ft.Option.some(gb);
    _updateMode(GameBoyExternalMode.Emulating);
    return ;
  }

  void _onEjectReq(_)
  {
    Ft.log('worker_emu', '_onEjectReq');
    assert(_rout.externalMode != GameBoyExternalMode.Absent,
        "_onEjectReq with no gameboy");
    _updateMode(GameBoyExternalMode.Absent);
  }

  // INTERNAL CONTROL ******************************************************* **

  void _updateEmulationSpeed(double speed)
  {
    Ft.log('worker_emu', '_updateEmulationSpeed');
    assert(!(speed < 0.0), "_updateEmulationSpeed($speed)");
    if (speed.isFinite) {
      _emulationSpeed = speed;
      _clockPerRoutineGoal =
        GB_CPU_FREQ_DOUBLE / EMULATION_PER_SEC_DOUBLE * _emulationSpeed;
    }
    else {
      _emulationSpeed = double.INFINITY;
      _clockPerRoutineGoal = double.INFINITY;
    }
    _clockDeficit = 0.0;
  }

  void _updateMode(GameBoyExternalMode m)
  {
    _rout.changeExternalMode(m);
    this.ports.send('EmulationStatus', m);
  }

  Gameboy.GameBoy _assembleGameBoy(Uint8List l)
  {
    final drom = l; //TODO: Retrieve from indexedDB
    final dram = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final irom = new Rom.Rom(drom);
    final iram = new Ram.Ram(dram);
    //TODO: Select right constructon giving r.pullHeader(RomHeaderField.Cartridge_Type)
    final c = new Cartmbc0.CartMbc0(irom, iram);
    return new Gameboy.GameBoy(c);
  }

  int _emulate(final DateTime timeLimit, final int clockLimit)
  {
    int clockSum = 0;
    int clockExec;

    if (_simulateCrash) {
      _simulateCrash = false;
      throw new Exception('Simulated crash');
    }
    while (true) {
      if (Ft.now().compareTo(timeLimit) >= 0)
        break ;
      if (clockSum >= clockLimit)
        break ;
      clockExec = Math.min(MAXIMUM_CLOCK_PER_EXEC_INT, clockLimit - clockSum);
      this.gbOpt.v.exec(clockExec);
      clockSum += clockExec;
    }
    return clockSum;
  }

  int _clockLimitOfClockDebt(double clockDebt)
  {
    // if (_autoBreak != AutoBreakMode.None)
    //   return Math.min(clockDebt.floor(), _autoBreakIn);
    // else
      if (clockDebt.isInfinite)
      return double.INFINITY.toInt();
    else
      return clockDebt.floor();
  }


  // ROUTINE CONTROL ******************************************************** **

  void _onEmulation()
  {
    // Ft.log('worker_emu', '_onEmulation', _emulationCount);

    int clockSum;
    var error = null;
    final DateTime timeLimit = _rescheduleTime.add(EMULATION_PERIOD_DURATION);
    final double clockDebt = _clockPerRoutineGoal + _clockDeficit;
    final int clockLimit = _clockLimitOfClockDebt(clockDebt);

    try {
      clockSum = _emulate(timeLimit, clockLimit);
    }
    catch (e) {
      clockSum = 0;
      error = e;
    }
    _clockDeficit = clockDebt - clockSum.toDouble();
    _emulationCount++;
    _rescheduleTime = _emulationStartTime.add(
        EMULATION_PERIOD_DURATION * _emulationCount);
    _timerOrNull = null;
    _timerOrNull = new Async.Timer(
        _rescheduleTime.difference(Ft.now()), _onEmulation);
    if (error != null) {
      _updateMode(GameBoyExternalMode.Crashed);
      // TODO: broadcast error
    }
    // else if (_autoBreak != AutoBreakMode.None) {
    //   _autoBreakIn -= clockSum;
    //   if (_autoBreakIn <= 0) {
    //     _updateMode(GameBoyExternalMode.Paused);
    //     this.ports.send('EmulationPause', 42);
    //   }
    // }
    return ;
  }

  void _makeLooping()
  {
    Ft.log('worker_emu', '_makeLooping');
    assert(_timerOrNull == null, "_makeLooping() with some timer");
    _clockDeficit = 0.0;
    _emulationStartTime = Ft.now().add(EMULATION_START_DELAY);
    _rescheduleTime = _emulationStartTime;
    _emulationCount = 0;
    _timerOrNull = new Async.Timer(EMULATION_START_DELAY, _onEmulation);
  }

  void _makeDormant()
  {
    Ft.log('worker_emu', '_makeDormant');
    assert(_timerOrNull != null && _timerOrNull.isActive,
        "_makeDormant with no timer");
    _timerOrNull.cancel();
    _timerOrNull = null;
  }

  // CONSTRUCTION *********************************************************** **

  void init_emulation()
  {
    Ft.log('worker_emu', 'init_emulation');
    _rout = new Ft.Routine<GameBoyExternalMode>(
        this.rc, [GameBoyExternalMode.Emulating], _makeLooping, _makeDormant,
        GameBoyExternalMode.Absent);
    this.ports.listener('EmulationStart')
      .forEach(_onEmulationStartReq);
    this.ports.listener('Debug')
      .forEach((Map map){
        if (map['action'] == 'crash') {
          _simulateCrash = true;
          Ft.log('worker_emu', 'faking_crash');
        }
      });
    this.ports.listener('Debug')
      .where((map) => map['action'] == 'eject')
      .forEach(_onEjectReq);
    this.ports.listener('EmulationSpeed')
      .listen(_onEmulationSpeedChangeReq);
    this.ports.listener('EmulationAutoBreak')
      .listen(_onAutoBreakReq);
    // this.ports.listener('EmulationPause')
    //   .listen(_onPauseReq);
    // this.ports.listener('EmulationResume')
    //   .listen(_onResumeReq);
  }

}
