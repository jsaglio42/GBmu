// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   keyboard.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/25 12:10:43 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;
import 'package:component_system/cs.dart' as Cs;

Emulator.Emulator _emu;
Cs.Cs _cs;

// Private ****************************************************************** **
/* Store the status of button: (false = released, true = pressed) */
Map<int, dynamic> _keySettings = <int, dynamic>{
  75 : JoypadKey.A,
  76 : JoypadKey.B,
  16 : JoypadKey.Select,
  13 : JoypadKey.Start,
  70 : JoypadKey.Right,
  83 : JoypadKey.Left,
  69 : JoypadKey.Up,
  68 : JoypadKey.Down,
}
  ..addAll(Cs.g_keyMapping);

Map<dynamic, int> _reverseKeySettings;

Map<JoypadKey, bool> _keyState = new Map<dynamic, bool>.fromIterable(
    _keySettings.values.where((v) => v is JoypadKey),
    key:(v) => v, value: (_) => false);

// ************************************************************************** **

void _updateRevMap() {
  _reverseKeySettings = new Map<dynamic, int>.fromIterables(
      _keySettings.values, _keySettings.keys);
}

void _onKeyDown(Html.KeyboardEvent ev){
  final int eventKeyCode = ev.keyCode;
  final key = _keySettings[eventKeyCode];

  if (key != null) {
    if (key is JoypadKey && _keyState[key] == false) {
      _keyState[key] = true;
      _emu.send('KeyDownEvent', key);
    }
    ev.preventDefault();
  }
  return ;
}

void _onKeyUp(Html.KeyboardEvent ev){
  final int eventKeyCode = ev.keyCode;
  final key = _keySettings[eventKeyCode];

  if (key != null) {
    if (key is JoypadKey) {
      if (_keyState[key] == true) {
        _keyState[key] = false;
        _emu.send('KeyUpEvent', key as JoypadKey);
      }
    }
    else /* if (key is Cs.KeyboardAction) */
      _cs.key(key as Cs.KeyboardAction);
    ev.preventDefault();
  }
  return ;
}

void _updateKey(JoypadKey k, int code) { //Unused yet
  final key = _keySettings[eventKeyCode];

  if (key != null) {
    // TODO: issue error
  }
  else {
    if (!_keySettings.removeValue(k))
      assert(false, "from: _updateKey");
    _keySettings[code] = k;
    _keyState[k] = false;
    _updateRevMap();
  }
}

// ************************************************************************** **

void init(Emulator.Emulator emu, Cs.Cs cs) {
  _emu = emu;
  _cs = cs;
  _updateRevMap();
  Html.window.onKeyDown.forEach(_onKeyDown);
  Html.window.onKeyUp.forEach(_onKeyUp);
  return ;
}
