// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation_timings.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/29 16:45:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 17:56:17 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/src/worker/worker.dart' as Worker;

// import 'package:emulator/src/GameBoyDMG/gameboy.dart' as Gameboy;

// import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
// import 'package:emulator/src/hardware/data.dart' as Data;
// import 'package:emulator/src/emulator.dart' show RequestEmuStart;
import 'package:emulator/variants.dart' as V;

abstract class EmulationTimings implements Worker.AWorker
{

  // ATTRIBUTES ************************************************************* **
  double _cyclesPerSec_double;
  double _cyclePeriod_double;
  Duration _cyclePeriod_duration;

  DateTime _firstCycleTime;
  int _emulationOrdinal;
  DateTime _cycleTimeLimit;

  DateTime _rescheduleTime;

  // PUBLIC ***************************************************************** **
  void et_setCyclesPerSec(double cps) {
    _cyclesPerSec_double = cps;
    _cyclePeriod_double = 1.0 / cps;
    _cyclePeriod_duration = new Duration(microseconds:
        (_cyclePeriod_double * MICROSECONDS_PER_SECOND_DOUBLE + 0.5) ~/ 1);
  }

  double get et_cyclesPerSec_double {
    return _cyclesPerSec_double;
  }

  void et_reset() {
    assert(_cyclesPerSec_double != null);
    _firstCycleTime = Ft.now().add(EMULATION_START_DELAY);
    _rescheduleTime = _firstCycleTime;
    _emulationOrdinal = 0;
  }

  void et_advance() {
    _emulationOrdinal++;
    _cycleTimeLimit = _rescheduleTime.add(_cyclePeriod_duration);
    _rescheduleTime = _firstCycleTime.add(
        _cyclePeriod_duration * _emulationOrdinal);
  }

  DateTime get et_cycleTimeLimit {
    return _cycleTimeLimit;
  }

  Duration et_rescheduleDeltaTime() {
    final DateTime now = Ft.now();
    final Duration delta = _rescheduleTime.difference(now);

    if (delta < EMULATION_RESCHEDULE_MIN_DELAY)
      return EMULATION_RESCHEDULE_MIN_DELAY;
    else
      return delta;
  }

  // SUBROUTINES ************************************************************ **

}
