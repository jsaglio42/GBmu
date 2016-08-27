// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_emulation.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 19:27:47 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
// import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

abstract class Emulation implements Worker.AWorker {

  Async.Timer _timer_or_null;

  double _emulationSpeed = 1.0;
  double _clockDeficit;
  double _clockPerRoutineGoal;

  int _emulationCount;
  DateTime _emulationStartTime;
  DateTime _rescheduleTime;

  void _onEmulationSpeedChange(map)
  {
    Ft.log('worker_emu', '_onEmulationSpeedChange', map);
    assert(!(map['speed'] < 0), "_onEmulationSpeedChange($map)");
    if (map['isInf']) {
      _emulationSpeed = double.INFINITY;
      _clockPerRoutineGoal = double.INFINITY;
    }
    else {
      _emulationSpeed = map['speed'];
      _clockPerRoutineGoal =
        GB_CPU_FREQ_DOUBLE / EMULATION_PER_SEC_DOUBLE * _emulationSpeed;
    }
    _clockDeficit = 0.0;
  }

  void _onEmulation()
  {
    // if (_timer_or_null == null)
      // return ;
    Ft.log('worker_emu', '_onEmulation($_emulationCount)');
    assert(this.status == Status.Emulating,
        "_onEmulation() while not emulating");

    int clockSum = 0;
    int clockExec;
    final DateTime timeLimit = _rescheduleTime.add(EMULATION_PERIOD_DURATION);
    final double clockDebt = _clockPerRoutineGoal + _clockDeficit;
    final int clockLimit =
      clockDebt.isFinite ? clockDebt.floor() : double.INFINITY;

    while (true) {
      if (Ft.now().compareTo(timeLimit) >= 0)
        break ;
      if (clockSum >= clockLimit)
        break ;
      clockExec = Math.min(MAXIMUM_CLOCK_PER_EXEC_INT, clockLimit - clockSum);
      this.gb.exec(clockExec);
      clockSum += clockExec;
    }
    _clockDeficit = clockDebt - clockSum.toDouble();
    _emulationCount++;
    _rescheduleTime = _emulationStartTime.add(
        EMULATION_PERIOD_DURATION * _emulationCount);
    _timer_or_null = new Async.Timer(
        _rescheduleTime.difference(Ft.now()), _onEmulation);
    Ft.log('worker_emu', '_onEmulationDONE');
    return ;
  }

  void _onEmulationStart(Uint8List l) //TODO: Retrieve string to indexDB
  {
    var gb;

    assert(this.status != Status.Emulating,
        "_onEmulationStart() while emulating");
    try {
      gb = _assembleGameBoy(l);
    }
    catch (e) {
      this.notifyError(Event.StartError, e);
      return ;
    }
    this.registerGameBoy(gb);
    // _onStart();
    return ;
  }

  Gameboy.GameBoy _assembleGameBoy(Uint8List l) {
    final drom = l; //TODO: Retrieve from indexedDB
    final dram = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final irom = new Rom.Rom(drom);
    final iram = new Ram.Ram(dram);
    //TODO: Select right constructon giving r.pullHeader(RomHeaderField.Cartridge_Type)
    final c = new Cartmbc0.CartMbc0(irom, iram);
    return new Gameboy.GameBoy(c);
  }

  /* CONTROL **************************************************************** */

  void _onStart([_])
  {
    Ft.log('worker_emu', '_onStart');
    assert(_timer_or_null == null,
        "worker_emu: _onStart while active");
    _clockDeficit = 0.0;
    _emulationStartTime = Ft.now().add(EMULATION_START_DELAY);
    _rescheduleTime = _emulationStartTime;
    _emulationCount = 0;
    _timer_or_null = new Async.Timer(EMULATION_START_DELAY, _onEmulation);
  }

  void _onStop([_])
  {
    Ft.log('worker_emu', '_onStop');
    assert(_timer_or_null != null && _timer_or_null.isActive,
        "worker_emu: _onStop while paused");
    assert(_timer_or_null.isActive, "worker_emu: _onStop while paused");
    _timer_or_null.cancel();
    _timer_or_null = null;
  }

  void init_emulation()
  {
    Ft.log('worker_emu', 'init_emulation');
    this.events
      ..where((Map map) => map['type'] == Event.FatalError)
      .forEach(_onStop)
      ..where((Map map) => map['type'] == Event.Eject)
      .forEach((_){
            if (_timer_or_null != null)
              _onStop();
          })
      ..where((Map map) => map['type'] == Event.Start)
      .forEach(_onStart)
      ;
    this.ports.listener('EmulationStart')
      .forEach(_onEmulationStart);
    this.ports.listener('EmulationSpeed')
      .listen(_onEmulationSpeedChange);
  }

}