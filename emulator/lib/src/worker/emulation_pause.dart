// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation_pause.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/29 13:37:05 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 16:35:04 by ngoguey          ###   ########.fr       //
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

import 'package:emulator/src/worker/worker.dart' as Worker;

// import 'package:emulator/src/GameBoyDMG/gameboy.dart' as Gameboy;

// import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
// import 'package:emulator/src/hardware/data.dart' as Data;
// import 'package:emulator/src/emulator.dart' show RequestEmuStart;
import 'package:emulator/variants.dart' as V;

final Map<LimitedEmulation, int> _limitedEmulationClocks = {
  LimitedEmulation.Instruction: 4,
  LimitedEmulation.Line: GB_CLOCK_PER_LINE_INT,
  LimitedEmulation.Frame: GB_CLOCK_PER_FRAME_INT,
  LimitedEmulation.Second: GB_CPU_FREQ_INT,
};

abstract class EmulationPause implements Worker.AWorker
{

  // ATTRIBUTES ************************************************************* **

  bool _limitedEmulation = false;
  int _autoBreakIn;

  // CONSTRUCTION *********************************************************** **
  void ep_init() {
    this.sc.declareType(PauseExternalMode, PauseExternalMode.values,
        PauseExternalMode.Ineffective);
    this.sc.addSideEffect(_onDebOpen, _onDebClose, [
      [DebuggerExternalMode.Operating],
    ]);
    this.ports
      ..listener('EmulationPause').forEach(_onPauseReq)
      ..listener('LimitedEmulation').forEach(_onLimitedEmulationReq)
      ..listener('EmulationResume').forEach(_onResumeReq);
    this.emulatorEvents
      .forEach(_onEmulatorEvent);
  }

  // CALLBACKS (DOM) ******************************************************** **
  void _onPauseReq(_)
  {
    assert(this.debMode == DebuggerExternalMode.Operating);
    Ft.log("WorkerPause", '_onPauseReq');
    if (this.pauseMode != PauseExternalMode.Effective)
      _updateMode(PauseExternalMode.Effective);
  }

  void _onResumeReq(_)
  {
    Ft.log("WorkerPause", '_onResumeReq');
    if (this.pauseMode != PauseExternalMode.Ineffective) {
      _limitedEmulation = false;
      _updateMode(PauseExternalMode.Ineffective);
    }
  }

  void _onLimitedEmulationReq(LimitedEmulation leRaw)
  {
    final LimitedEmulation le = LimitedEmulation.values[leRaw.index];

    assert(this.debMode == DebuggerExternalMode.Operating);
    if (this.gbMode is V.Emulating) {
      Ft.log("WorkerPause", '_onLimitedEmulationReq', [le]);
      _autoBreakIn = _limitedEmulationClocks[le];
      _limitedEmulation = true;
      if (this.pauseMode == PauseExternalMode.Effective)
        _updateMode(PauseExternalMode.Ineffective);
    }
  }

  // CALLBACKS (WORKER) ***************************************************** **
  void _onDebOpen() {
    _updateMode(PauseExternalMode.Effective);
  }

  void _onDebClose() {
    _limitedEmulation = false;
   if (this.pauseMode == PauseExternalMode.Effective)
     _updateMode(PauseExternalMode.Ineffective);
  }

  void _onEmulatorEvent(V.EmulatorEvent ev) {
    if (_limitedEmulation)
      _limitedEmulation = false;
    if (this.debMode == DebuggerExternalMode.Operating
        && this.pauseMode != PauseExternalMode.Effective)
      _updateMode(PauseExternalMode.Effective);
  }

  // PUBLIC ***************************************************************** **
  bool get ep_limitedEmulation => _limitedEmulation;

  int get ep_autoBreakIn => _autoBreakIn;

  void ep_decreaseAutoBreakIn(int clockSum) {
    _autoBreakIn -= clockSum;
    if (_autoBreakIn <= 0) {
      _limitedEmulation = false;
      _updateMode(PauseExternalMode.Effective);
    }
  }

  void ep_breakPoint() {
    _updateMode(PauseExternalMode.Effective);
  }

  // SUBROUTINES ************************************************************ **
  void _updateMode(PauseExternalMode m)
  {
    // Ft.log("WorkerPause", '_updateMode', [m]);
    this.sc.setState(m);
    if (m == PauseExternalMode.Effective)
      this.ports.send('EmulationPause', 42);
    else
      this.ports.send('EmulationResume', 42);
  }


}
