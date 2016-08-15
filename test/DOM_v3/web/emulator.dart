// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 16:20:08 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;
import 'dart:isolate' as Is;
import 'wired_isolate.dart' as WI;
import 'worker.dart' as W;

/*
 * ************************************************************************** **
 * Ports configuration ****************************************************** **
 * ************************************************************************** **
 */
final mainReceivers = <String, Type>{
  'RegInfo': <String, int>{}.runtimeType,
  'Timings': <String, double>{}.runtimeType,
};

final workerReceivers = <String, Type>{
  'EmulationStart': int,
  'EmulationMode': String,
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

  final fin = WI.spawn(W.entryPoint, mainReceivers, workerReceivers)
  ..catchError((e) {
        print('emulator:\tError while spawning wired_isolate:\n$e');
      });
  final data = await fin;

  return new Emulator(data.i, data.p);
}
