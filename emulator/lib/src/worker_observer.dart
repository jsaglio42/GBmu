// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_observer.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 12:16:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 12:26:18 by ngoguey          ###   ########.fr       //
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
// import 'package:emulator/src/memory/mem_registers.dart' as Memregisters;
// import 'package:emulator/src/memory/cartmbc0.dart' as Cartmbc0;
// import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/worker.dart' as Worker;

abstract class Observer implements Worker.AWorker {

  Async.Timer _speedPollTimer;
  int _gbClockPoll = 0;

  void _onSpeedPoll(_){
    if (this.gb.isSome) {
      final clock = this.gb.data.clockCount;
      final cps =
        (clock - _gbClockPoll).toDouble() / SPEEDPOLL_PERIOD_DOUBLE;
      final observedSpeed = cps / GB_CPU_FREQ_DOUBLE;

      this.ports.send('EmulationSpeed', <String, dynamic>{
        'speed': observedSpeed,
      });
      _gbClockPoll = clock;
    }
  }

  void init_observer()
  {
    _speedPollTimer =
      new Async.Timer.periodic(SPEEDPOLL_PERIOD_DURATION, _onSpeedPoll);
  }

}