// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_emulation.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/09 14:11:18 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/src/worker.dart' as Worker;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;


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

  Async.Stream _fut;
  Async.StreamSubscription _sub;
  // Async.Timer _timerOrNull = null;

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

    Ft.log("WorkerEmu", '_onAutoBreakReq', [ab]);
    assert(this.abMode != ab, '_onAutoBreakReq($ab) twice');
    this.sc.setState(ab);
  }

  void _onPauseReq(_)
  {
    Ft.log("WorkerEmu", '_onPauseReq');
    if (this.pauseMode != PauseExternalMode.Effective)
      _updatePauseMode(PauseExternalMode.Effective);
  }

  void _onResumeReq(_)
  {
    Ft.log("WorkerEmu", '_onResumeReq');
    if (this.pauseMode != PauseExternalMode.Ineffective)
      _updatePauseMode(PauseExternalMode.Ineffective);
  }

  void _onEmulationSpeedChangeReq(map)
  {
    Ft.log("WorkerEmu", '_onEmulationSpeedChangeReq', [map]);
    assert(map['speed'] != null && map['speed'] is double,
        "_onEmulationSpeedChangeReq($map)");
    _updateEmulationSpeed(map['speed']);
  }

  void _onEmulationStartReq(Uint8List l) //TODO: Retrieve string from indexDB
  {
    var gb;

    Ft.log("WorkerEmu", '_onEmulationStartReq');
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
    if (this.debMode == DebuggerExternalMode.Operating
        && this.pauseMode != PauseExternalMode.Effective)
      _updatePauseMode(PauseExternalMode.Effective);
    _updateGBMode(GameBoyExternalMode.Emulating);
    this.ports.send('Events', <String, dynamic>{
      'type': EmulatorEvent.GameBoyStart,
      'msg': "Plokemon violet.rom",
    });
    return ;
  }

  void _onEjectReq(_)
  {
    Ft.log("WorkerEmu", '_onEjectReq');
    assert(this.gbMode != GameBoyExternalMode.Absent,
        "_onEjectReq with no gameboy");
    this.gbOpt = null;
    _updateGBMode(GameBoyExternalMode.Absent);
    this.ports.send('Events', <String, dynamic>{
      'type': EmulatorEvent.GameBoyEject,
      'msg': "bye bye Plokemon violet.rom",
    });
  }

  void _onKeyDown(JoypadKey kc){
    kc = JoypadKey.values[kc.index];
    if (this.gbOpt == null)
      return ;
    else
      gbOpt.keyPress(kc);
    return ;
  }

  void _onKeyUp(JoypadKey kc){
    kc = JoypadKey.values[kc.index];
    if (this.gbOpt == null)
      return ;
    else
      gbOpt.keyRelease(kc);
    return ;
  }

  // SECONDARY ROUTINES ***************************************************** **

  void _updateEmulationSpeed(double speed)
  {
    Ft.log("WorkerEmu", '_updateEmulationSpeed', [speed]);
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
    Ft.log("WorkerEmu", '_updateGBMode', [m]);
    this.sc.setState(m);
    this.ports.send('EmulationStatus', m);
  }

  void _updatePauseMode(PauseExternalMode m)
  {
    Ft.log("WorkerEmu", '_updatePauseMode', [m]);
    this.sc.setState(m);
    if (m == PauseExternalMode.Effective)
      this.ports.send('EmulationPause', 42);
    else
      this.ports.send('EmulationResume', 42);
  }

  Gameboy.GameBoy _assembleGameBoy(Uint8List l)
  {
    final drom = l; //TODO: Retrieve from indexedDB
    final Data.Rom irom = new Data.Rom.unserialize(
        <String, dynamic>{
          'data': drom,
          'fileName': 'no-name-yet' + ROM_EXTENSION
        });
    // final Data.Ram iram = new Data.Ram.unserialize();
    final c = new Cartridge.ACartridge(irom); //TODO: Take iram as parameter, if present
    return new Gameboy.GameBoy(c);
  }

  // LOOPING ROUTINE ******************************************************** **

  void _onEmulation(_)
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
      Ft.logwarn(Ft.typeStr(this), '_onEmulation#try', [e, st]);
      clockSum = 0;
      error = e;
      stacktrace = st;
    }
    _clockDeficit = clockDebt - clockSum.toDouble();
    _emulationCount++;
    _rescheduleTime = _emulationStartTime.add(
        EMULATION_PERIOD_DURATION * _emulationCount);
    _fut = new Async.Future.delayed(_makeRescheduleDelay())
      .asStream();
    _sub = _fut.listen(_onEmulation);
    if (error != null) {
      _updateGBMode(GameBoyExternalMode.Crashed);
      this.ports.send('Events', <String, dynamic>{
        'type': EmulatorEvent.GameBoyCrash,
        'msg': error.toString(),
        'st': stacktrace.toString(),
      });
    }
    else if (this.gbOpt.hardbreak) {
      _updatePauseMode(PauseExternalMode.Effective);
      this.gbOpt.clearHB();
    }
    else if (_autoBreak) {
      _autoBreakIn -= clockSum;
      if (_autoBreakIn <= 0)
        _updatePauseMode(PauseExternalMode.Effective);
    }
    return ;
  }

  Duration _makeRescheduleDelay() {
    final DateTime now = Ft.now();
    final Duration delta = _rescheduleTime.difference(now);

    if (delta < EMULATION_RESCHEDULE_MIN_DELAY)
      return EMULATION_RESCHEDULE_MIN_DELAY;
    else
      return delta;
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
      Ft.log("WorkerEmu", '_emulate#simulateCrash');
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
      if (this.gbOpt.hardbreak)
        break ;
    }
    return clockSum;
  }

  // SIDE EFFECTS CONTROLS ************************************************** **

  void _makeLooping()
  {
    Ft.log("WorkerEmu", '_makeLooping');
    assert(_sub == null, "_makeLooping() with some timer");
    _clockDeficit = 0.0;
    _emulationStartTime = Ft.now().add(EMULATION_START_DELAY);
    _rescheduleTime = _emulationStartTime;
    _emulationCount = 0;
    _fut = new Async.Future.delayed(EMULATION_START_DELAY).asStream();
    _sub = _fut.listen(_onEmulation);
  }

  void _makeDormant()
  {
    Ft.log("WorkerEmu", '_makeDormant');
    assert(_sub != null, "_makeDormant with no timer");
    _sub.pause();
    _fut = null;
    _sub = null;
  }

  void _enableAutoBreak()
  {
    Ft.log("WorkerEmu", '_enableAutoBreak');
    assert(this.abMode != AutoBreakExternalMode.None, "_enableAutoBreak");
    _autoBreakIn = _autoBreakClocks[this.abMode];
    _autoBreak = true;
  }

  void _disableAutoBreak()
  {
    Ft.log("WorkerEmu", '_disableAutoBreak');
    _autoBreak = false;
  }

  // CONSTRUCTION *********************************************************** **

  void init_emulation()
  {
    Ft.log("WorkerEmu", 'init_emulation');
    this.sc
      ..setState(GameBoyExternalMode.Absent)
      ..setState(PauseExternalMode.Ineffective)
      ..setState(AutoBreakExternalMode.Instruction);
    this.sc
      ..addSideEffect(_makeLooping, _makeDormant, _loopingGBCombos)
      ..addSideEffect(_enableAutoBreak, _disableAutoBreak, _activeAutoBreakCombos);
    this.ports
      ..listener('EmulationStart').forEach(_onEmulationStartReq)
      ..listener('EmulationSpeed').forEach(_onEmulationSpeedChangeReq)
      ..listener('EmulationAutoBreak').forEach(_onAutoBreakReq)
      ..listener('EmulationPause').forEach(_onPauseReq)
      ..listener('EmulationResume').forEach(_onResumeReq)
      ..listener('KeyDownEvent').forEach(_onKeyDown)
      ..listener('KeyUpEvent').forEach(_onKeyUp)
      ..listener('Debug')
        .where((map) => map['action'] == 'eject').forEach(_onEjectReq)
      ..listener('Debug').forEach(
        (Map map) {
          if (map['action'] == 'crash') {
            _simulateCrash = true;
            Ft.log("WorkerEmu", 'listener#debug#crash');
        }});
  }

}
