// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/04 12:36:00 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/src/mixins/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker/emulation.dart' as WEmu;
import 'package:emulator/src/worker/emulation_state.dart' as WEmuState;
import 'package:emulator/src/worker/emulation_iddb.dart' as WEmuIddb;
import 'package:emulator/src/worker/emulation_pause.dart' as WEmuPause;
import 'package:emulator/src/worker/emulation_timings.dart' as WEmuTimings;
import 'package:emulator/src/worker/emulation_timings_cpu.dart' as WEmuTimingsCpu;
import 'package:emulator/src/worker/emulation_joypad.dart' as WEmuJoypad;
import 'package:emulator/src/worker/debug.dart' as WDeb;
import 'package:emulator/src/worker/observer.dart' as WObs;
import 'package:emulator/variants.dart' as V;

/** ************************************************************************* **
 ** Worker statuses/events ************************************************** **
 ** ************************************************************************* */
enum DebuggerExternalMode {
  Operating, Dismissed
}

enum PauseExternalMode {
  Effective, Ineffective
}

/** ************************************************************************* **
 ** Abstract Worker ********************************************************* **
 ** ************************************************************************* **
 ** Some variables should not be `private`, no `protected` keyword in dart
 */
abstract class AWorker {

  // CONSTRUCTION *********************************************************** **
  AWorker(this.ports);

  // DOM EVENTS ************************************************************* **
  final Wiso.Ports ports;

  // WORKERS EVENTS/STATES ************************************************** **
  final Ft.StatesController sc = new Ft.StatesController();

  V.GameBoyState get gbMode => this.sc.getState(V.GameBoyState);
  DebuggerExternalMode get debMode => this.sc.getState(DebuggerExternalMode);
  PauseExternalMode get pauseMode => this.sc.getState(PauseExternalMode);

  // EMULATION EVENTS/STATES ************************************************ **
  Gameboy.GameBoy gbOpt = null;
  Async.Stream<V.EmulatorEvent> emulatorEvents; // ABSTRACT ***************** **
  Async.Stream saveStateInstallEvents; // ABSTRACT ************************** **

  // EMULATION TIMINGS ****************************************************** **
  double get et_cyclesPerSec_double;
  bool get ep_limitedEmulation;
  int get ep_autoBreakIn;

}

/** ************************************************************************* **
 ** Concrete Worker ********************************************************* **
 ** ************************************************************************* **
 ** One constructor call to supertype.
 ** No constructors in mixins (impossible). Init mixins with `.init_*()`.
 */
class Worker extends AWorker
  with WEmuState.EmulationState
  , WEmuIddb.EmulationIddb
  , WEmuPause.EmulationPause
  , WEmuJoypad.EmulationJoypad
  , WEmuTimings.EmulationTimings
  , WEmuTimingsCpu.EmulationTimingsCpu
  , WEmu.Emulation
  , WObs.Observer
  , WDeb.Debug
{

  Worker(ports)
  : super(ports)
  {
    this.init_emulation();
    this.init_observer();
    this.init_debug();
    this.sc.fire();
  }

}

Worker _globalWorker;

void entryPoint(Wiso.Ports p)
{
  Ft.log('worker.dart', 'entryPoint', [p]);
  assert(_globalWorker == null, "Worker already instanciated");
  _globalWorker = new Worker(p);
  return ;
}
