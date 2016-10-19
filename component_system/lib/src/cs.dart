// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cs.dart                                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/19 16:49:58 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 18:02:25 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import 'package:component_system/src/include_cs.dart';
// import 'package:component_system/src/include_ccs.dart';
// import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

import 'package:emulator/enums.dart';

enum KeyboardAction {
  Load1,
  Load2,
  Load3,
  Load4,
  Save1,
  Save2,
  Save3,
  Save4,
}

const Map<int, KeyboardAction> g_keyMapping = const <int, KeyboardAction>{
  112 : KeyboardAction.Load1,
  113 : KeyboardAction.Load2,
  114 : KeyboardAction.Load3,
  115 : KeyboardAction.Load4,
  116 : KeyboardAction.Save1,
  117 : KeyboardAction.Save2,
  118 : KeyboardAction.Save3,
  119 : KeyboardAction.Save4,
};

class Cs {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformChip _pch;

  // CONTRUCTION ************************************************************ **
  Cs(this._pde, this._pch) {
    Ft.log('Cs', 'contructor');
  }

  // PUBLIC ***************************************************************** **
  void key(KeyboardAction a) {
    switch (a) {
      case (KeyboardAction.Load1): _pch.installSs(0); break;
      case (KeyboardAction.Load2): _pch.installSs(1); break;
      case (KeyboardAction.Load3): _pch.installSs(2); break;
      case (KeyboardAction.Load4): _pch.installSs(3); break;
      case (KeyboardAction.Save1): _pch.extractSs(0); break;
      case (KeyboardAction.Save2): _pch.extractSs(1); break;
      case (KeyboardAction.Save3): _pch.extractSs(2); break;
      case (KeyboardAction.Save4): _pch.extractSs(3); break;
    }
  }

  // CALLBACKS **************************************************************

}