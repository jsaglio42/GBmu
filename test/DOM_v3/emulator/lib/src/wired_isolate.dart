// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   wired_isolate.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 16:25:50 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as As;
import 'dart:isolate' as Is;

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

  bool _isValidListenerGet(String n) {
    if (_listeners[n] == null) {
      print('wired_isolate:\tPorts.listener($n) $n not found');
      return false;
    }
    else
      return true;
  }

  bool _isValidSendCall(String n, var p) {
    final Type t = _notifiersTypes[n];
    final Type pt = p.runtimeType;

    if (t == null) {
      print('wired_isolate:\tPorts.send($n, $p) $n not found');
      return false;
    }
    else if (t != pt) {
      print('wired_isolate:\tPorts.send($n, $p)'
          'parameter is ($pt) '
          'instead of ($t)');
      return false;
    }
    else
      return true;
  }

  As.Stream listener(String n) {
    assert(_isValidListenerGet(n));
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
  WorkerSpawnData(this.sPortsMain, this.tmpSPort, this.entryPoint,
      this.mainRTypes, this.workerRTypes);

  final Map<String, Is.SendPort> sPortsMain;
  final Is.SendPort tmpSPort;
  final entryPointType entryPoint;
  final Map<String, Type> mainRTypes;
  final Map<String, Type> workerRTypes;
}

void workerSpawn(WorkerSpawnData d)
{
  print('wired_isolate:\tworkerSpawn()');

  final Map<String, Is.ReceivePort> rPortsWorker = rPortsOfTypes(
      d.workerRTypes);
  final p = new Ports(
      streamsOfRPorts(rPortsWorker), d.sPortsMain, d.mainRTypes);
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

As.Future<Data> spawn(void entryPoint(Ports), Map<String, Type> mainRTypes,
    Map<String, Type> workerRTypes) async
{
  print('wired_isolate:\tspawn()');

  final Map<String, Is.ReceivePort> rPortsMain = rPortsOfTypes(mainRTypes);

  final Is.ReceivePort tmpRPort = new Is.ReceivePort();
  final spawnData = new WorkerSpawnData(
      sPortsOfRPorts(rPortsMain), tmpRPort.sendPort, entryPoint,
      mainRTypes, workerRTypes);
  final Is.Isolate iso = await Is.Isolate.spawn(workerSpawn, spawnData);
  final Map<String, Is.SendPort> sPortsWorker = await tmpRPort.first;
  final p = new Ports(
      streamsOfRPorts(rPortsMain), sPortsWorker, workerRTypes);

  return new Data(iso, p);
}