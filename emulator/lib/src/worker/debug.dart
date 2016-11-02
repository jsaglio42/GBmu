// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   debug.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 14:16:42 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/globals.dart';
import 'package:emulator/src/worker/worker.dart' as Worker;
import 'package:emulator/src/mixins/gameboy.dart' as Gameboy;
import 'package:emulator/src/mixins/instructions.dart' as Instructions;
import 'package:emulator/variants.dart' as V;

abstract class Debug implements Worker.AWorker {

  // ATTRIBUTES ************************************************************* **
  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  static const int _debuggerMemoryLen = 256; // should be initialised by dom
  static const int _debuggerInstFlowLen = 7; // should be initialised by dom
  int _debuggerMemoryAddr = 0;

  // CONSTRUCTION *********************************************************** **
  void init_debug([_])
  {
    Ft.log("WorkerDeb", 'init_debug');
    _periodic = new Async.Stream.periodic(DEBUG_PERIOD_DURATION);
    _sub = _periodic.listen(_onDebug);
    _sub.pause();
    this.sc.declareType(DebuggerExternalMode, DebuggerExternalMode.values,
        DebuggerExternalMode.Dismissed);
    this.sc.addSideEffect(_makeLooping, _makeDormant, [
      [V.Emulating.v, DebuggerExternalMode.Operating,
        PauseExternalMode.Ineffective],
    ]);
    this.sc.addSideEffect(_onDebOpen, (){}, [
      [DebuggerExternalMode.Operating],
    ]);
    this.sc.addSideEffect(_onPauseEffective, (){}, [
      [PauseExternalMode.Effective],
    ]);
    this.ports
      ..listener('DebStatusRequest').forEach(_onDebModeChangeReq)
      ..listener('DebMemAddrChange').forEach(_onMemoryAddrChangeReq);
    this.emulatorEvents
      .forEach(_onEmulatorEvent);
  }

  // CALLBACKS (DOM) ******************************************************** **
  void _onMemoryAddrChangeReq(int addr)
  {
    Ft.log("WorkerDeb", '_onMemoryAddrChangeReq', [addr]);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_onMemoryAddrChangeReq: addr not valid');
    _debuggerMemoryAddr = addr;

    if (this.gbMode is! V.Absent) {
      this.ports.send('MemInfo',  <String, dynamic> {
        'addr' : _debuggerMemoryAddr,
        'data' : _buildMemoryList(_debuggerMemoryAddr, this.gbOpt)
      });
    }
    return ;
  }

  void _onDebModeChangeReq(DebuggerModeRequest reqRaw)
  {
    final req = DebuggerModeRequest.values[reqRaw.index];

    switch (req) {
      case (DebuggerModeRequest.Toggle):
        if (this.debMode == DebuggerExternalMode.Dismissed)
          _enable();
        else
          _disable();
        break;
      case (DebuggerModeRequest.Disable):
        _disable();
        break;
      case (DebuggerModeRequest.Enable):
        _enable();
        break;
    }
  }

  // CALLBACKS (WORKER) ***************************************************** **
  void _onDebug([_])
  {
    // Ft.log("WorkerDeb", '_onDebug');
    assert(this.gbMode is! V.Absent,
        "_onDebug with no gameboy");

    final l = new Uint8List(MemReg.values.length);
    final it = new Ft.DoubleIterable(MemReg.values, g_memRegInfos);
    final Gameboy.GameBoy gb = this.gbOpt;
    this.ports.send('RegInfo', gb.cpur);
    it.forEach((r, i) {
      l[r.index] = gb.memr.pull8(r);
    });
    this.ports.send('MemInfo',  <String, dynamic> {
      'addr' : _debuggerMemoryAddr,
      'data' : _buildMemoryList(_debuggerMemoryAddr, gb)
    });
    this.ports.send('InstInfo', _buildInstList(gb));
    this.ports.send('MemRegInfo', l);
    this.ports.send('ClockInfo', gb.clockTotal);
    return ;
  }

  void _makeLooping()
  {
    Ft.log("WorkerDeb", '_makeLooping');
    assert(_sub.isPaused, "worker_deb: _makeLooping while not paused");
    _sub.resume();
  }

  void _makeDormant()
  {
    Ft.log("WorkerDeb", '_makeDormant');
    assert(!_sub.isPaused, "worker_deb: _makeDormant while paused");
    _sub.pause();
  }

  void _onDebOpen()
  {
    if (this.gbMode is! V.Absent)
      _onDebug();
  }

  void _onPauseEffective() {
    if (this.gbMode is! V.Absent)
      _onDebug();
  }

  void _onEmulatorEvent(V.EmulatorEvent ev) {
    if (ev is! V.Eject)
      _onDebug();
  }

  // SUBROUTINES ************************************************************ **
  void _enable()
  {
    if (this.debMode == DebuggerExternalMode.Dismissed) {
      this.sc.setState(DebuggerExternalMode.Operating);
      this.ports.send('DebStatusUpdate', true);
    }
  }

  void _disable()
  {
    if (this.debMode == DebuggerExternalMode.Operating) {
      this.sc.setState(DebuggerExternalMode.Dismissed);
      this.ports.send('DebStatusUpdate', false);
    }
  }

  List<int>   _buildMemoryList(int addr, Gameboy.GameBoy gb)
  {
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_buildMemExplorerMap: addr not valid');
    return gb.pullMemoryList(addr, _debuggerMemoryLen);

  }

  List<Instructions.Instruction>   _buildInstList(Gameboy.GameBoy gb)
  {
    return gb.pullInstructionList(_debuggerInstFlowLen);
  }

}
