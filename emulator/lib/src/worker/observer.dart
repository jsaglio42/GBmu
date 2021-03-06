// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   observer.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 12:16:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 14:25:22 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/src/worker/worker.dart' as Worker;
import 'package:emulator/variants.dart' as V;

abstract class Observer implements Worker.AWorker {

  // ATTRIBUTES ************************************************************* **
  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  int _gbClockPoll;
  DateTime _pollTime;

  // CONSTRUCTION *********************************************************** **
  void init_observer()
  {
    Ft.log("WorkerObs", 'init_observer');
    _periodic = new Async.Stream.periodic(SPEEDPOLL_PERIOD_DURATION);
    _sub = _periodic.listen(_onSpeedPoll);
    _sub.pause();
    this.sc.addSideEffect(_makeLooping, _makeDormant, [
      [V.Emulating.v, PauseExternalMode.Ineffective],
    ]);
    return ;
  }

  // CALLBACKS (WORKER) ***************************************************** **
  void _onSpeedPoll([_]){
    assert(this.gbMode is V.Emulating,
        "_onSpeedPoll with no gameboy");

    final now = Ft.now();
    final elapsed =
      now.difference(_pollTime).inMicroseconds.toDouble() /
      MICROSECONDS_PER_SECOND_DOUBLE;
    final clock = this.gbOpt.clockTotal;
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

  void _makeLooping()
  {
    Ft.log("WorkerObs", '_makeLooping');
    assert(_sub.isPaused, "worker_obs: _makeLooping while not paused");
    _gbClockPoll = 0;
    _pollTime = Ft.now();
    _sub.resume();
  }

  void _makeDormant()
  {
    Ft.log("WorkerObs", '_makeDormant');
    assert(!_sub.isPaused, "worker_obs: _makeDormant while paused");
    _sub.pause();
    this.ports.send('EmulationSpeed', <String, dynamic>{
      'speed': 0.0,
    });
  }

}
