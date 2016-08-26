// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_emulation.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/26 11:47:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/26 13:02:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:ft/wired_isolate.dart' as Wiso;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/memory/rom.dart' as Rom;
import 'package:emulator/src/memory/ram.dart' as Ram;
import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

DateTime now() => new DateTime.now();

abstract class Emulation implements Worker.AWorker {

  bool _pause = false; // TODO: init elsewhere
  double _emulationSpeed = 1.0 / GB_CPU_FREQ_DOUBLE * 2.0; // TODO: init elsewhere
  double _clockDeficit;
  double _clockPerRoutineGoal;

  int _emulationCount;
  DateTime _emulationStartTime;
  Async.Timer _emulationTimer;
  DateTime _rescheduleTime;

  void onEmulationSpeedChange(map)
  {
    print('worker:\tonEmulationSpeedChange($map)');
    assert(!(map['speed'] < 0));
    if (map['isInf']) {
      _emulationSpeed = double.INFINITY;
      _clockPerRoutineGoal = double.INFINITY;
    }
    else {
      _emulationSpeed = map['speed'];
      _clockPerRoutineGoal =
        GB_CPU_FREQ_DOUBLE / EMULATION_PER_SEC_DOUBLE * _emulationSpeed;
    }
    print('goal: $_clockPerRoutineGoal,  speed: $_emulationSpeed');
    _clockDeficit = 0.0;
  }

  void onEmulation()
  {
    int clockSum = 0;
    int clockExec;
    final DateTime timeLimit = _rescheduleTime.add(EMULATION_PERIOD_DURATION);
    final double clockDebt = _clockPerRoutineGoal + _clockDeficit;
    final int clockLimit =
      clockDebt.isFinite ? clockDebt.floor() : double.INFINITY;

    // print('emu#$_emulationCount ');
    if (_pause)
      _clockDeficit = 0.0;
    else {
      while (true) {
        if (now().compareTo(timeLimit) >= 0)
          break ;
        if (clockSum >= clockLimit)
          break ;
        clockExec = Math.min(MAXIMUM_CLOCK_PER_EXEC_INT, clockLimit - clockSum);
        this.gb.data.exec(clockExec);
        clockSum += clockExec;
      }
      _clockDeficit = clockDebt - clockSum.toDouble();
    }
    _emulationCount++;
    _rescheduleTime = _emulationStartTime.add(
        EMULATION_PERIOD_DURATION * _emulationCount);
    _emulationTimer =
      new Async.Timer(_rescheduleTime.difference(now()), onEmulation);
    return ;
  }

  void _onEmulationStart(Uint8List l)
  {
    final drom = l; //TODO: Retrieve from indexedDB
    final dram = new Uint8List.fromList([42, 43]); //TODO: Retrieve from indexedDB
    final irom = new Rom.Rom(drom);
    final iram = new Ram.Ram(dram);

    //TODO: Select right constructon giving r.pullHeader(RomHeaderField.Cartridge_Type)
    // and try catch to detect errors;
    final c = new Cartmbc0.CartMbc0(irom, iram);
    this.gb = new Ft.Option<Gameboy.GameBoy>.some(new Gameboy.GameBoy(c));
    _clockDeficit = 0.0;
    _emulationStartTime = now().add(EMULATION_START_DELAY);
    _rescheduleTime = _emulationStartTime;;
    _emulationCount = 0;
    _emulationTimer =
      new Async.Timer(EMULATION_START_DELAY, onEmulation);
    return ;
  }

  void init_emulation()
  {
    this.ports.listener('EmulationStart').listen(_onEmulationStart);
    this.ports.listener('EmulationSpeed').listen(onEmulationSpeedChange);
  }


}