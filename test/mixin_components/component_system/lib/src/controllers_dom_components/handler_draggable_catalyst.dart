// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_draggable_catalyst.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 17:04:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/01 17:53:06 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerDraggableCatalyst {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomComponentStorage _pdcs;
  // final PlatformTopLevelBanks _ptlb;
  final PlatformComponentEvents _pce;
  // final PlatformDomEvents _pde;

  List<HtmlDropZone> _enabledOpt;

  // CONSTRUCTION *********************************************************** **
  static HandlerDraggableCatalyst _instance;

  factory HandlerDraggableCatalyst(pdcs, pce) {
    if (_instance == null)
      _instance = new HandlerDraggableCatalyst._(pdcs, pce);
    return _instance;
  }

  HandlerDraggableCatalyst._(this._pdcs, this._pce) {
    Ft.log('HandlerDraggableCatalyst', 'contructor');

    // TODO: Listen chips creations / ?deletions?
    // TODO: Enable all chips in chip sockets
    // TODO: Disable all chips in chip sockets
    _pce.onOpenedCartChange.forEach(_onOpenedCartChange);
    _pce.onGbCartChange.forEach(_onGbCartChange);
  }

  // CALLBACKS ************************************************************** **
  void _onOpenedCartChange(SlotEvent<DomCart> ev) {
    if (ev.type is Arrival) {
      ev.value.hdr_enable();
    }
    else {
      if (ev.value != _pdcs.gbCart.v)
        ev.value.hdr_disable();
    }
  }

  void _onGbCartChange(SlotEvent<DomCart> ev) {
    if (ev.type is Arrival) {
      // ev.value.hdr_enable();
    }
    else {
      // if (ev.value != _pdcs.gbCart.v)
      ev.value.hdr_disable();
    }
  }

  // PRIVATE **************************************************************** **

}
