// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:46:41 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:typed_data';
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
 * Receiver may use `a subtype` or `dynamic` parameter in
 *   it's callback function.
 */

final _mainReceivers = <String, Type>{
  'RegInfo': Cpuregs.CpuRegs,
  'MemRegInfo': <int>[].runtimeType,
  'Timings': <String, double>{}.runtimeType,
  'DebStatusUpdate': DebStatus,
};

final _workerReceivers = <String, Type>{
  'DebStatusRequest'  : DebStatusRequest,
  'EmulationStart'    : Uint8List,
  'EmulationMode'     : String,
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
  print('emulator:\tspawn()');

  //Todo: listen isolate errors
  final w = await Wiso.spawn(
      Worker.entryPoint, _mainReceivers, _workerReceivers);
  w.i.resume(w.resumeCapability);
  return new Emulator(w);
}
