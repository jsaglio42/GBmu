// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_emulation.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 10:26:56 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/src/memory/data.dart' as Data;
import 'package:emulator/src/memory/cartridge.dart' as Cartridge;
// import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;

import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

final List<List> _loopingGBCombos = [
  [GameBoyExternalMode.Emulating, DebuggerExternalMode.Dismissed],
  [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective]
];

final List<List> _activeAutoBreakCombos = [
  [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective, AutoBreakExternalMode.Instruction],
  [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective, AutoBreakExternalMode.Frame],
  [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective, AutoBreakExternalMode.Second],
];

final Map<AutoBreakExternalMode, int> _autoBreakClocks = {
  AutoBreakExternalMode.Instruction: 4,
  AutoBreakExternalMode.Frame: GB_FRAME_PER_CLOCK_INT,
  AutoBreakExternalMode.Second: GB_CPU_FREQ_INT,
};

abstract class Emulation implements Worker.AWorker {

  Async.Timer _timerOrNull = null;

  bool _simulateCrash = false;

  double _emulationSpeed = 1.0;
  double _clockDeficit;
  double _clockPerRoutineGoal;

  int _emulationCount;
  DateTime _emulationStartTime;
  DateTime _rescheduleTime;

  bool _autoBreak = false;
  int _autoBreakIn;

  // EXTERNAL INTERFACE ***************************************************** **

  void _onAutoBreakReq(AutoBreakExternalMode abRaw)
  {
    final AutoBreakExternalMode ab = AutoBreakExternalMode.values[abRaw.index];

    Ft.log(Ft.typeStr(this), '_onAutoBreakReq', [ab]);
    assert(this.abMode != ab, '_onAutoBreakReq($ab) twice');
    this.sc.setState(ab);
  }

  void _onPauseReq(_)
  {
    Ft.log(Ft.typeStr(this), '_onPauseReq');
    if (this.pauseMode != PauseExternalMode.Effective)
      _updatePauseMode(PauseExternalMode.Effective);
  }

  void _onResumeReq(_)
  {
    Ft.log(Ft.typeStr(this), '_onResumeReq');
    if (this.pauseMode != PauseExternalMode.Ineffective)
      _updatePauseMode(PauseExternalMode.Ineffective);
  }

  void _onEmulationSpeedChangeReq(map)
  {
    Ft.log(Ft.typeStr(this), '_onEmulationSpeedChangeReq', [map]);
    assert(map['speed'] != null && map['speed'] is double,
        "_onEmulationSpeedChangeReq($map)");
    _updateEmulationSpeed(map['speed']);
  }

  void _onEmulationStartReq(Uint8List l) //TODO: Retrieve string from indexDB
  {
    var gb;

    Ft.log(Ft.typeStr(this), '_onEmulationStartReq');
    try {
      gb = _assembleGameBoy(l);
    }
    catch (e) {
      this.ports.send('Events', <String, dynamic>{
        'type': EmulatorEvent.InitError,
        'msg': e,
      });
      return ;
    }
    _updateEmulationSpeed(_emulationSpeed);
    this.gbOpt = gb;
    _updateGBMode(GameBoyExternalMode.Emulating);
    if (this.debMode == DebuggerExternalMode.Operating
        && this.pauseMode != PauseExternalMode.Effective)
      _updatePauseMode(PauseExternalMode.Effective);
    this.ports.send('Events', <String, dynamic>{
      'type': EmulatorEvent.GameBoyStart,
      'msg': "Plokemon violet.rom",
    });
    return ;
  }

  void _onEjectReq(_)
  {
    Ft.log(Ft.typeStr(this), '_onEjectReq');
    assert(this.gbMode != GameBoyExternalMode.Absent,
        "_onEjectReq with no gameboy");
    _updateGBMode(GameBoyExternalMode.Absent);
    this.ports.send('Events', <String, dynamic>{
      'type': EmulatorEvent.GameBoyEject,
      'msg': "bye bye Plokemon violet.rom",
    });
  }

  // SECONDARY ROUTINES ***************************************************** **

  void _updateEmulationSpeed(double speed)
  {
    Ft.log(Ft.typeStr(this), '_updateEmulationSpeed', [speed]);
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

  void _updateGBMode(GameBoyExternalMode m)
  {
    Ft.log(Ft.typeStr(this), '_updateGBMode', [m]);
    this.sc.setState(m);
    this.ports.send('EmulationStatus', m);
  }

  void _updatePauseMode(PauseExternalMode m)
  {
    Ft.log(Ft.typeStr(this), '_updatePauseMode', [m]);
    this.sc.setState(m);
    if (m == PauseExternalMode.Effective)
      this.ports.send('EmulationPause', 42);
    else
      this.ports.send('EmulationResume', 42);
  }

  Gameboy.GameBoy _assembleGameBoy(Uint8List l)
  {
    final drom = l; //TODO: Retrieve from indexedDB
    final dram = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final irom = new Data.Rom(drom);
    final iram = new Data.Ram(dram);
    final c = new Cartridge.ACartridge(irom); //TODO: Take iram as parameter
    return new Gameboy.GameBoy(c);
  }

  // LOOPING ROUTINE ******************************************************** **

  void _onEmulation()
  {
    int clockSum;
    var error, stacktrace;
    final DateTime timeLimit = _rescheduleTime.add(EMULATION_PERIOD_DURATION);
    final double clockDebt = _clockPerRoutineGoal + _clockDeficit;
    final int clockLimit = _clockLimitOfClockDebt(clockDebt);

    try {
      clockSum = _emulate(timeLimit, clockLimit);
    }
    catch (e, st) {
      // Ft.logwarn(Ft.typeStr(this), '_onEmulation#try', [e, st]);
      clockSum = 0;
      error = e;
      stacktrace = st;
    }
    _clockDeficit = clockDebt - clockSum.toDouble();
    _emulationCount++;
    _rescheduleTime = _emulationStartTime.add(
        EMULATION_PERIOD_DURATION * _emulationCount);
    _timerOrNull = null;
    _timerOrNull = new Async.Timer(
        _rescheduleTime.difference(Ft.now()), _onEmulation);
    if (error != null) {
      _updateGBMode(GameBoyExternalMode.Crashed);
      this.ports.send('Events', <String, dynamic>{
        'type': EmulatorEvent.GameBoyCrash,
        'msg': error.toString(),
        'st': stacktrace.toString(),
      });
    }
    else if (_autoBreak) {
      _autoBreakIn -= clockSum;
      if (_autoBreakIn <= 0)
        _updatePauseMode(PauseExternalMode.Effective);
    }
    return ;
  }

  int _clockLimitOfClockDebt(double clockDebt)
  {
    if (this._autoBreak && clockDebt.isFinite)
      return Math.min(clockDebt.floor(), _autoBreakIn);
    else if (this._autoBreak && !clockDebt.isFinite)
      return _autoBreakIn;
    else if (clockDebt.isInfinite)
      return MAX_INT_LOLDART;
    else
      return clockDebt.floor();
  }

  int _emulate(final DateTime timeLimit, final int clockLimit)
  {
    int clockSum = 0;
    int clockExec;

    if (_simulateCrash) {
      Ft.log(Ft.typeStr(this), '_emulate#simulateCrash');
      _simulateCrash = false;
      throw new Exception('Simulated crash');
    }
    while (true) {
      if (Ft.now().compareTo(timeLimit) >= 0)
        break ;
      if (clockSum >= clockLimit)
        break ;
      clockExec = Math.min(MAXIMUM_CLOCK_PER_EXEC_INT, clockLimit - clockSum);
      clockSum += this.gbOpt.exec(clockExec);
    }
    return clockSum;
  }

  // SIDE EFFECTS CONTROLS ************************************************** **

  void _makeLooping()
  {
    Ft.log(Ft.typeStr(this), '_makeLooping');
    assert(_timerOrNull == null, "_makeLooping() with some timer");
    _clockDeficit = 0.0;
    _emulationStartTime = Ft.now().add(EMULATION_START_DELAY);
    _rescheduleTime = _emulationStartTime;
    _emulationCount = 0;
    _timerOrNull = new Async.Timer(EMULATION_START_DELAY, _onEmulation);
  }

  void _makeDormant()
  {
    Ft.log(Ft.typeStr(this), '_makeDormant');
    assert(_timerOrNull != null && _timerOrNull.isActive,
        "_makeDormant with no timer");
    _timerOrNull.cancel();
    _timerOrNull = null;
  }

  void _enableAutoBreak()
  {
    Ft.log(Ft.typeStr(this), '_enableAutoBreak');
    assert(this.abMode != AutoBreakExternalMode.None, "_enableAutoBreak");
    _autoBreakIn = _autoBreakClocks[this.abMode];
    _autoBreak = true;
  }

  void _disableAutoBreak()
  {
    Ft.log(Ft.typeStr(this), '_disableAutoBreak');
    _autoBreak = false;
  }

  // CONSTRUCTION *********************************************************** **

  void init_emulation()
  {
    Ft.log(Ft.typeStr(this), 'init_emulation');
    this.sc.setState(GameBoyExternalMode.Absent);
    this.sc.setState(PauseExternalMode.Ineffective);
    this.sc.setState(AutoBreakExternalMode.Instruction);
    this.sc.addSideEffect(_makeLooping, _makeDormant, _loopingGBCombos);
    this.sc.addSideEffect(
        _enableAutoBreak, _disableAutoBreak, _activeAutoBreakCombos);
    this.ports.listener('EmulationStart')
      .forEach(_onEmulationStartReq);
    this.ports.listener('Debug')
      .forEach((Map map){
        if (map['action'] == 'crash') {
          _simulateCrash = true;
          Ft.log(Ft.typeStr(this), 'listener#debug#crash');
        }
      });
    this.ports.listener('Debug')
      .where((map) => map['action'] == 'eject')
      .forEach(_onEjectReq);
    this.ports.listener('EmulationSpeed')
      .listen(_onEmulationSpeedChangeReq);
    this.ports.listener('EmulationAutoBreak')
      .listen(_onAutoBreakReq);
    this.ports.listener('EmulationPause')
      .listen(_onPauseReq);
    this.ports.listener('EmulationResume')
      .listen(_onResumeReq);
  }

}
