// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_dom_dragged.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/08 13:50:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 17:01:17 by ngoguey          ###   ########.fr       //
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

// http://stackoverflow.com/questions/3144881/how-do-i-detect-a-html5-drag-event-entering-and-leaving-the-window-like-gmail-d

class HandlerDomDragged {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  int _docCount = 0;
  int _cartSystemCount = 0;

  // CONSTRUCTION *********************************************************** **
  HandlerDomDragged(this._pde, this._pce, this._pdcs) {
    final Html.Element cartSystem = Html.querySelector('#row-cartsystem');

    Ft.log('HandlerDomDragged', 'contructor');

    _pde.onDragStart.forEach(_onDragStart);
    _pde.onDragStop.forEach(_onDragStop);
    _pce.onCartEvent
      .where((ev) => ev.cart == _pdcs.dragged.v)
      .forEach(_handleDraggedCartEvent);
    _pce.onChipEvent
      .where((ev) => ev.chip == _pdcs.dragged.v)
      .forEach(_handleDraggedChipEvent);

    Html.document.onDragEnter.forEach(_handleDocEnter);
    Html.document.onDragLeave.forEach(_handleDocLeave);
    Html.document.onDragOver.forEach(_handleDocOver);
    Html.document.onDrop.forEach(_handleDocDrop);

    cartSystem.onDragEnter.forEach(_handleCartSystemEnter);
    cartSystem.onDragLeave.forEach(_handleCartSystemLeave);
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
    Ft.log('HandlerDomDragged', '_handleDraggedCartEvent', [ev]);

    if (ev.isNew || ev.isOpen || ev.isClose)
      assert(false, 'from: _handleDraggedCartEvent, impossible');
    else {
      ev.cart.hdr_abort();
      _pce.draggedChange(new SlotEvent<DomComponent>.Dismissal(ev.cart));
      _pdcs.unsetDragged();
    }
  }

  void _handleDraggedChipEvent(ChipEvent<DomChip, DomCart> ev) {
    Ft.log('HandlerDomDragged', '_handleDraggedChipEvent', [ev]);

    if (ev.isNewAttached || ev.isNewDetached)
      assert(false, 'from: _handleDraggedChipEvent, impossible');
    else {
      ev.chip.hdr_abort();
      _pce.draggedChange(new SlotEvent<DomComponent>.Dismissal(ev.chip));
      _pdcs.unsetDragged();
    }
  }

  // FILE HANDLING ********************************************************** **
  void _handleDocEnter(Html.MouseEvent ev) {
    if (_docCount == 0)
      _actionFileDrag(true);
    _docCount++;
  }

  void _handleDocLeave(Html.MouseEvent ev) {
    _docCount--;
    if (_docCount == 0)
      _actionFileDrag(false);
  }

  void _handleDocOver(Html.MouseEvent ev) {
    ev.stopPropagation();
    ev.preventDefault();
  }

  void _handleCartSystemEnter(Html.MouseEvent ev) {
    if (_cartSystemCount == 0)
      _actionCartSystemHover(true);
    _cartSystemCount++;
  }

  void _handleCartSystemLeave(Html.MouseEvent ev) {
    _cartSystemCount--;
    if (_cartSystemCount == 0)
      _actionCartSystemHover(false);
  }

  void _handleDocDrop(Html.MouseEvent ev) {
    ev.stopPropagation();
    ev.preventDefault();
    if (_cartSystemCount > 0 && ev.dataTransfer.types.contains('Files'))
      _pde.cartSystemFilesDrop(ev.dataTransfer.files);
    _actionFileDrag(false);
    _actionCartSystemHover(false);
    _cartSystemCount = 0;
    _docCount = 0;
  }

  // PRIVATE **************************************************************** **
  void _actionCartSystemHover(bool b) {
    _pdcs.cartSystemDragHovered = b;
    _pde.cartSystemFileHover(b);
  }

  void _actionFileDrag(bool b) {
    _pdcs.fileDragged = b;
    _pde.fileDrag(b);
  }

}
