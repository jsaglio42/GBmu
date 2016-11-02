// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   key_mapping.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 14:05:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 19:28:25 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library key_mapping;

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'dart:async' as Async;
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;
import 'package:component_system/cs.dart' as Cs;
import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

part './key.dart';
part './key_map.dart';
part './joypad_key.dart';
part './store_events.dart';
part './store_mappings.dart';
part './platform_mapper.dart';
part './platform_activator.dart';
part './handler_keyboard.dart';
part './builder_dom.dart';

// CONSTANTS **************************************************************** **

// VARIABLES **************************************************************** **

// CONSTRUCTION ************************************************************* **
void init(Emulator.Emulator emu) {
  Ft.log('key_mapping.dart', 'init', [emu]);

  final StoreEvents se = new StoreEvents();
  final StoreMappings sm = new StoreMappings();
  final PlatformMapper pm = new PlatformMapper(se, sm);
  final PlatformActivator pa = new PlatformActivator(sm);

  new HandlerKeyboard(pm, pa);

  new BuilderDom(emu, se, sm);

}


// CALLBACKS **************************************************************** **
void onOpen() {

}

void onClose() {

}

// PRIVATE ****************************************************************** **
