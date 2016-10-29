// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 13:54:46 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/src/GameBoyDMG/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker/emulation.dart' as WEmu;
import 'package:emulator/src/worker/emulation_state.dart' as WEmuState;
import 'package:emulator/src/worker/emulation_iddb.dart' as WEmuIddb;
import 'package:emulator/src/worker/emulation_pause.dart' as WEmuPause;
import 'package:emulator/src/worker/debug.dart' as WDeb;
import 'package:emulator/src/worker/observer.dart' as WObs;
import 'package:emulator/src/worker/framescheduler.dart' as WFramescheduler;
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

  final Wiso.Ports ports;
  final Ft.StatesController sc = new Ft.StatesController();
  Gameboy.GameBoy gbOpt = null;

  V.GameBoyState get gbMode => this.sc.getState(V.GameBoyState);
  DebuggerExternalMode get debMode => this.sc.getState(DebuggerExternalMode);
  PauseExternalMode get pauseMode => this.sc.getState(PauseExternalMode);

  AWorker(this.ports);

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
  , WEmu.Emulation
  , WObs.Observer
  , WDeb.Debug
  , WFramescheduler.FrameScheduler
{

  Worker(ports)
  : super(ports)
  {
    this.init_emulation();
    this.init_observer();
    this.init_debug();
    this.init_framescheduler();
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
