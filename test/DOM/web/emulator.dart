// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/10 17:57:18 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:isolate' as Isolate;

class Emulator {

  Emulator(
      Isolate.Isolate w
      , Isolate.ReceivePort cpuPort
      , Isolate.SendPort startEmulationPort)
    : _worker = w
    , _cpuPort = cpuPort
    , onCpuUpdate = cpuPort.asBroadcastStream()
    , _startEmulationPort = startEmulationPort
  {
  }

  final Isolate.Isolate					_worker;

  final Isolate.ReceivePort				_cpuPort;
  final Async.Stream<Map<String, int>>	onCpuUpdate;

  final Isolate.SendPort				_startEmulationPort;

  void							startEmulation(lolparam){
    _startEmulationPort.send(lolparam);
  }
}

Async.Future<Emulator> create() async {

  final uri = new Uri.file('worker.dart');
  final workerInitPort = new Isolate.ReceivePort();
  final cpuPort = new Isolate.ReceivePort();
  final worker = await Isolate.Isolate.spawnUri(uri, [], {
    'workerinitport': workerInitPort.sendPort,
    'cpuport': cpuPort.sendPort,
  });
  final Map<String, Isolate.SendPort> map = await workerInitPort.first;
  final Isolate.SendPort startEmulationPort = map['startemulationport'];
  assert(startEmulationPort != null);

  return new Emulator(worker, cpuPort, startEmulationPort);
}