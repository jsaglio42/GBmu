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
		// : _worker()
		// , _CPUStream()
		// , _CPUPort()
	{
		final uri = new Uri.file('worker.dart');

		_CPUPort = new Isolate.ReceivePort();
		Isolate.Isolate.spawnUri(uri, [], _CPUPort.sendPort)
			.then((worker) => this._worker = worker);
 

	}

	Isolate.Isolate					_worker;

	Isolate.ReceivePort						_CPUPort;
	// Stream<Map<String, Int>>		_CPUStream;

	// Stream<Map<String, Int>> get onCPUUpdate => _streamCPU;

}