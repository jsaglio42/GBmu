// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_dom_component_nodes.dart                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/07 16:30:42 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/07 16:48:05 by ngoguey          ###   ########.fr       //
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

class HandlerDomComponentNodes {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  // CONTRUCTION ************************************************************ **
  HandlerDomComponentNodes(this._pde, this._pce, this._pdcs) {
    Ft.log('HandlerDCN', 'contructor');

    _pce.onCartEvent.forEach(_handleCartEvent);
    _pce.onChipEvent.forEach(_handleChipEvent);
  }

  // CALLBACKS ************************************************************** **
  void _handleCartEvent(CartEvent<DomCart> ev) {
    Ft.log('HandlerDCN', '_handleCartEvent', [ev]);
    if (ev.isMove) {
      ev.cart.elt.style.left = '0px';
      ev.cart.elt.style.top = '0px';
    }
    if (ev.isNew || ev.isUnload)
      _pdcs.cartBank.elt.nodes.add(ev.cart.elt);
    else if (ev.isLoad)
      _pdcs.gbSocket.elt.nodes = [ev.cart.elt];
    else if (ev.isDeleteOpened || ev.isDeleteClosed)
      _pdcs.cartBank.elt.nodes.remove(ev.cart.elt);
    else if (ev.isDeleteGameBoy)
      _pdcs.gbSocket.elt.nodes = [];
    // else: Don't act on Open & Close
  }

  void _handleChipEvent(ChipEvent<DomChip, DomCart> ev) {
    final LsChip chdata = ev.chip.data as LsChip;
    DomCart ca;
    DomChipSocket s;

    Ft.log('HandlerDCN', '_handleChipEvent', [ev]);
    if (ev.isMove) {
      ev.chip.elt.style.left = '0px';
      ev.chip.elt.style.top = '0px';
    }
    if (ev.isNewDetached || ev.isDetach)
      _pdcs.chipBank.elt.nodes.add(ev.chip.elt);
    else if (ev.isDeleteDetached)
      _pdcs.chipBank.elt.nodes.remove(ev.chip.elt);
    else {
      ca = ev.isMoveAttach
        ? (ev as ChipEventCart2<DomChip, DomCart>).newCart
        : (ev as ChipEventCart<DomChip, DomCart>).cart;
      s = chdata.type is Ram
        ? ca.ramSocket
        : ca.ssSocket(chdata.slot.v);
      if (ev.isNewAttached || ev.isMoveAttach || ev.isAttach)
        s.elt.nodes.add(ev.chip.elt);
      else if (ev.isDeleteAttached)
        s.elt.nodes.remove(ev.chip.elt);
    }
  }

}