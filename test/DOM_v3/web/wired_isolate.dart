// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   wired_isolate.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 15:17:13 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;
import 'dart:isolate' as Is;

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
 * Port: Ports wrapper ****************************************************** **
 * ************************************************************************** **
 * In Main: Ports is retreived from Emulator's call to wired_isolate.spawn()
 * In Worker: Pors is retrieved from `entryPoint` arguments
 */
class Ports {

  Ports(this._listeners, this._notifiers, this._notifiersTypes);

  final Map<String, As.Stream> _listeners;
  final Map<String, Is.SendPort> _notifiers;
  final Map<String, Type> _notifiersTypes;

  bool _isValidListenerGetter(String n) {
    if (_listeners[n] == null) {
      print('wired_isolate.Ports.listener($n) $n not found');
      return false;
    }
    else
      return true;
  }

  bool _isValidSendCall(String n, var p) {
    if (_notifiersTypes[n] == null) {
      print('wired_isolate.Ports.send($n, $p) $n not found');
      return false;
    }
    else if (_notifiersTypes[n] != p.runtimeType) {
      print('wired_isolate.Ports.send($n, $p)'
          'parameter is (${p.runtimeType}) '
          'instead of (${_notifiersTypes[p]})');
      return false;
    }
    else
      return true;
  }

  dynamic listener(String n) {
    assert(_isValidListenerGetter(n));
    return _listeners[n];
  }

  void send(String n, var p) {
    assert(_isValidSendCall(n, p));
    _notifiers[n].send(p);
    return ;
  }
}


/*
 * ************************************************************************** **
 * Map conversion functions ************************************************* **
 * ************************************************************************** **
 * Is there any simpler way ?
*/

Map<String, Is.ReceivePort> rPortsOfTypes(Map<String, Type> t)
{
  var m = new Map<String, Is.ReceivePort>();

  t.forEach((k, _) {
    m.putIfAbsent(k, () => new Is.ReceivePort());
  });
  return m;
}

Map<String, Is.SendPort> sPortsOfRPorts(Map<String, Is.ReceivePort> rp)
{
  var m = new Map<String, Is.SendPort>();

  rp.forEach((k, v) {
    m.putIfAbsent(k, () => v.sendPort);
  });
  return m;
}

Map<String, As.Stream> streamsOfRPorts(Map<String, Is.ReceivePort> rp)
{
  var m = new Map<String, As.Stream>();

  rp.forEach((k, v) {
    m.putIfAbsent(k, () => v.asBroadcastStream());
  });
  return m;
}

/*
 * ************************************************************************** **
 * Isolate entry point and it's parameter of type `WorkerSpawnData` ********* **
 * ************************************************************************** **
 */
typedef void entryPointType(Ports);
class WorkerSpawnData {
  WorkerSpawnData(this.sPortsMain, this.tmpSPort, this.entryPoint);

  final Map<String, Is.SendPort> sPortsMain;
  final Is.SendPort tmpSPort;
  final entryPointType entryPoint;
}

void workerSpawn(WorkerSpawnData d)
{
  print('wired_isolate:workerSpawn()');

  final Map<String, Is.ReceivePort> rPortsWorker =
    rPortsOfTypes(workerReceivers);
  final p = new Ports(streamsOfRPorts(rPortsWorker), d.sPortsMain, mainReceivers);
  d.tmpSPort.send(sPortsOfRPorts(rPortsWorker));
  d.entryPoint(p);
  return ;
}


/*
 * ************************************************************************** **
 * `spawn()` method and it's return value of type `Data` ******************** **
 * ************************************************************************** **
 */
class Data {
  Data(this.i, this.p);

  final Is.Isolate i;
  final Ports p;
}

As.Future<Data> spawn(void entryPoint(Ports)) async
{
  print('wired_isolate:spawn()');

  final Map<String, Is.ReceivePort> rPortsMain = rPortsOfTypes(mainReceivers);

  final Is.ReceivePort tmpRPort = new Is.ReceivePort();
  final spawnData = new WorkerSpawnData(
      sPortsOfRPorts(rPortsMain),
      tmpRPort.sendPort,
      entryPoint);
  final Is.Isolate iso = await Is.Isolate.spawn(workerSpawn, spawnData);
  final Map<String, Is.SendPort> sPortsWorker = await tmpRPort.first;
  final p = new Ports(
      streamsOfRPorts(rPortsMain), sPortsWorker, workerReceivers);

  return new Data(iso, p);
}
