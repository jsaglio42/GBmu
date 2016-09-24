// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 10:26:59 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// import 'dart:math' as Math;
import 'dart:async' as Async;
// import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

// import 'package:emulator/enums.dart';
// import 'package:emulator/constants.dart';
// import 'package:emulator/src/memory/rom.dart' as Rom;
// import 'package:emulator/src/memory/ram.dart' as Ram;
// import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
// import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker_emulation.dart' as Workeremulation;
import 'package:emulator/src/worker_debug.dart' as Workerdebug;
import 'package:emulator/src/worker_observer.dart' as Workerobserver;

/** ************************************************************************* **
 ** Worker statuses/events ************************************************** **
 ** ************************************************************************* */
enum DebuggerExternalMode {
  Operating, Dismissed
}

enum GameBoyExternalMode {
  Emulating, Crashed, Absent
}

enum PauseExternalMode {
  Effective, Ineffective
}

enum AutoBreakExternalMode {
  Instruction,
  Frame,
  Second,
  None
}

enum EmulatorEvent {
  EmulatorCrash,
  InitError,
  GameBoyStart,
  GameBoyCrash,
  GameBoyEject,
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

  GameBoyExternalMode get gbMode => this.sc.getState(GameBoyExternalMode);
  DebuggerExternalMode get debMode => this.sc.getState(DebuggerExternalMode);
  PauseExternalMode get pauseMode => this.sc.getState(PauseExternalMode);
  AutoBreakExternalMode get abMode => this.sc.getState(AutoBreakExternalMode);

  AWorker(this.ports);

}

/** ************************************************************************* **
 ** Concrete Worker ********************************************************* **
 ** ************************************************************************* **
 ** One constructor call to supertype.
 ** No constructors in mixins (impossible). Init mixins with `.init_*()`.
 */
class Worker extends AWorker
  with Workeremulation.Emulation
  , Workerobserver.Observer
  , Workerdebug.Debug
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
