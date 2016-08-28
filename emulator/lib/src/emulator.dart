// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 15:59:16 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/src/worker.dart' as Worker;
import "package:emulator/src/cpu_registers.dart" as Cpuregs;

/*
 * ************************************************************************** **
 * Ports configuration ****************************************************** **
 * ************************************************************************** **
 * Defines two Map<String, Type>.
 * `Type` must match EXACTLY the sent type.
 * Don't send any `double` here, a double rounded is always a type int.
 * Receiver may use `a subtype` or `dynamic` parameter in
 *   it's callback function.
 */

final _mainReceivers = <String, Type>{
  'RegInfo' : Cpuregs.CpuRegs,
  'MemRegInfo' : Uint8List,
  'ClockInfo' : int,
  'EmulationSpeed' : <String, dynamic>{}.runtimeType,
  'DebStatusUpdate' : bool,
  'MemInfo' : <String, dynamic>{}.runtimeType,
};

final _workerReceivers = <String, Type>{
  'DebStatusRequest' : DebuggerModeRequest,
  'EmulationStart' : Uint8List,
  'EmulationSpeed' : <String, dynamic>{}.runtimeType,
  'DebMemAddrChange' : int,
  'Debug' : <String, dynamic>{}.runtimeType,
};

/*
 * ************************************************************************** **
 * Emulator class ...
 * ************************************************************************** **
 */

class Emulator {

  final Wiso.WiredIsolate    _wiso;

  Emulator(this._wiso);

  void      send(String msgType, var data)  => _wiso.p.send(msgType, data);
  Async.Stream listener(String msgType)        => _wiso.p.listener(msgType);

}

Async.Future<Emulator> spawn()
async {
  Ft.log('emulator', 'spawn');

  //Todo: listen isolate errors
  final w = await Wiso.spawn(
      Worker.entryPoint, _mainReceivers, _workerReceivers);
  w.i.resume(w.resumeCapability);
  return new Emulator(w);
}
