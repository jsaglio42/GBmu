// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_dragged.dart                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/04 19:04:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 16:58:29 by ngoguey          ###   ########.fr       //
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

class PlatformDomDragged {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentEvents _pce;
  final PlatformDomEvents _pde;

  Ft.Option<DomComponent> _dragged = new Ft.Option<DomComponent>.none();

  // CONSTRUCTION *********************************************************** **
  PlatformDomDragged(this._pde, this._pce) {
    Ft.log('PlatformDomDragged', 'contructor');

    _pde.onDragStart.forEach(_onDragStart);
    _pde.onDragStop.forEach(_onDragStop);
    _pce.onCartEvent
      .where((ev) => ev.isDelete && ev.cart == _dragged.v)
      .map((ev) => ev.cart)
      .forEach(_handleDraggedDelete);
    // Todo: motitor chip delete while dragged
  }

  // CALLBACKS ************************************************************** **
  Ft.Option<DomComponent> get dragged => _dragged;

  void _onDragStart(HtmlDraggable that) {
    assert(_dragged.isNone, "from: _onDragStart");
    _dragged = new Ft.Option<DomComponent>.some(that as DomComponent);
    _pce.draggedChange(
        new SlotEvent<DomComponent>.Arrival(that as DomComponent));
  }

  void _onDragStop(HtmlDraggable that) {
    assert(_dragged.isSome, "from: _onDragStop");
    _pce.draggedChange(new SlotEvent<DomComponent>.Dismissal(_dragged.v));
    _dragged = new Ft.Option<DomComponent>.none();
  }

  void _handleDraggedDelete(HtmlDraggable that) {
    Ft.log('PlatformDomDragged', '_handleDraggedDelete', [that]);
    that.hdr_abort();
    _pce.draggedChange(
        new SlotEvent<DomComponent>.Dismissal(that as DomComponent));
    _dragged = new Ft.Option<DomComponent>.none();
  }


}
