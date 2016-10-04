// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_draggable_catalyst.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 17:04:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/04 19:03:28 by ngoguey          ###   ########.fr       //
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
  final PlatformCart _pc;
  final PlatformComponentEvents _pce;

  List<HtmlDropZone> _enabledOpt;

  // CONSTRUCTION *********************************************************** **
  HandlerDraggableCatalyst(this._pc, this._pce) {
    Ft.log('HandlerDraggableCatalyst', 'contructor');

    // TODO: Listen chips creations / ?deletions?
    // TODO: Enable all chips in chip sockets
    // TODO: Disable all chips in chip sockets
    _pce.onCartEvent.forEach(_onCartEvent);
  }

  // CALLBACKS ************************************************************** **
  void _onCartEvent(CartEvent<DomCart> ev) {
    if (ev.isClose || ev.isDeleteOpened
        || ev.isDeleteGameBoy || ev.isUnloadClosed)
        ev.cart.hdr_disable();
    else if (ev.isOpen)
      ev.cart.hdr_enable();
  }

  // PRIVATE **************************************************************** **

}
