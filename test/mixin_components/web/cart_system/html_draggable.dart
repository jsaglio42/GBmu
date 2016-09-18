// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_draggable.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:21:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 17:21:43 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './mixin_interfaces.dart';
import './globals.dart';

// Holds HTML interactions
abstract class HtmlDraggable implements HtmlElement_intf {

  // ATTRIBUTES ************************************************************* **

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
    assert(__stateChangeValid(true), "hdr_enable() invalid");
    this.jqElt.callMethod('draggable', ['enable']);
  }

  void hdr_disable() {
    assert(__stateChangeValid(false), "hdr_disable() invalid");
    this.jqElt.callMethod('draggable', ['disable']);
  }

  // CALLBACKS ************************************************************** **
  void _onDragStart(_, __) {
    g_csc.dragStart(this);
  }

  void _onDragStop(_, __) {
    g_csc.dragStop(this);
  }

  // INVARIANTS ************************************************************* **
  bool __enabled = false;

  bool __stateChangeValid(bool state) {
    if (state == __enabled)
      return false;
    else {
      __enabled = state;
      return true;
    }
  }

}
