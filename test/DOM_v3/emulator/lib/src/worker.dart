// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 16:09:58 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
// import 'dart:isolate' as Is;
// import 'dart:async' as As;
import './wired_isolate.dart' as WI;
import './emulator.dart' as Em;
import './conf.dart';

var rng = new Math.Random();

Map _generateRandomMapFromIterable(Iterable l, int value_range)
{
  final size = rng.nextInt(l.length);
  final m = {};
  var v;

  for (int i = 0; i < size; i++) {
    v = l.elementAt(rng.nextInt(l.length));
    m[v] = rng.nextInt(value_range);
  }
  return m;
}

class Worker {

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationMode').listen(_onEmulationMode);
    _ports.listener('DebStatusRequest').listen(_onDebuggerStanteChange);
  }
  final WI.Ports _ports;
  DebStatus _debuggerStatus = DebStatus.ON;

  void _onEmulationStart(int p)
  {
    // var rng = new Math.Random();

    print('worker:\tonEmulationStart($p)');
    _ports.send('RegInfo', new Map<Register, int>.from(
            _generateRandomMapFromIterable(Register.values, 256 * 256)));
    _ports.send('VRegInfo', new Map<VRegister, int>.from(
            _generateRandomMapFromIterable(VRegister.values, 256)));
    _ports.send('ORegInfo', new Map<ORegister, int>.from(
            _generateRandomMapFromIterable(ORegister.values, 256)));
      return ;
  }

  void _onEmulationMode(String p)
  {
    print('worker:\tonEmulationMode($p)');
    return ;
  }

  void _onDebuggerStanteChange(DebStatusRequest p)
  {
    print('worker:\tonDebuggerStateChange($p ${p.index})');

    // Enum equality fails after passing through a SendPort
    if (p.index == DebStatusRequest.TOGGLE.index) {
        if (_debuggerStatus == DebStatus.ON)
          _disableDebugger();
        else
          _enableDebugger();
    }
    else if (p.index == DebStatusRequest.DISABLE.index) {
      if (_debuggerStatus == DebStatus.ON)
        _disableDebugger();
    }
    else if (p.index == DebStatusRequest.ENABLE.index) {
        if (_debuggerStatus == DebStatus.OFF)
          _enableDebugger();
    }
    return ;
  }

  void _disableDebugger()
  {
    _debuggerStatus = DebStatus.OFF;
    _ports.send('DebStatusUpdate', _debuggerStatus);
  }
  void _enableDebugger()
  {
    _debuggerStatus = DebStatus.ON;
    _ports.send('DebStatusUpdate', _debuggerStatus);
  }
}

Worker _globalWorker;

void entryPoint(WI.Ports p)
{
  print('worker:\tentryPoint($p)');

  assert(_globalWorker == null);
  _globalWorker = new Worker(p);
  return ;
}
