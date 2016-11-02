// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   key_mapping.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 14:05:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 15:34:13 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library key_mapping;

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'dart:convert';
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

part './key.dart';
part './joypad_key.dart';

// CONSTANTS **************************************************************** **

// VARIABLES **************************************************************** **
Emulator.Emulator _emu;

// CONSTRUCTION ************************************************************* **

void init(Emulator.Emulator emu) {
  Ft.log('key_mapping.dart', 'init', [emu]);

  _emu = emu;
  print(joypadInfo);

}


// CALLBACKS **************************************************************** **
void onOpen() {

}

void onClose() {

}

// PRIVATE ****************************************************************** **
