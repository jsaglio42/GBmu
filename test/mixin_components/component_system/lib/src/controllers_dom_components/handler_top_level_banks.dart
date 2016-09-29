// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_top_level_banks.dart                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 15:52:34 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 16:12:52 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerTopLevelBanks {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentEvents _pce;
  final PlatformDomEvents _pde;

  final DomGameBoySocket _dgbs;

  // CONTRUCTION ************************************************************ **
  static HandlerTopLevelBanks _instance;

  factory HandlerTopLevelBanks(pde, pce) {
    if (_instance == null)
      _instance = new HandlerTopLevelBanks._(pde, pce);
    return _instance;
  }

  HandlerTopLevelBanks._(pde, pce) {
    Ft.log('HandlerTLB', 'contructor');
  }

  // PUBLIC ***************************************************************** **
  DomGameBoySocket get dgbs => _dgbs;

  // CALLBACKS ************************************************************** **

}