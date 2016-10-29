// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation_timings_cpu.dart                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/29 18:19:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 18:46:28 by ngoguey          ###   ########.fr       //
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

abstract class EmulationTimingsCpu implements Worker.AWorker
{

  // ATTRIBUTES ************************************************************* **
  double _rate;
  double _clockPerCycleGoal;

  double _clockDeficit;
  double _clockDebt;
  int _cycleClockLimit;

  // PUBLIC ***************************************************************** **
  void etc_setRate(double rate) {
    assert(!(rate.isNegative), "from: etc_setRate($rate)");
    if (rate.isFinite) {
      _rate = rate;
      _clockPerCycleGoal =
        GB_CPU_FREQ_DOUBLE / et_cyclesPerSec_double * rate;
    }
    else {
      _rate = double.INFINITY;
      _clockPerCycleGoal = double.INFINITY;
    }
    etc_reset();
  }

  void etc_reset() {
    assert(_rate != null);
    _clockDeficit = 0.0;
    _clockDebt = null;
    _cycleClockLimit = null;
  }

  void etc_advance() {
    _clockDebt = _clockPerCycleGoal + _clockDeficit;
    _cycleClockLimit = _clockLimitOfClockDebt(_clockDebt);
  }

  void etc_postAdvance(int clockElapsed) {
    _clockDeficit = _clockDebt - clockElapsed.toDouble();
  }

  int get etc_cycleClockLimit {
    return _cycleClockLimit;
  }

  // SUBROUTINES ************************************************************ **
  int _clockLimitOfClockDebt(double clockDebt)
  {
    if (ep_limitedEmulation)
      return ep_autoBreakIn;
    else if (clockDebt.isInfinite)
      return MAX_INT_LOLDART;
    else
      return clockDebt.floor();
  }

}
