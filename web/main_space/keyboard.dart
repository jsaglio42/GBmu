// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   keyboard.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:37:10 by jsaglio           #+#    #+#             //
//   Updated: 2016/09/28 11:50:31 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

import 'package:emulator/enums.dart';

import 'package:emulator/emulator.dart' as Emulator;

Emulator.Emulator _emu;

void init(Emulator.Emulator emu) {
  _emu = emu;
  Html.window.onKeyDown
    .listen((keyEvent) => _onKeyDown(keyEvent.keyCode));
  Html.window.onKeyUp
    .listen((keyEvent) => _onKeyUp(keyEvent.keyCode));
  return ;
}

Map<int, JoypadKey> keySettings = <int, JoypadKey>{
  75 : JoypadKey.A,
  76 : JoypadKey.B,
  16 : JoypadKey.Select,
  13 : JoypadKey.Start,
  68 : JoypadKey.Right,
  65 : JoypadKey.Left,
  87 : JoypadKey.Up,
  83 : JoypadKey.Down
};

/* Private ********************************************************************/
/* Store the status of button: (false = released, true = pressed) */
Map<JoypadKey, bool> _keyState = <JoypadKey, bool>{
  JoypadKey.A : false,
  JoypadKey.B : false,
  JoypadKey.Select : false,
  JoypadKey.Start : false,
  JoypadKey.Right : false,
  JoypadKey.Left : false,
  JoypadKey.Up : false,
  JoypadKey.Down : false
};

void _onKeyDown(int eventKeyCode){
  JoypadKey key = keySettings[eventKeyCode];
  if (key == null || _keyState[key] == true)
    return ;
  _keyState[key] = true;
  _emu.send('KeyDownEvent', key);
  return ;
}

void _onKeyUp(int eventKeyCode){
  JoypadKey key = keySettings[eventKeyCode];
  if (key == null || _keyState[key] == false)
    return ;
  _keyState[key] = false;
  _emu.send('KeyUpEvent', key);
  return ;
}
