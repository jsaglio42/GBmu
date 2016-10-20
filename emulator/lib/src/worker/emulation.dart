// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 11:09:50 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:js' as Js;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/events.dart';

import 'package:emulator/src/worker/worker.dart' as Worker;
import 'package:emulator/src/worker/emulation_state.dart' as WEmuState;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/src/emulator.dart' show RequestEmuStart;
import 'package:emulator/variants.dart' as V;

final List<List> _loopingGBCombos = [
  [V.Emulating.v, DebuggerExternalMode.Dismissed],
  [V.Emulating.v, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective]
];

final List<List> _activeAutoBreakCombos = [
  [V.Emulating.v, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective, AutoBreakExternalMode.Instruction],
  [V.Emulating.v, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective, AutoBreakExternalMode.Frame],
  [V.Emulating.v, DebuggerExternalMode.Operating,
    PauseExternalMode.Ineffective, AutoBreakExternalMode.Second],
];

final Map<AutoBreakExternalMode, int> _autoBreakClocks = {
  AutoBreakExternalMode.Instruction: 4,
  AutoBreakExternalMode.Frame: GB_FRAME_PER_CLOCK_INT,
  AutoBreakExternalMode.Second: GB_CPU_FREQ_INT,
};

abstract class Emulation implements Worker.AWorker, WEmuState.EmulationState {

  Async.Stream _fut;
  Async.StreamSubscription _sub;

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

  Async.Future _onEmulationStartReq(RequestEmuStart req) async
  {
    Gameboy.GameBoy gb;

    Ft.log("WorkerEmu", '_onEmulationStartReq');
    try {
      gb = await _assembleGameBoy(req);
    }
    catch (e, st) {
      this.es_startFailure(e.toString(), st.toString());
      return ;
    }
    _updateEmulationSpeed(_emulationSpeed);
    if (this.debMode == DebuggerExternalMode.Operating
        && this.pauseMode != PauseExternalMode.Effective)
      _updatePauseMode(PauseExternalMode.Effective);
    this.es_startSuccess(gb);
    return ;
  }

  void _onEjectReq(_)
  {
    Ft.log("WorkerEmu", '_onEjectReq');
    assert(this.gbMode != V.Absent, "_onEjectReq with no gameboy");
    this.es_eject(this.gbOpt.c.rom.fileName);
  }

  void _onExtractRamReq(EventExtractRam ev) async {
    Ft.log("WorkerEmu", '_onExtractRamReq', [ev.ramKey]);
    assert(this.gbMode != V.Absent, "_onExtractRamReq with no gameboy");

    final c = this.gbOpt.c.ram.rawData;
    final Idb.Database idb = await _futureDatabaseOfName(ev.idb);
    Ft.log('WorkerEmu', '_onExtractRamReq#got-idb', [idb]);

    await _setDataOfField(idb, ev.ramStore, ev.ramKey, c);
    Ft.log("WorkerEmu", '_onExtractRamReq#done');
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

  void _updatePauseMode(PauseExternalMode m)
  {
    Ft.log("WorkerEmu", '_updatePauseMode', [m]);
    this.sc.setState(m);
    if (m == PauseExternalMode.Effective)
      this.ports.send('EmulationPause', 42);
    else
      this.ports.send('EmulationResume', 42);
  }

  Async.Future<Gameboy.GameBoy> _assembleGameBoy(RequestEmuStart req) async
  {
    Cartridge.ACartridge c;


    Ft.log('WorkerEmu', '_assembleGameBoy', [req]);

    final Idb.Database idb = await _futureDatabaseOfName(req.idb);
    Ft.log('WorkerEmu', '_assembleGameBoy#got-idb', [idb]);

    final Data.Rom rom = new Data.Rom.unserialize(
        await _fieldOfKeys(idb, req.romStore, req.romKey));
    Ft.log('WorkerEmu', '_assembleGameBoy#got-rom', [rom]);

    if (req.ramKeyOpt != null) {
      Data.Ram ram = new Data.Ram.unserialize(
          await _fieldOfKeys(idb, req.ramStore, req.ramKeyOpt));
      Ft.log('WorkerEmu', '_assembleGameBoy#got-ram', [ram]);
      c = new Cartridge.ACartridge(rom, optionalRam: ram);
    }
    else
      c = new Cartridge.ACartridge(rom);
    Ft.log('WorkerEmu', '_assembleGameBoy#got-cartridge', [c]);

    final Gameboy.GameBoy gb = new Gameboy.GameBoy(c);
    Ft.log('WorkerEmu', '_assembleGameBoy#got-gb', [gb]);

    return gb;
  }

  // DATABASE INTERACTIONS ******************** **
  Async.Future<Idb.Database> _futureDatabaseOfName(String name) {
    final idbf = Js.context['indexedDB'];
    final Async.Completer compl = new Async.Completer.sync();
    final req = idbf.callMethod('open', [name]);

    // Ft.log('WorkerEmu', '_futureDatabaseOfName', [name]);
    req['onsuccess'] = (ev){
      // Ft.log('WorkerEmu', '_onSuccess', [ev]);
      compl.complete(ev.target.result);
      new Async.Future.delayed(new Duration(milliseconds: 5), (){});
    };
    req['onerror'] = (ev){
      compl.completeError('Database error: ${ev.target.errorCode}');
      new Async.Future.delayed(new Duration(milliseconds: 5), (){});
    };
    return compl.future;
  }

  Async.Future<dynamic> _fieldOfKeys(
      Idb.Database idb, String storeName, int fieldKey) async {
    Idb.Transaction tra;
    dynamic serialized;

    tra = idb.transaction(storeName, 'readonly');

    await tra.objectStore(storeName)
    .openCursor(key: fieldKey)
    .take(1)
    .forEach((Idb.CursorWithValue cur) {
      serialized = cur.value;
    });
    return tra.completed.then((_) {
        if (serialized == null)
          throw new Exception('Missing $storeName#$fieldKey');
        else
          return serialized;
        });
  }

  Async.Future _setDataOfField(
      Idb.Database idb, String storeName, int fieldKey, Uint8List data) async {
    Idb.Transaction tra;

    tra = idb.transaction(storeName, 'readwrite');
    await tra.objectStore(storeName)
    .openCursor(key: fieldKey)
    .take(1)
    .forEach((Idb.CursorWithValue cur) {
      final m = new Map.from(cur.value);

      m['data'] = data;
      cur.update(m);
    });
    return tra.completed;
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
    if (error != null)
      this.es_gbCrash(error.toString(), stacktrace.toString());
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
      ..declareType(V.GameBoyState, V.GameBoyState.values,
          V.Absent.v)
      ..declareType(PauseExternalMode, PauseExternalMode.values,
          PauseExternalMode.Ineffective)
      ..declareType(AutoBreakExternalMode, AutoBreakExternalMode.values,
          AutoBreakExternalMode.None);
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
      ..listener('EmulationEject').forEach(_onEjectReq)
      ..listener('ExtractRam').forEach(_onExtractRamReq);
  }

}
