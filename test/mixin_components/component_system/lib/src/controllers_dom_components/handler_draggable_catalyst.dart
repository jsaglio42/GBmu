// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_draggable_catalyst.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 17:04:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/07 14:49:46 by ngoguey          ###   ########.fr       //
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
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  List<HtmlDropZone> _enabledOpt;

  // CONSTRUCTION *********************************************************** **
  HandlerDraggableCatalyst(this._pde, this._pce, this._pdcs) {
    Ft.log('HandlerDraggableCatalyst', 'contructor');

    // TODO: Listen chips creations / ?deletions?
    // TODO: Enable all chips in chip sockets
    // TODO: Disable all chips in chip sockets
    _pce.onCartEvent.forEach(_onCartEvent);
    _pce.onChipEvent.forEach(_onChipEvent);
  }

  // CALLBACKS ************************************************************** **
  void _onCartEvent(CartEvent<DomCart> ev) {
    if (ev.isClose || ev.isDeleteOpened
        || ev.isDeleteGameBoy || ev.isUnloadClosed)
        ev.cart.hdr_disable();
    else if (ev.isOpen)
      ev.cart.hdr_enable();
  }

  void _onChipEvent(ChipEvent<DomChip, DomCart> ev) {
    DomCart dc, dc2;
    bool isOpenedOrGb(DomCart c) =>
      _pdcs.gbCart.v == c || _pdcs.openedCart.v == c;
    DomCart cart() => (ev as ChipEventCart<DomChip, DomCart>).cart;
    DomCart cartNew() => (ev as ChipEventCart2<DomChip, DomCart>).newCart;
    DomCart cartOld() => (ev as ChipEventCart2<DomChip, DomCart>).oldCart;

    if (ev.isNewDetached)
      _updateChipState(ev.chip, false, true);
    else if (ev.isAttach)
      _updateChipState(ev.chip, true, isOpenedOrGb(cart()));
    else if (ev.isMoveAttach)
      _updateChipState(ev.chip, isOpenedOrGb(cartOld()), isOpenedOrGb(cartNew()));
    else if (ev.isDetach)
      _updateChipState(ev.chip, isOpenedOrGb(cart()), true);
    else if (ev.isNewAttached)
      _updateChipState(ev.chip, false, isOpenedOrGb(cart()));
  }

  // PRIVATE **************************************************************** **
  void _updateChipState(DomChip c, bool oldActive, bool newActive) {
    if (oldActive && !newActive)
      c.hdr_disable();
    else if (!oldActive && newActive)
      c.hdr_enable();
  }

}
