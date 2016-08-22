// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 11:38:23 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;
import 'dart:isolate' as Is;
import 'package:ft/wired_isolate.dart' as WI;
import './worker.dart' as W;
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
final _mainReceivers = <String, Type>{
  // 'RegInfo': (new RegisterBank()).runtimeType,
    'RegInfo': RegisterBank,
  'VRegInfo': <VRegister, int>{}.runtimeType,
  'ORegInfo': <ORegister, int>{}.runtimeType,
  'Timings': <String, double>{}.runtimeType,
  'DebStatusUpdate': DebStatus,
};

final _workerReceivers = <String, Type>{
  'DebStatusRequest': DebStatusRequest,
  'EmulationStart': int, //debug
  'EmulationMode': String, //debug
};

/*
 * ************************************************************************** **
 * Emulator class ...
 * ************************************************************************** **
 */
class Emulator {

  Emulator(Is.Isolate iso, WI.Ports p)
    : _iso = iso
    , _ports = p
  {
  }

  final Is.Isolate _iso;
  final WI.Ports _ports;

  void send(String n, var p) => _ports.send(n, p);
  As.Stream listener(String n) => _ports.listener(n);
}

As.Future<Emulator> create() async {
  print('emulator:\tcreate()');

  //Todo: listen isolate errors
  final fin = WI.spawn(W.entryPoint, _mainReceivers, _workerReceivers)
  ..catchError((e) {
        print('emulator:\tError while spawning wired_isolate:\n$e');
      });
  final data = await fin;
  data.i.resume(data.resumeCapability);

  return new Emulator(data.i, data.p);
}
