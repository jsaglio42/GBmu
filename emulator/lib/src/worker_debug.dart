// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_debug.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:51:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 19:23:24 by ngoguey          ###   ########.fr       //
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

  void _onDebug([_])
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

  final static Map<List<dynamic>, bool>_combinations = {
      // Subscription `false` but shouldn't
    [Status.Emulating, DebStatus.ON, false, 'deb+']: false,
    [Status.Emulating, DebStatus.ON, false, 'deb-']: false,
    [Status.Emulating, DebStatus.ON, false, 'emu+']: false,
    [Status.Emulating, DebStatus.ON, false, 'emu-']: false,

    // Subscription `true` but shouldn't
    [Status.Emulating, DebStatus.OFF, true, 'deb+']: false,
    [Status.Emulating, DebStatus.OFF, true, 'deb-']: false,
    [Status.Crashed, DebStatus.OFF, true, 'deb+']: false,
    [Status.Crashed, DebStatus.OFF, true, 'deb-']: false,
    [Status.Crashed, DebStatus.ON, true, 'deb+']: false,
    [Status.Crashed, DebStatus.ON, true, 'deb-']: false,
    [Status.Empty, DebStatus.OFF, true, 'deb+']: false,
    [Status.Empty, DebStatus.OFF, true, 'deb-']: false,
    [Status.Empty, DebStatus.ON, true, 'deb+']: false,
    [Status.Empty, DebStatus.ON, true, 'deb-']: false,
    [Status.Emulating, DebStatus.OFF, true, 'emu+']: false,
    [Status.Emulating, DebStatus.OFF, true, 'emu-']: false,
    [Status.Crashed, DebStatus.OFF, true, 'emu+']: false,
    [Status.Crashed, DebStatus.OFF, true, 'emu-']: false,
    [Status.Empty, DebStatus.OFF, true, 'emu+']: false,
    [Status.Empty, DebStatus.OFF, true, 'emu-']: false,
    [Status.Crashed, DebStatus.ON, true, 'emu+']: false,
    [Status.Crashed, DebStatus.ON, true, 'emu-']: false,
    [Status.Empty, DebStatus.ON, true, 'emu+']: false,
    [Status.Empty, DebStatus.ON, true, 'emu-']: false,

    // Bad event `deb+`
    [Status.Empty, DebStatus.ON, false, 'deb+']: false,
    [Status.Crashed, DebStatus.ON, false, 'deb+']: false,
    [Status.Emulating, DebStatus.ON, true, 'deb+']: false,

    // Bad event `deb-`
    [Status.Emulating, DebStatus.OFF, false, 'deb-']: false,
    [Status.Crashed, DebStatus.OFF, false, 'deb-']: false,
    [Status.Empty, DebStatus.OFF, false, 'deb-']: false,

    // Bad event `emu+`
    [Status.Emulating, DebStatus.OFF, false, 'emu+']: false,
    [Status.Emulating, DebStatus.ON, true, 'emu+']: false,

    // Bad event `emu-`
    [Status.Empty, DebStatus.OFF, false, 'emu-']: false,
    [Status.Empty, DebStatus.ON, false, 'emu-']: false,

    // Valid `emu` action without effect
    [Status.Crashed, DebStatus.OFF, false, 'emu-']: true,
    [Status.Crashed, DebStatus.ON, false, 'emu-']: true,
    [Status.Emulating, DebStatus.OFF, false, 'emu-']: true,
    [Status.Crashed, DebStatus.OFF, false, 'emu+']: true,
    [Status.Empty, DebStatus.OFF, false, 'emu+']: true,

    //  Valid `deb` action without effect on sub
    [Status.Crashed, DebStatus.OFF, false, 'deb+']: true,
    [Status.Empty, DebStatus.OFF, false, 'deb+']: true,
    [Status.Crashed, DebStatus.ON, false, 'deb-']: true,
    [Status.Empty, DebStatus.ON, false, 'deb-']: true,

    // Enable sub
    [Status.Emulating, DebStatus.OFF, false, 'deb+']: true,
    [Status.Empty, DebStatus.ON, false, 'emu+']: true,
    [Status.Crashed, DebStatus.ON, false, 'emu+']: true,

    // Disable sub
    [Status.Emulating, DebStatus.ON, true, 'deb-']: true,
    [Status.Emulating, DebStatus.ON, true, 'emu-']: true,
  };

  bool _isCorrect(String action) {
    var k = [this.status, _debuggerStatus, !_sub.isPaused, action];
    var b;

    _combinations.forEach((l, v) {
      if (
          // this.status == l[0] &&
          _debuggerStatus == l[1] &&
          !_sub.isPaused == l[2] &&
          action == l[3])
        b = v;
    });
    if (!b)
      print('Invalid: $k');
    return b;
  }

  void _onDebStart(_) {
    Ft.log('worker_debug', '_onDebStart');
    assert(_isCorrect('deb+'), 'Invalid call to _onDebStart');

    final es = this.status;

    _debuggerStatus = DebStatus.ON;
    this.ports.send('DebStatusUpdate', _debuggerStatus);
    if (es == Status.Emulating)
      _sub.resume();
  }
  void _onDebStop(_) {
    Ft.log('worker_debug', '_onDebStop');
    assert(_isCorrect('deb-'), 'Invalid call to _onDebStop');

    final es = this.status;

    _debuggerStatus = DebStatus.OFF;
    this.ports.send('DebStatusUpdate', _debuggerStatus);
    if (es == Status.Emulating)
      _sub.pause();
  }
  void _onEmuStart(_) {
    Ft.log('worker_debug', '_onEmuStart');
    assert(_isCorrect('emu+'), 'Invalid call to _onEmuStart');

    final ds = _debuggerStatus;

    if (ds == DebStatus.ON)
      _sub.resume();
  }
  void _onEmuStop(_) {
    Ft.log('worker_debug', '_onEmuStop');
    assert(_isCorrect('emu-'), 'Invalid call to _onEmuStop');

    final ds = _debuggerStatus;

    if (ds == DebStatus.ON)
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
      .forEach(_onEmuStop)
      ..where((Map map) => map['type'] == Event.Eject)
      .forEach(_onEmuStop)
      ..where((Map map) => map['type'] == Event.Start)
      .forEach(_onEmuStart)
      ;
    this.ports.listener('DebStatusRequest')
      ..where((v) => v.index == DebStatusRequest.ENABLE.index)
      .forEach(_onDebStart)
      ..where((v) => v.index == DebStatusRequest.DISABLE.index)
      .forEach(_onDebStop)
      ..where((v) => v.index == DebStatusRequest.TOGGLE.index)
      .forEach((v) {
            if (_debuggerStatus == DebStatus.ON)
              _onDebStop(null);
            else
              _onDebStart(null);
          })
      ;
    this.ports.listener('DebMemAddrChange').forEach(_onMemoryAddrChange);
  }

}