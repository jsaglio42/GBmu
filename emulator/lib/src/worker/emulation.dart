// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 18:14:37 by jsaglio          ###   ########.fr       //
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
import 'package:emulator/src/worker/emulation_timings_cpu.dart' as WEmuTimingsCpu;
import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/variants.dart' as V;

abstract class Emulation
  implements Worker.AWorker, WEmuState.EmulationState, WEmuIddb.EmulationIddb,
  WEmuPause.EmulationPause, WEmuTimings.EmulationTimings,
  WEmuTimingsCpu.EmulationTimingsCpu
{

  // ATTRIBUTES ************************************************************* **
  Async.Stream _fut;
  Async.StreamSubscription _sub;

  GameBoyType _gameboyType = GameBoyType.Auto;

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
      ..listener('FpsRequest').forEach(_onFpsChangeReq)
      ..listener('KeyDownEvent').forEach(_onKeyDown)
      ..listener('KeyUpEvent').forEach(_onKeyUp)
      ..listener('GameBoyTypeUpdate').forEach(_onGameBoyTypeUpdate)
      ..listener('EmulationEject').forEach(_onEjectReq)
      ..listener('ExtractRam').forEach(_onExtractRamReq)
      ..listener('ExtractSs').forEach(_onExtractSsReq)
      ..listener('InstallSs').forEach(_onInstallSsReq);
    ep_init();
    et_setCyclesPerSec(60.0);
    etc_setRate(1.0);
  }

  // PUBLIC **************************************************************** **
  GameBoyType get gameboyType => _gameboyType;

  // CALLBACKS (DOM) ******************************************************** **
  void _onEmulationSpeedChangeReq(map)
  {
    Ft.log("WorkerEmu", '_onEmulationSpeedChangeReq', [map]);
    assert(map['speed'] != null && map['speed'] is double,
        "_onEmulationSpeedChangeReq($map)");
    etc_setRate(map['speed']);
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
    etc_reset();
    es_startSuccess(gb);
    return ;
  }

  void _onFpsChangeReq(Map m) {
    Ft.log("WorkerEmu", '_onFpsChangeReq', [m]);
    assert(m['fps'] != null && m['fps'] is double);
    et_setCyclesPerSec(m['fps']);
    etc_resetRate();
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
    var error, stacktrace;
    int clockElapsed;

    et_advance();
    etc_advance();
    _fut = new Async.Future.delayed(et_rescheduleDeltaTime()).asStream();
    _sub = _fut.listen(_onEmulation);

    try {
      // Ft.log("WorkerEmu", '_emulate');
      clockElapsed = _emulate();
      // Ft.log("WorkerEmu", '_emulate#DONE');
    }
    catch (e, st) {
      clockElapsed = 0;
      error = e;
      stacktrace = st;
    }
    etc_postAdvance(clockElapsed);

    this.ports.send('FrameUpdate', this.gbOpt.lcd.screen);
    if (error != null) {
      this.es_gbCrash(error.toString(), stacktrace.toString());
      return ;
    }
    else if (this.gbOpt.hardbreak) {
      ep_breakPoint();
      this.gbOpt.clearHB();
    }
    else if (ep_limitedEmulation)
      ep_decreaseAutoBreakIn(clockElapsed);
    return ;
  }

  void _makeLooping()
  {
    Ft.log("WorkerEmu", '_makeLooping');
    assert(_sub == null, "_makeLooping() with some timer");
    et_reset();
    etc_reset();
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
  int _emulate()
  {
    int clockAcc = 0;
    int clockExec;

    this.gbOpt.incrementFrameRenderToken();
    while (true) {
      if (Ft.now().compareTo(et_cycleTimeLimit) >= 0)
        break ;
      if (clockAcc >= etc_cycleClockLimit)
        break ;
      clockExec = Math.min(
          MAXIMUM_CLOCK_PER_EXEC_INT, etc_cycleClockLimit - clockAcc);
      clockAcc += this.gbOpt.exec(clockExec);
      if (this.gbOpt.hardbreak)
        break ;
    }
    return clockAcc;
  }

  // OTHER SUBROUTINES ****************************************************** **

}
