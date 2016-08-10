// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/09 14:20:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/09 20:18:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:isolate' as Isolate;

class Worker {

	Worker(Map<String, Isolate.SendPort>  initMap)
		: CPUPort = initMap['cpuport']
	{
		this.startEmulationPort = new Isolate.ReceivePort();
		print('tro $initMap');
		initMap['workerinitport'].send({
			'startemulationport': startEmulationPort.sendPort
		});
		print('lolo');
	}

	Isolate.SendPort		CPUPort;

	Isolate.ReceivePort		startEmulationPort;
}

main(_, Map<String, Isolate.SendPort> initMap)
{
	var worker = new Worker(initMap);

	print('waka');
	worker.startEmulationPort.listen((msg){
		print('Worker: startEmulationPort.listen $msg');
		worker.CPUPort.send({
			'eax': 42,
			'rdx': 43
		});
	});
	print('hehe');
	return ;	
}


// mainIsolateReceive.asBroadcastStream().where()