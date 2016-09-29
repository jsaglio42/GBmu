// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   framescheduler.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 12:16:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 10:50:25 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/src/worker.dart' as Worker;

abstract class FrameScheduler implements Worker.AWorker {

  Async.Stream _periodic;
  Async.StreamSubscription _sub;

  // LOOPING ROUTINE ******************************************************** **
  void _onFrameUpdate([_]){
    assert(this.gbMode == GameBoyExternalMode.Emulating,
        "_onFrameUpdate with no gameboy");
    this.ports.send('FrameUpdate', this.gbOpt.lcdScreen);
    return ;
  }

  // SIDE EFFECTS CONTROLS ************************************************** **
  void _makeLooping()
  {
    Ft.log(Ft.typeStr(this), '_makeLooping');
    assert(_sub.isPaused, "FrameScheduler: _makeLooping while not paused");
    _sub.resume();
  }

  void _makeDormant()
  {
    Ft.log(Ft.typeStr(this), '_makeDormant');
    assert(!_sub.isPaused, "FrameScheduler: _makeDormant while paused");
    _sub.pause();
    this.ports.send('FrameUpdate', this.gbOpt.lcdScreen);
  }

  // CONSTRUCTION *********************************************************** **

  void init_framescheduler()
  {
    Ft.log(Ft.typeStr(this), 'init_FrameScheduler');
    _periodic = new Async.Stream.periodic(FRAME_PERIOD_DURATION);
    _sub = _periodic.listen(_onFrameUpdate);
    _sub.pause();
    this.sc.addSideEffect(_makeLooping, _makeDormant, [
      [GameBoyExternalMode.Emulating, DebuggerExternalMode.Dismissed],
      [GameBoyExternalMode.Emulating, DebuggerExternalMode.Operating,
        PauseExternalMode.Ineffective],
    ]);
    return ;
  }

  // EXTERNAL INTERFACE ***************************************************** **
  // none

  // SECONDARY ROUTINES ***************************************************** **
  // none

}
