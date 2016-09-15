// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_debug.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:04:06 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
// import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;

import 'package:emulator/src/z80/instructions.dart' as Instructions;
import 'package:emulator/src/z80/z80.dart' as Z80;

abstract class Debug implements Worker.AWorker {

  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  static const int _debuggerMemoryLen = 144; // <- bad, should be initialised by dom
  static const int _debuggerInstFlowLen = 7; // <- bad, should be initialised by dom
  int _debuggerMemoryAddr = 0;

  // EXTERNAL INTERFACE ***************************************************** **

  void _onMemoryAddrChangeReq(int addr)
  {
    Ft.log(Ft.typeStr(this), '_onMemoryAddrChangeReq', [addr]);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_onMemoryAddrChangeReq: addr not valid');
    _debuggerMemoryAddr = addr;

    if (this.gbMode == GameBoyExternalMode.Emulating
        && this.pauseMode == PauseExternalMode.Effective) {
      this.ports.send('MemInfo',  <String, dynamic> {
        'addr' : _debuggerMemoryAddr,
        'data' : _buildMemoryList(_debuggerMemoryAddr, this.gbOpt)
      });
    }
    // ---> Again, would rather check that gb is null
    // Uint8List memList;
    // if (this.gbOpt == null)
    // {
    //   print('onMemoryAddrChange: Cartridge not loaded');
    //   _debuggerMemoryAddr = 0x0000;
    //   memList = Uint8List(_debuggerMemoryLen);
    // }
    // else
    // {
    //   _debuggerMemoryAddr = addr;
    //   memList = _buildMemoryList(_debuggerMemoryAddr, this.gbOpt);
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

  List<int>   _buildMemoryList(int addr, Gameboy.GameBoy gb)
  {
    Ft.log(Ft.typeStr(this), '_buildMemoryList', [addr, gb]);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_buildMemExplorerMap: addr not valid');
    final memList = new List.generate(_debuggerMemoryLen,
      (i) {
        try { return gb.mmu.pull8(addr + i); }
        catch (e) { return null; }
      });
    return memList;
  }

  List<Instructions.Instruction>   _buildInstList(Gameboy.GameBoy gb)
  {
    Ft.log(Ft.typeStr(this), '_buildInstList', [gb]);
    final z80 = new Z80.Z80.clone(gb.z80);
    final lst = <Instructions.Instruction>[];
    for (var i = 0; i < _debuggerInstFlowLen; ++i) {
      lst.add(z80.pullInstruction());
    }
    return lst;
  }

  // LOOPING ROUTINE ******************************************************** **

  void _onDebug([_])
  {
    assert(this.gbMode != GameBoyExternalMode.Absent,
        "_onDebug with no gameboy");

    final l = new Uint8List(MemReg.values.length);
    final it = new Ft.DoubleIterable(MemReg.values, Memregisters.memRegInfos);
    final Gameboy.GameBoy gb = this.gbOpt;

    this.ports.send('RegInfo', gb.cpur);
    it.forEach((r, i) {
      l[r.index] = gb.mmu.pullMemReg(r);
    });
    this.ports.send('MemInfo',  <String, dynamic> {
      'addr' : _debuggerMemoryAddr,
      'data' : _buildMemoryList(_debuggerMemoryAddr, gb)
    });
    this.ports.send('InstInfo', _buildInstList(gb));
    this.ports.send('MemRegInfo', l);
    this.ports.send('ClockInfo', gb.clockCount);
    return ;
  }

  // SIDE EFFECTS CONTROLS ************************************************** **

  void _makeLooping()
  {
    Ft.log(Ft.typeStr(this), '_makeLooping');
    assert(_sub.isPaused, "worker_deb: _makeLooping while not paused");
    _sub.resume();
  }

  void _makeDormant()
  {
    Ft.log(Ft.typeStr(this), '_makeDormant');
    assert(!_sub.isPaused, "worker_deb: _makeDormant while paused");
    _sub.pause();
    if (this.gbMode != GameBoyExternalMode.Absent)
      _onDebug();
  }

  void _singleRefresh()
  {
    Ft.log(Ft.typeStr(this), '_singleRefresh');
    if (this.gbMode != GameBoyExternalMode.Absent)
      _onDebug();
  }

  // CONSTRUCTION *********************************************************** **

  void init_debug([_])
  {
    Ft.log(Ft.typeStr(this), 'init_debug');
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
