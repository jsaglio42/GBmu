// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:30 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 15:51:43 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
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
    var rng = new Math.Random();

    print('worker:\tonEmulationStart($p)');
    _ports.send('RegInfo', <Register, int>{
      Register.PC: rng.nextInt(256 * 256),
      Register.AF: rng.nextInt(256 * 256),
      Register.BC: rng.nextInt(256 * 256),
      Register.DE: rng.nextInt(256 * 256),
      Register.HL: rng.nextInt(256 * 256),
      Register.SP: rng.nextInt(256 * 256),
    });
    _ports.send('VRegInfo', <VRegister, int>{
      VRegister.LCDC: rng.nextInt(256 * 256),
      VRegister.STAT: rng.nextInt(256 * 256),
      VRegister.SCY: rng.nextInt(256 * 256),
      VRegister.SCX: rng.nextInt(256 * 256),
      VRegister.LY: rng.nextInt(256 * 256),
      VRegister.LYC: rng.nextInt(256 * 256),
      VRegister.DMA: rng.nextInt(256 * 256),
      VRegister.BGP: rng.nextInt(256 * 256),
      VRegister.OBP0: rng.nextInt(256 * 256),
      VRegister.OBP1: rng.nextInt(256 * 256),
      VRegister.WY: rng.nextInt(256 * 256),
      VRegister.WX: rng.nextInt(256 * 256),
      VRegister.BCPS: rng.nextInt(256 * 256),
      VRegister.BCPD: rng.nextInt(256 * 256),
      VRegister.OCPS: rng.nextInt(256 * 256),
      VRegister.OCPD: rng.nextInt(256 * 256),
    });
    _ports.send('ORegInfo', <ORegister, int>{
      ORegister.P1: rng.nextInt(256 * 256),
      ORegister.SB: rng.nextInt(256 * 256),
      ORegister.SC: rng.nextInt(256 * 256),
      ORegister.DIV: rng.nextInt(256 * 256),
      ORegister.TIMA: rng.nextInt(256 * 256),
      ORegister.TMA: rng.nextInt(256 * 256),
      ORegister.TAC: rng.nextInt(256 * 256),
      ORegister.KEY1: rng.nextInt(256 * 256),
      ORegister.VBK: rng.nextInt(256 * 256),
      ORegister.HDMA1: rng.nextInt(256 * 256),
      ORegister.HDMA2: rng.nextInt(256 * 256),
      ORegister.HDMA3: rng.nextInt(256 * 256),
      ORegister.HDMA4: rng.nextInt(256 * 256),
      ORegister.HDMA5: rng.nextInt(256 * 256),
      ORegister.SVBK: rng.nextInt(256 * 256),
      ORegister.IF: rng.nextInt(256 * 256),
      ORegister.IE: rng.nextInt(256 * 256),
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
