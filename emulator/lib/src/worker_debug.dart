// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_debug.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 17:03:06 by ngoguey          ###   ########.fr       //
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
// import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

abstract class Debug implements Worker.AWorker {

  Async.Stream _periodic;
  Async.StreamSubscription _sub;
  DebStatus _debuggerStatus = DebStatus.ON;

  static const int _debuggerMemoryLen = 144; // <- bad, should be initialised by dom
  int _debuggerMemoryAddr = 0;

  void _onDebug(_)
  {
    assert(this.status != Status.Empty, "_onDebug() while empty");
    assert(_debuggerStatus == DebStatus.ON, "_onDebug() while off");
    final l = new Uint8List(MemReg.values.length);
    final it = new Ft.DoubleIterable(MemReg.values, Memregisters.memRegInfos);

    this.ports.send('RegInfo', this.gb.cpuRegs);
    it.forEach((r, i) {
      l[r.index] = this.gb.mmu.pullMemReg(r);
    });
    this.ports.send('MemInfo',  <String, dynamic> {
      'addr' : _debuggerMemoryAddr,
      'data' : _buildMemoryList(_debuggerMemoryAddr)
    });
    this.ports.send('MemRegInfo', l);
    this.ports.send('ClockInfo', this.gb.clockCount);
    return ;
  }

  void _onMemoryAddrChange(int addr)
  {
    Ft.log('worker_debug', '_onMemoryAddrChange', addr);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_onMemoryAddrChange: addr not valid');
    _debuggerMemoryAddr = addr;
    this.ports.send('MemInfo',  <String, dynamic> {
        'addr' : _debuggerMemoryAddr,
        'data' : _buildMemoryList(_debuggerMemoryAddr)
      });
    return ;
  }

  Uint8List   _buildMemoryList(int addr)
  {
    Ft.log('worker_debug', '_buildMemoryList', addr);
    assert((addr >= 0) && (addr <= 0x10000 - _debuggerMemoryLen)
        , '_buildMemExplorerMap: addr not valid');
    final memList = new List.generate(_debuggerMemoryLen, (i) {
      return this.gb.mmu.pullMem8(addr + i);
    });
    return new Uint8List.fromList(memList);
  }

  /* CONTROL **************************************************************** */

  void _disable([_]) {
    Ft.log('worker_debug', '_disable');
    if (this.status == Status.Crashed)
      _onDebug(null);
    _end();
    _debuggerStatus = DebStatus.OFF;
    this.ports.send('DebStatusUpdate', _debuggerStatus);
  }

  void _enable([_]) {
    Ft.log('worker_debug', '_enable');
    _begin();
    _sub.resume();
    this.ports.send('DebStatusUpdate', _debuggerStatus);
  }

  void _begin([_]) {
    assert(_sub.isPaused, "resume debug while not stopped");
    _sub.resume();
  }

  void _end([_]) {
    assert(!_sub.isPaused, "stop debug while stopped");
    _sub.pause();
  }

  void init_debug([_])
  {
    Ft.log('worker_debug', 'init_debug');
    _periodic = new Async.Stream.periodic(DEBUG_PERIOD_DURATION);
    _sub = _periodic.listen(_onDebug);
    _sub.pause();
    this.events
      ..where((Map map) => map['type'] == Event.FatalError)
      .forEach(_end)
      ..where((Map map) => map['type'] == Event.Eject)
      .forEach(_end)
      ..where((Map map) => map['type'] == Event.Start)
      .forEach(_begin)
      ;
    this.ports.listener('DebStatusRequest')
      ..where((v) => v.index == DebStatusRequest.ENABLE.index)
      .forEach(_enable)
      ..where((v) => v.index == DebStatusRequest.DISABLE.index)
      .forEach(_disable)
      ..where((v) => v.index == DebStatusRequest.TOGGLE.index
          && _debuggerStatus == DebStatus.ON)
      .forEach(_disable)
      ..where((v) => v.index == DebStatusRequest.TOGGLE.index
          && _debuggerStatus == DebStatus.OFF)
      .forEach(_enable)
      ;
    this.ports.listener('DebMemAddrChange').forEach(_onMemoryAddrChange);
  }

}