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

import 'dart:async' as Async;
import 'dart:isolate' as Isolate;

class Emulator {

	Emulator()
	{
		_CPUPort = new Isolate.ReceivePort();
		_CPUStream = _CPUPort.asBroadcastStream();

		final uri = new Uri.file('worker.dart');
		final Isolate.ReceivePort workerInitPort = new Isolate.ReceivePort();

		workerInitPort.listen((Map<String, Isolate.SendPort> map){
			this._startEmulationPort = map['startemulationport'];
		});


		Isolate.Isolate.spawnUri(uri, [],
			{'cpuport': _CPUPort.sendPort
			, 'workerinitport': workerInitPort.sendPort}
			)
			.then((worker) => this._worker = worker);
 
	}

	Isolate.Isolate					_worker;

	Isolate.ReceivePort				_CPUPort;
	Async.Stream<Map<String, int>>	_CPUStream;
	Async.Stream<Map<String, int>> get onCPUUpdate => _CPUStream;

	Isolate.SendPort				_startEmulationPort;

	void							startEmulation(lolparam){
		_startEmulationPort.send(lolparam);
	}


}