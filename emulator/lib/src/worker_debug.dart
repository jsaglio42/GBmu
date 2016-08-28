// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_debug.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 16:07:30 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
// import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
// import 'package:emulator/src/memory/rom.dart' as Rom;
// import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
// import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

abstract class Debug implements Worker.AWorker {

  Ft.Routine<DebuggerExternalMode> _rout;
  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  static const int _debuggerMemoryLen = 144; // <- bad, should be initialised by dom
  int _debuggerMemoryAddr = 0;

  // EXTERNAL CONTROL ******************************************************* **

  void _onMemoryAddrChangeReq(int addr)
  {
    Ft.log('worker_debug', '_onMemoryAddrChangeReq', addr);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_onMemoryAddrChangeReq: addr not valid');
    _debuggerMemoryAddr = addr;

    // TODO: removed cause not sure that GameBoy is present
    // this.ports.send('MemInfo',  <String, dynamic> {
    //     'addr' : _debuggerMemoryAddr,
    //     'data' : _buildMemoryList(_debuggerMemoryAddr, ???)
    //   });
    return ;
  }

  void _onDebModeChangeReq(DebuggerModeRequest req)
  {
    switch (req) {
      case (DebuggerModeRequest.Toggle):
        if (_rout.externalMode == DebuggerExternalMode.Dismissed)
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

  // INTERNAL CONTROL ******************************************************* **

  void _enable()
  {
    assert(_rout.externalMode == DebuggerExternalMode.Dismissed,
        "worker_deb: _disable() while enabled");
    _rout.changeExternalMode(DebuggerExternalMode.Operating);
    this.ports.send('DebStatusUpdate', true);
  }

  void _disable()
  {
    assert(_rout.externalMode == DebuggerExternalMode.Operating,
        "worker_deb: _disable() while disabled");
    _rout.changeExternalMode(DebuggerExternalMode.Dismissed);
    this.ports.send('DebStatusUpdate', false);
  }

  Uint8List   _buildMemoryList(int addr, Gameboy.GameBoy gb)
  {
    Ft.log('worker_debug', '_buildMemoryList', addr);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_buildMemExplorerMap: addr not valid');
    final memList = new List.generate(_debuggerMemoryLen, (i) {
      return gb.mmu.pullMem8(addr + i);
    });
    return new Uint8List.fromList(memList);
  }

  // ROUTINE CONTROL ******************************************************** **

  void _onDebug([_])
  {
    assert(this.rc.getExtMode(GameBoyExternalMode)
        != GameBoyExternalMode.Absent, "_onDebug with no gameboy");

    final l = new Uint8List(MemReg.values.length);
    final it = new Ft.DoubleIterable(MemReg.values, Memregisters.memRegInfos);
    final Gameboy.GameBoy gb = this.gbOpt.v;

    this.ports.send('RegInfo', gb.cpuRegs);
    it.forEach((r, i) {
      l[r.index] = gb.mmu.pullMemReg(r);
    });
    this.ports.send('MemInfo',  <String, dynamic> {
      'addr' : _debuggerMemoryAddr,
      'data' : _buildMemoryList(_debuggerMemoryAddr, gb)
    });
    this.ports.send('MemRegInfo', l);
    this.ports.send('ClockInfo', gb.clockCount);
    return ;
  }

  void _makeLooping()
  {
    Ft.log('worker_deb', '_makeLooping');
    assert(_sub.isPaused, "worker_deb: _makeLooping while not paused");
    _sub.resume();
  }

  void _makeDormant()
  {
    Ft.log('worker_deb', '_makeDormant');
    assert(!_sub.isPaused, "worker_deb: _makeDormant while paused");
    _sub.pause();
    if (this.rc.getExtMode(GameBoyExternalMode) !=
        GameBoyExternalMode.Absent)
      _onDebug();
  }

  // CONSTRUCTION *********************************************************** **

  void init_debug([_])
  {
    Ft.log('worker_debug', 'init_debug');
    _periodic = new Async.Stream.periodic(DEBUG_PERIOD_DURATION);
    _sub = _periodic.listen(_onDebug);
    _sub.pause();
    _rout = new Ft.Routine<DebuggerExternalMode>(
        this.rc,
        [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating],
        _makeLooping, _makeDormant, DebuggerExternalMode.Operating);
    this.ports.listener('DebStatusRequest').forEach(_onDebModeChangeReq);
    this.ports.listener('DebMemAddrChange').forEach(_onMemoryAddrChangeReq);
  }

}