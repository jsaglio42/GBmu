// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   wired_isolate.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/21 16:00:05 by ngoguey          ###   ########.fr       //
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
Map<String, Is.ReceivePort> _rPortsOfTypes(Map<String, Type> t)
{
  var m = new Map<String, Is.ReceivePort>();

  t.forEach((k, _) {
    m.putIfAbsent(k, () => new Is.ReceivePort());
  });
  return m;
}

Map<String, Is.SendPort> _sPortsOfRPorts(Map<String, Is.ReceivePort> rp)
{
  var m = new Map<String, Is.SendPort>();

  rp.forEach((k, v) {
    m.putIfAbsent(k, () => v.sendPort);
  });
  return m;
}

Map<String, As.Stream> _streamsOfRPorts(Map<String, Is.ReceivePort> rp)
{
  var m = new Map<String, As.Stream>();

  rp.forEach((k, v) {
    m.putIfAbsent(k, () => v.asBroadcastStream());
  });
  return m;
}


/*
 * ************************************************************************** **
 * Isolate entry point and it's parameter of type `_WorkerSpawnData` ********* **
 * ************************************************************************** **
 */
typedef void entryPointType(Ports);
class _WorkerSpawnData {
  _WorkerSpawnData(this.sPortsMain, this.tmpSPort, this.entryPoint,
      this.mainRTypes, this.workerRTypes, this.resumeCapability);

  final Map<String, Is.SendPort> sPortsMain;
  final Is.SendPort tmpSPort;
  final entryPointType entryPoint;
  final Map<String, Type> mainRTypes;
  final Map<String, Type> workerRTypes;
  final Is.Capability resumeCapability;
}

void _workerSpawn(_WorkerSpawnData d)
{
  print('wired_isolate:\t_workerSpawn()');

  final Map<String, Is.ReceivePort> rPortsWorker = _rPortsOfTypes(
      d.workerRTypes);
  final p = new Ports(
      _streamsOfRPorts(rPortsWorker), d.sPortsMain, d.mainRTypes);
  d.tmpSPort.send(_sPortsOfRPorts(rPortsWorker));
  Is.Isolate.current.pause(d.resumeCapability);
  d.entryPoint(p);
  return ;
}


/*
 * ************************************************************************** **
 * `spawn()` method and it's return value of type `Data` ******************** **
 * ************************************************************************** **
 */
class Data {
  Data(this.i, this.resumeCapability, this.p);

  final Is.Isolate i;
  final Is.Capability resumeCapability;
  final Ports p;
}

As.Future<Data> spawn(void entryPoint(Ports), Map<String, Type> mainRTypes,
    Map<String, Type> workerRTypes) async
{
  print('wired_isolate:\tspawn()');

  final Map<String, Is.ReceivePort> rPortsMain = _rPortsOfTypes(mainRTypes);

  final Is.ReceivePort tmpRPort = new Is.ReceivePort();
  final Is.Capability resumeCapability = new Is.Capability();
  final spawnData = new _WorkerSpawnData(
      _sPortsOfRPorts(rPortsMain), tmpRPort.sendPort, entryPoint,
      mainRTypes, workerRTypes, resumeCapability);
  final Is.Isolate iso = await Is.Isolate.spawn(_workerSpawn, spawnData);
  final Map<String, Is.SendPort> sPortsWorker = await tmpRPort.first;
  final p = new Ports(
      _streamsOfRPorts(rPortsMain), sPortsWorker, workerRTypes);

  return new Data(iso, resumeCapability, p);
}
