// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulator.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/10 18:00:38 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:isolate' as Isolate;

class Emulator {

  Emulator(
    Isolate.Isolate w
    , Isolate.SendPort wSendPort
    , Async.Stream wReceiveStream)
      : _worker = w
      , _wSendPort = wSendPort
      , _wReceiveStream = wReceiveStream
      , isInt42 = wReceiveStream.where((msg) => (msg is int) && (msg == 42))
  {
    // BEHAVIOUR HERE ?
    wReceiveStream.listen((msg) => print('Emulator: wReceiveStream.listen $msg'));
    isInt42.listen((msg) => print('Emulator: Lulz, you received 42'));
  }

  final Isolate.Isolate					        _worker;
  final Isolate.SendPort                _wSendPort;
  final Async.Stream                    _wReceiveStream;

  final Async.Stream                  	isInt42;

  void				sendMessage(msg) {_wSendPort.send(msg);}

}

Async.Future<Emulator> create() async {
  final uri = new Uri.file('worker.dart');
  final workerReceivePort = new Isolate.ReceivePort();
  final workerReceiveStream = workerReceivePort.asBroadcastStream();
  final workerIsolate = await Isolate.Isolate.spawnUri(uri, [], workerReceivePort.sendPort);
  final Isolate.SendPort workerSendPort = await workerReceiveStream.first;
  assert(workerSendPort is Isolate.SendPort && workerSendPort != null);
  return new Emulator(workerIsolate, workerSendPort, workerReceiveStream);
}