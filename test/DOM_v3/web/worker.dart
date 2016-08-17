// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 14:03:41 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:isolate' as Isolate;
import 'dart:async' as Async;
import 'wired_isolate.dart' as WI;
import 'emulator.dart' as Em;

class Worker {

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationMode').listen(_onEmulationMode);
    _ports.listener('DebStatusRequest').listen(_onDebuggerStanteChange);
  }
  final WI.Ports _ports;
  Em.DebStatus _debuggerStatus = Em.DebStatus.ON;

  void _onEmulationStart(int p)
  {
    print('worker:\tonEmulationStart($p)');
    _ports.send('RegInfo', <String, int>{
      'rpb': 12,
      'eax': 15,
    });
    return ;
  }

  void _onEmulationMode(String p)
  {
    print('worker:\tonEmulationMode($p)');
    return ;
  }

  void _onDebuggerStanteChange(Em.DebStatusRequest p)
  {
    print('worker:\tonDebuggerStateChange($p ${p.index})');

    // Enum equality fails after passing through a SendPort
    if (p.index == Em.DebStatusRequest.TOGGLE.index) {
        if (_debuggerStatus == Em.DebStatus.ON)
          _disableDebugger();
        else
          _enableDebugger();
    }
    else if (p.index == Em.DebStatusRequest.DISABLE.index) {
      if (_debuggerStatus == Em.DebStatus.ON)
        _disableDebugger();
    }
    else if (p.index == Em.DebStatusRequest.ENABLE.index) {
        if (_debuggerStatus == Em.DebStatus.OFF)
          _enableDebugger();
    }
    return ;
  }

  void _disableDebugger()
  {
    _debuggerStatus = Em.DebStatus.OFF;
    _ports.send('DebStatusUpdate', _debuggerStatus);
  }
  void _enableDebugger()
  {
    _debuggerStatus = Em.DebStatus.ON;
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
