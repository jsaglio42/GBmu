// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_debug.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/30 07:27:26 by ngoguey          ###   ########.fr       //
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

  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  static const int _debuggerMemoryLen = 144; // <- bad, should be initialised by dom
  int _debuggerMemoryAddr = 0;

  // EXTERNAL INTERFACE ***************************************************** **

  void _onMemoryAddrChangeReq(int addr)
  {
    Ft.log('worker_debug', '_onMemoryAddrChangeReq', addr);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_onMemoryAddrChangeReq: addr not valid');
    _debuggerMemoryAddr = addr;

    // TODO: removed cause not sure that GameBoy is present    
    // Uint8List memList;
    // if (this.gbOpt.isSome)
    // {
    //   _debuggerMemoryAddr = addr;
    //   memList = _buildMemoryList(_debuggerMemoryAddr, this.gbOpt.v);
    // }
    // else
    // {
    //   print('onMemoryAddrChange: Cartridge not loaded');
    //   _debuggerMemoryAddr = 0x0000;
    //   memList = Uint8List(_debuggerMemoryLen);
    // }
    // this.ports.send('MemInfo',  <String, dynamic> {
    //     'addr' : _debuggerMemoryAddr,
    //     'data' : memList
    //   });
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

  // SECONDARY ROUTINES ***************************************************** **

  void _enable()
  {
    assert(this.debMode == DebuggerExternalMode.Dismissed,
        "worker_deb: _disable() while enabled");
    this.sc.setState(DebuggerExternalMode.Operating);
    this.ports.send('DebStatusUpdate', true);
  }

  void _disable()
  {
    assert(this.debMode == DebuggerExternalMode.Operating,
        "worker_deb: _disable() while disabled");
    this.sc.setState(DebuggerExternalMode.Dismissed);
    this.ports.send('DebStatusUpdate', false);
  }

  Uint8List   _buildMemoryList(int addr, Gameboy.GameBoy gb)
  {
    // Ft.log('worker_debug', '_buildMemoryList', addr);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_buildMemExplorerMap: addr not valid');
    final memList = new List.generate(_debuggerMemoryLen, (i) {
      return gb.mmu.pullMem8(addr + i);
    });
    return new Uint8List.fromList(memList);
  }

  // LOOPING ROUTINE ******************************************************** **

  void _onDebug([_])
  {
    assert(this.gbMode != GameBoyExternalMode.Absent,
        "_onDebug with no gameboy");

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

  // SIDE EFFECTS CONTROLS ************************************************** **

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
    if (this.gbMode != GameBoyExternalMode.Absent)
      _onDebug();
  }

  void _singleRefresh()
  {
    Ft.log('worker_deb', '_singleRefresh');
    if (this.gbMode != GameBoyExternalMode.Absent)
      _onDebug();
  }

  // CONSTRUCTION *********************************************************** **

  void init_debug([_])
  {
    Ft.log('worker_debug', 'init_debug');
    _periodic = new Async.Stream.periodic(DEBUG_PERIOD_DURATION);
    _sub = _periodic.listen(_onDebug);
    _sub.pause();
    this.sc.setState(DebuggerExternalMode.Operating);
    this.sc.addSideEffect(_makeLooping, _makeDormant, [
      [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating,
        PauseExternalMode.Ineffective],
    ]);
    this.sc.addSideEffect(_singleRefresh, (){}, [
      [DebuggerExternalMode.Operating],
    ]);
    this.ports.listener('DebStatusRequest').forEach(_onDebModeChangeReq);
    this.ports.listener('DebMemAddrChange').forEach(_onMemoryAddrChangeReq);
  }

}
