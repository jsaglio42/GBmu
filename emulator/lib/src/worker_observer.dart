// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   worker_observer.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 12:16:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/27 19:28:23 by ngoguey          ###   ########.fr       //
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

  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  int _gbClockPoll;
  DateTime _pollTime;

  void _onSpeedPoll(_){
    assert(this.status == Status.Emulating,
        '_onSpeedPoll while ${this.status}');
    final now = Ft.now();
    final elapsed =
      now.difference(_pollTime).inMicroseconds.toDouble() /
      MICROSECONDS_PER_SECOND_DOUBLE;
    final clock = this.gb.clockCount;
    final cps =
      (clock - _gbClockPoll).toDouble() / elapsed;
    final observedSpeed = cps / GB_CPU_FREQ_DOUBLE;

    _pollTime = now;
    this.ports.send('EmulationSpeed', <String, dynamic>{
      'speed': observedSpeed,
    });
    _gbClockPoll = clock;
    return ;
  }

  /* CONTROL **************************************************************** */

  void _onStop(_) {
    Ft.log('worker_obs', '_onStop');
    assert(!_sub.isPaused, "worker_obs: _onStop while paused");
    _sub.pause();
    this.ports.send('EmulationSpeed', <String, dynamic>{
      'speed': 0.0,
    });
  }

  void _onStart(_) {
    Ft.log('worker_obs', '_onStart');
    assert(_sub.isPaused, "worker_obs: _onStop while not paused");
    _gbClockPoll = 0;
    _pollTime = Ft.now();
    _sub.resume();
  }

  void init_observer()
  {
    Ft.log('worker_obs', 'init_observer');
    _periodic = new Async.Stream.periodic(SPEEDPOLL_PERIOD_DURATION);
    _sub = _periodic.listen(_onSpeedPoll);
    _sub.pause();
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
    return ;
  }

}