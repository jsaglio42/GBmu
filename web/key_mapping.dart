// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   key_mapping.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 14:05:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 14:23:10 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

// CONSTANTS **************************************************************** **

// VARIABLES **************************************************************** **
Emulator.Emulator _emu;

// CONSTRUCTION ************************************************************* **

void init(Emulator.Emulator emu) {
  Ft.log('key_mapping.dart', 'init', [emu]);

  _emu = emu;

}


// CALLBACKS **************************************************************** **
void onOpen() {

}

void onClose() {

}
