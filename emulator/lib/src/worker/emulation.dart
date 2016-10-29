// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 18:03:00 by jsaglio          ###   ########.fr       //
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
import 'package:emulator/src/worker/emulation_pause.dart' as WEmuPause;
import 'package:emulator/src/worker/emulation_iddb.dart' as WEmuIddb;
import 'package:emulator/src/mixins/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker/emulation_timings.dart' as WEmuTimings;
import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/src/emulator.dart' show RequestEmuStart;
import 'package:emulator/variants.dart' as V;

abstract class Emulation
  implements Worker.AWorker, WEmuState.EmulationState, WEmuIddb.EmulationIddb,
  WEmuPause.EmulationPause, WEmuTimings.EmulationTimings
{

  // ATTRIBUTES ************************************************************* **
  Async.Stream _fut;
  Async.StreamSubscription _sub;

  GameBoyType _gameboyType = GameBoyType.Auto;
  double _emulationSpeed = 1.0;
  double _clockDeficit;
  double _clockPerRoutineGoal;

  // CONSTRUCTION *********************************************************** **
  void init_emulation()
  {
    Ft.log("WorkerEmu", 'init_emulation');
    this.sc.declareType(V.GameBoyState, V.GameBoyState.values,
        V.Absent.v);
    this.sc.addSideEffect(_makeLooping, _makeDormant,
        [[V.Emulating.v, PauseExternalMode.Ineffective]]);
    this.ports
      ..listener('EmulationStart').forEach(_onEmulationStartReq)
      ..listener('EmulationSpeed').forEach(_onEmulationSpeedChangeReq)
      ..listener('KeyDownEvent').forEach(_onKeyDown)
      ..listener('KeyUpEvent').forEach(_onKeyUp)
      ..listener('GameBoyTypeUpdate').forEach(_onGameBoyTypeUpdate)
      ..listener('EmulationEject').forEach(_onEjectReq)
      ..listener('ExtractRam').forEach(_onExtractRamReq)
      ..listener('ExtractSs').forEach(_onExtractSsReq)
      ..listener('InstallSs').forEach(_onInstallSsReq);
    ep_init();
    et_setCyclesPerSec(30.0);
  }

  // PUBLIC **************************************************************** **
  GameBoyType get gameboyType => _gameboyType;

  // CALLBACKS (DOM) ******************************************************** **
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

    Ft.log("WorkerEmu", '_onEmulationStartReq', [req]);
    try {
      gb = await this.ei_assembleGameBoy(req);
    }
    catch (e, st) {
      this.es_startFailure(e.toString(), st.toString());
      return ;
    }
    _updateEmulationSpeed(_emulationSpeed);
    this.es_startSuccess(gb);
    return ;
  }

  void _onEjectReq(_)
  {
    Ft.log("WorkerEmu", '_onEjectReq');
    assert(this.gbMode is! V.Absent, "_onEjectReq with no gameboy");
    this.es_eject(this.gbOpt.c.rom.fileName);
  }

  void _onExtractRamReq(EventIdb ev) {
    Ft.log("WorkerEmu", '_onExtractRamReq', [ev.key]);
    this.ei_extractRam(ev);
  }

  void _onExtractSsReq(EventIdb ev) {
    Ft.log("WorkerEmu", '_onExtractSsReq', [ev.key]);
    this.ei_extractSs(ev);
  }

  void _onInstallSsReq(EventIdb ev) {
    Ft.log("WorkerEmu", '_onInstallSsReq', [ev.key]);
    this.ei_installSs(ev);
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

  void _onGameBoyTypeUpdate(GameBoyType gbt)
  {
    // Ft.log('WorkerEmu', '_onGameBoyTypeUpdate', gbt.toString());
    _gameboyType = GameBoyType.values[gbt.index];
  }

  // CALLBACKS (WORKER) ***************************************************** **
  void _onEmulation(_)
  {
    int clockSum;
    var error, stacktrace;
    final double clockDebt = _clockPerRoutineGoal + _clockDeficit;
    final int clockLimit = _clockLimitOfClockDebt(clockDebt);

    et_advance();

    try {
      // Ft.log("WorkerEmu", '_emulate');
      clockSum = _emulate(clockLimit);
      // Ft.log("WorkerEmu", '_emulate#DONE');
    }
    catch (e, st) {
      clockSum = 0;
      error = e;
      stacktrace = st;
    }
    _clockDeficit = clockDebt - clockSum.toDouble();
    _fut = new Async.Future.delayed(et_rescheduleDeltaTime()).asStream();
    _sub = _fut.listen(_onEmulation);
    if (error != null)
      this.es_gbCrash(error.toString(), stacktrace.toString());
    else if (this.gbOpt.hardbreak) {
      ep_breakPoint();
      this.gbOpt.clearHB();
    }
    else if (ep_limitedEmulation)
      ep_decreaseAutoBreakIn(clockSum);
    return ;
  }

  void _makeLooping()
  {
    Ft.log("WorkerEmu", '_makeLooping');
    assert(_sub == null, "_makeLooping() with some timer");
    _clockDeficit = 0.0;
    et_reset();
    _fut = new Async.Future.delayed(et_rescheduleDeltaTime()).asStream();
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

  // ONEMULATION SUBROUTINES ************************************************ **
  int _clockLimitOfClockDebt(double clockDebt)
  {
    if (ep_limitedEmulation)
      return ep_autoBreakIn;
    else if (clockDebt.isInfinite)
      return MAX_INT_LOLDART;
    else
      return clockDebt.floor();
  }

  int _emulate(final int clockLimit)
  {
    int clockSum = 0;
    int clockExec;

    while (true) {
      if (Ft.now().compareTo(et_cycleTimeLimit) >= 0)
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

  // OTHER SUBROUTINES ****************************************************** **
  void _updateEmulationSpeed(double speed)
  {
    // Ft.log("WorkerEmu", '_updateEmulationSpeed', [speed]);
    assert(!(speed < 0.0), "_updateEmulationSpeed($speed)");
    if (speed.isFinite) {
      _emulationSpeed = speed;
      _clockPerRoutineGoal =
        GB_CPU_FREQ_DOUBLE / et_cyclesPerSec_double * _emulationSpeed;
    }
    else {
      _emulationSpeed = double.INFINITY;
      _clockPerRoutineGoal = double.INFINITY;
    }
    _clockDeficit = 0.0;
  }

}
