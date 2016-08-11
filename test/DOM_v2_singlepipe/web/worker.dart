// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/10 17:52:15 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:isolate' as Isolate;
import 'dart:async' as Async;

class Worker {
  Worker(
    Isolate.SendPort mSendPort,
    Async.Stream mReceiveStream)
    : _mSendPort = mSendPort
    , _mReceiveStream = mReceiveStream
    , isInt21 = mReceiveStream.where((msg) => (msg == 21) && (msg is int))
  {
    // BEHAVIOUR HERE ?
    mReceiveStream.listen((msg) => print('Worker: mReceiveStream.listen $msg'));
    isInt21.listen((msg) => print('Worker: Lulz, you received 21'));
  }

  final Isolate.SendPort		  _mSendPort;
  final Isolate.ReceivePort		_mReceivePort;
  final Async.Stream          _mReceiveStream;

  final Async.Stream          isInt21;

  void        sendMessage(msg) {_mSendPort.send(msg);}

  void   loop(){
    int i = 0;
    while (true){
      i++;
      if (i < 10000000000)
        continue;
      sendMessage(42);
      i = 0;
    }
  }

}

Worker worker = null;

main(_, Isolate.SendPort mainSendPort)
{
  final Isolate.SendPort mSendPort = mainSendPort;
  assert(mSendPort != null);
  final Isolate.ReceivePort mReceivePort = new Isolate.ReceivePort();
  final Async.Stream mReceiveStream = mReceivePort.asBroadcastStream();
  worker = new Worker(mSendPort, mReceiveStream);
  worker.sendMessage(mReceivePort.sendPort);
  // worker.loop();
  return ;
}
