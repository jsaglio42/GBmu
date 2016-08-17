// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 17:26:16 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// import 'dart:isolate' as Is;
// import 'dart:async' as As;
import './wired_isolate.dart' as WI;
import './emulator.dart' as Em;
import './conf.dart';

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
    print('worker:\tonEmulationStart($p)');
    _ports.send('RegInfo', <Register, int>{
      Register.PC: 12,
      Register.AF: 13,
      Register.BC: 14,
      Register.DE: 15,
      Register.HL: 16,
      Register.SP: 17,
    });
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
