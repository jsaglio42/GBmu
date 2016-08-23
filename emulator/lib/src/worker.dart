// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 15:45:19 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as math;
import 'dart:typed_data';
// import 'dart:isolate' as Is;
// import 'dart:async' as As;
import 'package:ft/wired_isolate.dart' as WI;

// import './emulator.dart' as Em;
import './public_classes.dart';
import './memory/mmu.dart' as MMU;
import 'cpu_registers.dart' as CPUR;

var rng = new math.Random();

Map _generateRandomMapFromIterable(Iterable l, int value_range)
{
  final size = math.max(1, rng.nextInt(l.length));
  final m = {};
  var v;

  for (int i = 0; i < size; i++) {
    v = l.elementAt(rng.nextInt(l.length));
    m[v] = rng.nextInt(value_range);
  }
  return m;
}

/*
 * ************************************************************************** **
 * Worker Class
 * ************************************************************************** **
 */

class Worker {

  final WI.Ports        _ports;
 
  DebStatus           _debuggerStatus = DebStatus.ON;
  MMU.MMU             _mmu = new MMU.MMU();
  CPUR.RegisterBank   _cpuRegs = new CPUR.RegisterBank();

  Worker(this._ports)
  {
    _ports.listener('EmulationStart').listen(_onEmulationStart);
    _ports.listener('EmulationMode').listen(_onEmulationMode);
    _ports.listener('DebStatusRequest').listen(_onDebuggerStanteChange);
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

 // *********************************************** **
 // Callback functions
 // *********************************************** **

  void _onEmulationStart(Uint8List data)
  {
    print('worker:\tonEmulationStart(l len:${data.length})');
    _mmu.loadRom(data);
    _cpuRegs.init();
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

}

/*
 * ************************************************************************** **
 * Entry Point
 * ************************************************************************** **
 */

Worker _globalWorker;

void entryPoint(WI.Ports p)
{
  print('worker:\tentryPoint($p)');

  assert(_globalWorker == null);
  _globalWorker = new Worker(p);
  return ;
}
