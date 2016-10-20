// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation_state.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/13 11:01:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 11:09:35 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:js' as Js;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';

import 'package:emulator/src/worker/worker.dart' as Worker;
import 'package:emulator/src/gameboy.dart' as Gameboy;
import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/src/emulator.dart' show RequestEmuStart;
import 'package:emulator/variants.dart' as V;

abstract class EmulationState implements Worker.AWorker {

  void es_gbCrash(String msg, String st) {
    this.sc.setState(V.Crashed.v);
    this.ports.send('Events', <String, dynamic>{
      'type': V.Crash.v,
      'msg': msg,
      'st': st,
    });
  }

  void es_startFailure(String msg, String st) {
    V.EmulatorEvent ev;

    if (this.gbMode is V.Absent)
      ev = V.StartError.v;
    else if (this.gbMode is V.Crashed) {
      ev = V.CrashedRestartError.v;
      this.sc.setState(V.Absent.v);
    }
    else /* if (this.gbMode is V.Emulating) */ {
      ev = V.EmulatingRestartError.v;
      this.sc.setState(V.Absent.v);
    }
    this.ports.send('Events', <String, dynamic>{
      'type': ev,
      'msg': msg,
      'st': st,
    });
  }

  void es_startSuccess(Gameboy.GameBoy gb) {
    V.EmulatorEvent ev;

    this.gbOpt = gb;
    if (this.gbMode is V.Absent) {
      this.sc.setState(V.Emulating.v);
      ev = V.Start.v;
    }
    else if (this.gbMode is V.Crashed) {
      this.sc.setState(V.Emulating.v);
      ev = V.CrashedRestart.v;
    }
    else /* if (this.gbMode is V.Emulating) */
      ev = V.EmulatingRestart.v;
    this.ports.send('Events', <String, dynamic>{
      'type': ev,
      'name': gb.c.rom.fileName,
    });
  }

  void es_eject(String name) {
    V.EmulatorEvent ev;
    final Gameboy.GameBoy gb = this.gbOpt;

    this.gbOpt = null;
    if (this.gbMode is V.Emulating)
      ev = V.EmulatingEject.v;
    else if (this.gbMode is V.Crashed)
      ev = V.CrashedEject.v;
    else
      assert(false);
    this.sc.setState(V.Absent.v);
    this.ports.send('Events', <String, dynamic>{
      'type': ev,
      'name': gb.c.rom.fileName,
    });
  }

}
