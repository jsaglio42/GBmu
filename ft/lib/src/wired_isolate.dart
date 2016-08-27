// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   wired_isolate.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/15 10:47:48 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 12:10:14 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:async' as Async;
import 'dart:isolate' as Iso;
import 'package:ft/ft.dart' as Ft;

/*
 * ************************************************************************** **
 * Port: Ports wrapper ****************************************************** **
 * ************************************************************************** **
 * In Main: Ports is retreived from Emulator's call to wired_isolate.spawn()
 * In Worker: Pors is retrieved from `entryPoint` arguments
 */

class Ports
{

  final Map<String, Async.Stream>    _listeners;
  final Map<String, Iso.SendPort>  _notifiers;
  final Map<String, Type>         _notifiersTypes;

  Ports(this._listeners, this._notifiers, this._notifiersTypes);

  bool _isValidListenerGet(String n)
  {
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

  Async.Stream listener(String typeid) {
    assert(_isValidListenerGet(typeid));
    return _listeners[typeid];
  }

  void send(String typeid, var data) {
    assert(_isValidSendCall(typeid, data));
    _notifiers[typeid].send(data);
    return ;
  }
}

/*
 * ************************************************************************** **
 * Map conversion functions ************************************************* **
 * ************************************************************************** **
 * Is there any simpler way ?
*/

Map<String, Iso.ReceivePort> _rPortsOfTypes(Map<String, Type> t)
{
  var m = new Map<String, Iso.ReceivePort>();

  t.forEach((k, _) {
    m.putIfAbsent(k, () => new Iso.ReceivePort());
  });
  return m;
}

Map<String, Iso.SendPort> _sPortsOfRPorts(Map<String, Iso.ReceivePort> rp)
{
  var m = new Map<String, Iso.SendPort>();

  rp.forEach((k, v) {
    m.putIfAbsent(k, () => v.sendPort);
  });
  return m;
}

Map<String, Async.Stream> _streamsOfRPorts(Map<String, Iso.ReceivePort> rp)
{
  var m = new Map<String, Async.Stream>();

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

  final Map<String, Iso.SendPort> sPortsMain;
  final Iso.SendPort tmpSPort;
  final entryPointType entryPoint;
  final Map<String, Type> mainRTypes;
  final Map<String, Type> workerRTypes;
  final Iso.Capability resumeCapability;
}

void _workerSpawn(_WorkerSpawnData d)
{
  Ft.log('wiso', '_workerSpawn', d);
  final Map<String, Iso.ReceivePort> rPortsWorker = _rPortsOfTypes(
      d.workerRTypes);
  final p = new Ports(
      _streamsOfRPorts(rPortsWorker), d.sPortsMain, d.mainRTypes);

  d.tmpSPort.send(_sPortsOfRPorts(rPortsWorker));
  Iso.Isolate.current.pause(d.resumeCapability);
  d.entryPoint(p);
  return ;
}

/*
 * ************************************************************************** **
 * `spawn()` method and it's return value of type `WiredIsolate` *****-****** **
 * ************************************************************************** **
 */

class WiredIsolate {

  WiredIsolate(this.i, this.resumeCapability, this.p);

  final Iso.Isolate i;
  final Iso.Capability resumeCapability;
  final Ports p;

}

Async.Future<WiredIsolate> spawn(void entryPoint(Ports),
  Map<String, Type> mainRTypes,
  Map<String, Type> workerRTypes)
async {
  Ft.log('wiso', 'spawn');

  final Map<String, Iso.ReceivePort> rPortsMain = _rPortsOfTypes(mainRTypes);
  final Iso.ReceivePort tmpRPort = new Iso.ReceivePort();
  final Iso.Capability resumeCapability = new Iso.Capability();
  final spawnData = new _WorkerSpawnData(
      _sPortsOfRPorts(rPortsMain), tmpRPort.sendPort, entryPoint,
      mainRTypes, workerRTypes, resumeCapability);
  final Iso.Isolate iso = await Iso.Isolate.spawn(_workerSpawn, spawnData);
  final Map<String, Iso.SendPort> sPortsWorker = await tmpRPort.first;
  final p = new Ports(
      _streamsOfRPorts(rPortsMain), sPortsWorker, workerRTypes);
  return new WiredIsolate(iso, resumeCapability, p);
}
