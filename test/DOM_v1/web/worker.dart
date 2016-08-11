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

class Worker {
  Worker(Isolate.SendPort cpuPort, Isolate.ReceivePort startEmulationPort)
    : cpuPort = cpuPort
    , startEmulationPort = startEmulationPort
  {}

  final Isolate.SendPort		cpuPort;
  final Isolate.ReceivePort		startEmulationPort;
}

Worker worker = null;

main(_, Map<String, Isolate.SendPort> initMap)
{
  final Isolate.ReceivePort startEmulationPort = new Isolate.ReceivePort();

  final Isolate.SendPort workerinitport = initMap['workerinitport'];
  assert(workerinitport != null);
  workerinitport.send({
    'startemulationport': startEmulationPort.sendPort
  });

  final Isolate.SendPort cpuPort = initMap['cpuport'];
  assert(cpuPort != null);

  startEmulationPort.listen((msg){
        print('Worker: startEmulationPort.listen $msg');
        cpuPort.send({
          'eax': 42,
          'rdx': 43
        });
      });

  worker = new Worker(cpuPort, startEmulationPort);
  return ;
}
