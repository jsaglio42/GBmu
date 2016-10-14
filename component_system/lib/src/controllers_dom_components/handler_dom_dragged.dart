// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_dom_dragged.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/08 13:50:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/14 13:59:04 by ngoguey          ###   ########.fr       //
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

class HandlerDomDragged {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  int _docCount = 0;
  int _cartBodyCount = 0;

  // CONSTRUCTION *********************************************************** **
  HandlerDomDragged(this._pde, this._pce, this._pdcs) {
    final Html.Element _cartBody = Html.querySelector('#cartsBody');

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

    _cartBody.onDragEnter.forEach(_handleCartBodyEnter);
    _cartBody.onDragLeave.forEach(_handleCartBodyLeave);
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

  void _handleDocEnter(Html.MouseEvent ev) {
    if (_docCount == 0)
      _pde.fileDrag(true);
    _docCount++;
  }

  void _handleDocLeave(Html.MouseEvent ev) {
    _docCount--;
    if (_docCount == 0)
      _pde.fileDrag(false);
  }

  void _handleDocOver(Html.MouseEvent ev) {
    ev.stopPropagation();
    ev.preventDefault();
  }

  void _handleDocDrop(Html.MouseEvent ev) {
    ev.stopPropagation();
    ev.preventDefault();
    if (_cartBodyCount > 0 && ev.dataTransfer.types.contains('Files'))
      _pde.cartBodyFilesDrop(ev.dataTransfer.files);
    _pde.cartBodyHover(false);
    _pde.fileDrag(false);
    _cartBodyCount = 0;
    _docCount = 0;
  }

  void _handleCartBodyEnter(Html.MouseEvent ev) {
    if (_cartBodyCount == 0)
      _pde.cartBodyHover(true);
    _cartBodyCount++;
  }

  void _handleCartBodyLeave(Html.MouseEvent ev) {
    _cartBodyCount--;
    if (_cartBodyCount == 0)
      _pde.cartBodyHover(false);
  }





}
