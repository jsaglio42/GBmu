// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 18:16:45 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:async' as Async;

import 'package:emulator/enums.dart';
import 'package:emulator/src/events.dart';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;
import 'package:emulator/src/worker/worker.dart' as Worker;
import "package:emulator/src/hardware/cpu_registers.dart" as Cpuregs;
import "package:emulator/src/mixins/instructions.dart" as Instructions;
import 'package:emulator/variants.dart' as V;

/*
 * ************************************************************************** **
 * Ports configuration ****************************************************** **
 * ************************************************************************** **
 * Defines two Map<String, Type>.
 * `Type` must match EXACTLY the sent type.
 * Don't send any `double` here, a double rounded is always of type int.
 * Receiver may use `a subtype` or `dynamic` parameter in
 *   it's callback function.
 */

final Map<String, Type> _mainReceivers = <String, Type>{

  // DOM
  'EmulationSpeed' : <String, dynamic>{}.runtimeType,
  'Events': <String, dynamic>{}.runtimeType,
  'FrameUpdate': <int>[].runtimeType,

  // DOM Debugger
  'DebStatusUpdate' : bool,
  'EmulationPause' : int,
  'EmulationResume' : int,
  'MemInfo' : <String, dynamic>{}.runtimeType,
  'InstInfo' : <Instructions.Instruction>[].runtimeType,
  'RegInfo' : Cpuregs.CpuRegs,
  'MemRegInfo' : Uint8List,
  'ClockInfo' : int,

};

final Map<String, Type> _workerReceivers = <String, Type>{

  // Emulation
  'EmulationStart' : RequestEmuStart,
  'EmulationEject' : int,
  'EmulationSpeed' : <String, dynamic>{}.runtimeType,
  'ExtractRam' : EventIdb,
  'ExtractSs' : EventIdb,
  'InstallSs' : EventIdb,
  'FpsRequest': <String, double>{}.runtimeType,
  'GameBoyTypeUpdate' : GameBoyType,

  // GameBoy Joypad
  'KeyDownEvent' : JoypadKey,
  'KeyUpEvent' : JoypadKey,

  // Debugger
  'DebStatusRequest' : DebuggerModeRequest,
  'LimitedEmulation' : LimitedEmulation,
  'EmulationPause' : int,
  'EmulationResume' : int,
  'DebMemAddrChange' : int,

};

/*
 * ************************************************************************** **
 * Emulator class ...
 * ************************************************************************** **
 */
class Emulator {

  final Wiso.WiredIsolate _wiso;
  final Async.StreamController<Map<String, dynamic>> _eventsBroadcast =
    new Async.StreamController<Map<String, dynamic>>.broadcast();

  Emulator(wiso)
    : _wiso = wiso
  {
    wiso.p.listener('Events')
    .forEach((Map e){
          _eventsBroadcast.add(e);
        });
    _wiso.isoErrors
    .forEach((e) {
          _eventsBroadcast.add(<String, dynamic>{
            'type': V.EmulatorCrash.v,
            'msg': e,
          });
        });
  }

  void send(String msgType, var data) => _wiso.p.send(msgType, data);
  Async.Stream listener(String msgType)
  {
    if (msgType == 'Events')
      return _eventsBroadcast.stream;
    return _wiso.p.listener(msgType);
  }

}

Async.Future<Emulator> spawn()
async {
  Ft.log('emulator.dart', 'spawn');

  final wiso = await Wiso.spawn(
      Worker.entryPoint, _mainReceivers, _workerReceivers);

  wiso.i.resume(wiso.resumeCapability);
  return new Emulator(wiso);
}
