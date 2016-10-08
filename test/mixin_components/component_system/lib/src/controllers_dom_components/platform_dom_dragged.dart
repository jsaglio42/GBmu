// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_dragged.dart                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/04 19:04:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/08 13:10:29 by ngoguey          ###   ########.fr       //
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

//TODO: Rename `Handler`
class PlatformDomDragged {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  // CONSTRUCTION *********************************************************** **
  PlatformDomDragged(this._pde, this._pce, this._pdcs) {
    Ft.log('PlatformDomDragged', 'contructor');

    _pde.onDragStart.forEach(_onDragStart);
    _pde.onDragStop.forEach(_onDragStop);
    _pce.onCartEvent
      .where((ev) => ev.cart == _pdcs.dragged.v)
      .forEach(_handleDraggedCartEvent);
    _pce.onChipEvent
      .where((ev) => ev.chip == _pdcs.dragged.v)
      .forEach(_handleDraggedChipEvent);
  }

  // CALLBACKS ************************************************************** **
  void _onDragStart(HtmlDraggable that) {
    assert(_pdcs.dragged.isNone, "from: _onDragStart");
    _pdcs.dragged = that as DomComponent;
    _pce.draggedChange(
        new SlotEvent<DomComponent>.Arrival(that as DomComponent));
  }

  void _onDragStop(HtmlDraggable that) {
    assert(_pdcs.dragged.isSome, "from: _onDragStop");
    _pce.draggedChange(new SlotEvent<DomComponent>.Dismissal(_pdcs.dragged.v));
    _pdcs.unsetDragged();
  }

  void _handleDraggedCartEvent(CartEvent<DomCart> ev) {
    Ft.log('PlatformDomDragged', '_handleDraggedCartEvent', [ev]);

    if (ev.isNew || ev.isOpen || ev.isClose)
      assert(false, 'from: _handleDraggedCartEvent, impossible');
    else {
      ev.cart.hdr_abort();
      _pce.draggedChange(new SlotEvent<DomComponent>.Dismissal(ev.cart));
      _pdcs.unsetDragged();
    }
  }

  void _handleDraggedChipEvent(ChipEvent<DomChip, DomCart> ev) {
    Ft.log('PlatformDomDragged', '_handleDraggedChipEvent', [ev]);

    if (ev.isNewAttached || ev.isNewDetached)
      assert(false, 'from: _handleDraggedChipEvent, impossible');
    else {
      ev.chip.hdr_abort();
      _pce.draggedChange(new SlotEvent<DomComponent>.Dismissal(ev.chip));
      _pdcs.unsetDragged();
    }
  }


}
