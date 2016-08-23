// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 15:45:12 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;
import 'dart:isolate' as Is;
import 'package:ft/wired_isolate.dart' as WI;
import './worker.dart' as W;
import 'dart:typed_data';
import './public_classes.dart';

/*
 * ************************************************************************** **
 * Ports configuration ****************************************************** **
 * ************************************************************************** **
 * Defines two Map<String, Type>.
 * `Type` must match EXACTLY the sent type.
 * Receiver may use `a subtype` or `dynamic` parameter in
 *   it's callback function.
 */

// final Type VRegisterMap = <VRegister, int>{}.runtimeType;
// final Type ORegisterMap = <ORegister, int>{}.runtimeType;
// final Type TimingMap    = <String, double>{}.runtimeType;

final _mainReceivers = <String, Type>{
  'RegInfo': RegisterBank,
  'MemRegInfo': <int>[].runtimeType,
  'Timings': <String, double>{}.runtimeType,
  'DebStatusUpdate': DebStatus,
};

final _workerReceivers = <String, Type>{
  'DebStatusRequest'  : DebStatusRequest,
  'EmulationStart'    : Uint8List,    //debug
  'EmulationMode'     : String, //debug
};

/*
 * ************************************************************************** **
 * Emulator class ...
 * ************************************************************************** **
 */

class Emulator {

  final WI.WiredIsolate    _wi;

  Emulator(WI.WiredIsolate wi) : _wi = wi;

  void      send(String msgType, var data)  => _wi.p.send(msgType, data);
  As.Stream listener(String msgType)        => _wi.p.listener(msgType);

}

As.Future<Emulator> spawn()
async {
  print('emulator:\tspawn()');

  //Todo: listen isolate errors
  final wi = await WI.spawn(W.entryPoint, _mainReceivers, _workerReceivers);
  wi.i.resume(wi.resumeCapability);
  return new Emulator(wi);
}
