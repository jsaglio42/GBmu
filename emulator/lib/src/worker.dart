// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 15:00:36 by ngoguey          ###   ########.fr       //
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
 ** Worker statuses/error events ******************************************** **
 ** ************************************************************************* */
enum Status {
  Emulating, //_gb != null && _crashed == false
    // (after emulation start)
  Crashed, //  _gb != null && _crashed == true
    // (after emulation crash)
  Empty, //    _gb == null && _crashed == false
    // (after ejection, before 1st emulation)
}

// TODO: Should merge StartError and NonFatalError ?
enum Event {
  Start,
  Eject,
  StartError, //              errors with _gb == null
  NonFatalError, // Non-fatal errors with _gb != null
  FatalError, //        Fatal errors with _gb != null
}

/** ************************************************************************* **
 ** Abstract Worker ********************************************************* **
 ** ************************************************************************* **
 ** Some variables should not be `private`, no `protected` keyword in dart
 */
abstract class AWorker {

  /* PORTS ****************************************************************** */
  final Wiso.Ports ports;

  AWorker(this.ports);

  /* EMULATION STATUS/EVENTS - PUBLIC *************************************** */
  Async.Stream<Map<String, dynamic>> get events => _events.stream;

  Status get status
  {
    if (_gb_or_null != null) {
      if (_crashed)
        return Status.Crashed;
      else
        return Status.Emulating;
    }
    else {
      if (!_crashed)
        return Status.Empty;
      else
        assert(false, "Worker: Unsound worker status");
    }
  }
  Gameboy.GameBoy get gb
  {
    assert(_gb_or_null != null, "worker: Getter call for a null GameBoy");
    return _gb_or_null;
  }

  /** Source of Event.Start **/
  void registerGameBoy(gb) {
    assert(gb != null, "registerGameBoy(null)");
    switch (this.status) {
      case (Status.Emulating):
        assert(false,
            "worker: registerGameBoy(gb) "
            "can't register a new gameboy while another one is running");
        break;
      case (Status.Crashed):
        break;
      case (Status.Empty):
        break;
    }
    _gb_or_null = gb;
    _crashed = false;
    _events.add(<String, dynamic>{
      'type': Event.Start,
    });
    return ;
  }

  /** Source of Event.Eject **/
  void ejectGameBoy() {
    switch (this.status) {
      case (Status.Emulating):
        break;
      case (Status.Crashed):
        break;
      case (Status.Empty):
        assert(_gb_or_null != null,
            "worker: ejectGameBoy() "
            "can't unregister a gameboy if none previously registered");
        break;
    }
    _gb_or_null = null;
    _crashed = false;
    _events.add(<String, dynamic>{
      'type': Event.Eject,
    });
    return ;
  }

  /** Source of Event.*Error **/
  void notifyError(Event type, var msg) {
    switch (this.status) {
      case (Status.Emulating):
        assert(type != Event.StartError,
            "worker.notifyError($type, $msg) while emulating");
        break;
      case (Status.Crashed):
        assert(type == Event.StartError,
            "worker.notifyError($type, $msg) while crashed");
        break;
      case (Status.Empty):
        assert(type == Event.StartError,
            "worker.notifyError($type, $msg) while empty");
        break;
    }
    switch (type) {
      case (Event.StartError):
        break;
      case (Event.NonFatalError):
        break;
      case (Event.FatalError):
        _crashed = true;
        break;
      default:
        assert(false, "worker.notifyError($type, $msg)");
    }
    _events.add(<String, dynamic>{
      'type': type,
      'msg': msg,
    });
  }

  /* EMULATION STATUS/EVENTS - PRIVATE ************************************** */

  bool _crashed = false;
  Gameboy.GameBoy _gb_or_null = null;
  final Async.StreamController<Map<String, dynamic>> _events =
    new Async.StreamController<Map<String, dynamic>>.broadcast();

}

/** ************************************************************************* **
 ** Concrete Worker ********************************************************* **
 ** ************************************************************************* **
 ** One constructor call to supertype.
 ** No constructors in mixins (impossible). Init mixins with `.init_*()`.
 */
class Worker extends AWorker
  with Workeremulation.Emulation
  , Workerdebug.Debug
  , Workerobserver.Observer {

  Worker(ports)
  : super(ports)
  {
    this.init_debug();
    this.init_emulation();
    this.init_observer();

    ports.listener('Debug')
      ..where((Map map) => map['action'] == 'crash')
      .forEach((_){
            this.notifyError(Event.FatalError, 'Simulated fatal error');
          })
      ..where((Map map) => map['action'] == 'eject')
      .forEach((_){
            this.ejectGameBoy();
          })
      ;
  }
}

Worker _globalWorker;

void entryPoint(Wiso.Ports p)
{
  Ft.log('worker', 'entryPoint', p);
  assert(_globalWorker == null, "Worker already instanciated");
  _globalWorker = new Worker(p);
  return ;
}
