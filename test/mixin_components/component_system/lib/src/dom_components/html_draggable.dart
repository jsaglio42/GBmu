// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_draggable.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:21:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:16:02 by ngoguey          ###   ########.fr       //
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

import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

// Holds HTML interactions
abstract class HtmlDraggable implements HtmlElement_intf, DomElement {

  // ATTRIBUTES ************************************************************* **
  bool _abort = false;

  // CONSTRUCTION *********************************************************** **
  void hdr_init(int left, int top, int distance, int zIndex) {
    Ft.log('HtmlDraggable', 'hdr_init');

    this.jqElt.callMethod('draggable', [new Js.JsObject.jsify({
      'helper': "original",
      'revert': true,
      'revertDuration': 50,
      'cursorAt': {'left': left, 'top': top},
      'distance': distance,
      'cursor': "crosshair",
      'zIndex': zIndex.toString(),
      'cancel': "input,textarea,select,option",
      'start': _onDragStart,
      'stop': _onDragStop,
    })]);
  }

  // PUBLIC ***************************************************************** **
  // `Cart` is never disabled
  // `Chip` in `GB` or in `a closed cart` is disabled
  void hdr_enable() {
    assert(__enabled.toggleTrueValid(), "hdr_enable() invalid");
    this.jqElt.callMethod('draggable', ['enable']);
  }

  void hdr_disable() {
    assert(__enabled.toggleFalseValid(), "hdr_disable() invalid");
    this.jqElt.callMethod('draggable', ['disable']);
  }

  void hdr_abort() {
    assert(_abort == false && __enabled.state == true, "hdr_abort() invalid");
    _abort = true;
  }

  // CALLBACKS ************************************************************** **
  void _onDragStart(_, __) {
    de_pde.dragStart(this);
  }

  void _onDragStop(_, __) {
    de_pde.dragStop(this);
  }

  void _onDrag(_, __) {
    if (_abort) {
      _abort = false;
      return false;
    }
    return true;
  }

  // INVARIANTS ************************************************************* **
  final Ft.BinaryToggle __enabled = Ft.checkedOnlyBinaryToggle(false);

}
