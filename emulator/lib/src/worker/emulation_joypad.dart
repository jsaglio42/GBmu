// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   emulation_joypad.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 22:02:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 10:34:41 by ngoguey          ###   ########.fr       //
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
import 'package:emulator/src/events.dart';

import 'package:emulator/src/worker/worker.dart' as Worker;

import 'package:emulator/src/mixins/gameboy.dart' as Gameboy;

import 'package:emulator/src/cartridge/cartridge.dart' as Cartridge;
import 'package:emulator/src/hardware/data.dart' as Data;
import 'package:emulator/variants.dart' as V;

abstract class EmulationJoypad implements Worker.AWorker {

  // ATTRIBUTES ************************************************************* **
  Map<JoypadKey, int> _actions = <JoypadKey, int>{};
  Set<JoypadKey> _spamming = new Set<JoypadKey>();
  int _tap_cycle_count;

  // CONSTRUCTION *********************************************************** **
  void ej_init() {
    this.ports
      ..listener('RequestJoypad').forEach(_onRequestJoypad);
    ej_onFpsUpdate();
  }

  // CALLBACKS (DOM) ******************************************************** **
  void _onRequestJoypad(RequestJoypad evRaw) {
    final RequestJoypad ev = new RequestJoypad.copy(evRaw);

    switch (ev.type) {
      case (JoypadActionType.PressRelease):
        if (this.gbMode is V.Emulating) {
          if (ev.press)
            this.gbOpt.keyPress(ev.key);
          else
            this.gbOpt.keyRelease(ev.key);
        }
        break;
      case (JoypadActionType.Tap):
        if (!_actions.containsKey(ev.key))
          _actions[ev.key] = _tap_cycle_count;
        break;
      case (JoypadActionType.SpamToggle):
        if (_spamming.contains(ev.key)) {
          _spamming.remove(ev.key);
          this.ports.send(
              'JoypadSpamState', new EventSpamUpdate(ev.key, false));
        }
        else {
          _spamming.add(ev.key);
          this.ports.send(
              'JoypadSpamState', new EventSpamUpdate(ev.key, true));
          if (!_actions.containsKey(ev.key))
            _actions[ev.key] = 1;
        }
        break;
    }
  }

  // PUBLIC ***************************************************************** **
  void ej_onFpsUpdate() {
    final double count_double =
      TAP_MINIMUM_SEC_DOUBLE * et_cyclesPerSec_double;

    _tap_cycle_count = (count_double + 0.5) ~/ 1;
    _tap_cycle_count = Math.max(_tap_cycle_count, 1);
  }

  void ej_update() {
    final Map<JoypadKey, int> nextActions = <JoypadKey, int>{};

    _actions.forEach((JoypadKey key, int countdown) {
      if (countdown > 0) {
        this.gbOpt.keyPress(key);
        nextActions[key] = countdown - 1;
      }
      else {
        this.gbOpt.keyRelease(key);
        if (_spamming.contains(key))
          nextActions[key] = 1;
      }
    });
    _actions = nextActions;
  }
  // SUBROUTINES ************************************************************ **

}
