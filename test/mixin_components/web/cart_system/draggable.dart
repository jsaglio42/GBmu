// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   draggable.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:16:10 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 19:29:29 by ngoguey          ###   ########.fr       //
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

abstract class Draggable implements HtmlElement_intf {

  // ATTRIBUTES ************************************************************* **

  // CONSTRUCTION *********************************************************** **
  void dr_init(int left, int top, int distance, int zIndex) {
    Ft.log('Draggable', 'dr_init');

    this.jqElt.callMethod('draggable', [new Js.JsObject.jsify({
      'helper': "original",
      'revert': true,
      'revertDuration': 50,
      'cursorAt': { 'left': left, 'top': top },
      'distance': distance,
      'cursor': "crosshair",
      'zIndex': zIndex.toString(),
      'cancel': "input,textarea,select,option",
      'start': _onDragStart,
      'stop': _onDragStop,
    })]);
  }

  // PUBLIC ***************************************************************** **
  void dr_enable() {
    this.jqElt.callMethod('draggable', ['enable']);
  }

  void dr_disable() {
    this.jqElt.callMethod('draggable', ['disable']);
  }

  // CALLBACKS ************************************************************** **
  void _onDragStart(_, __) {
    g_csc.dragStart(this);
  }

  void _onDragStop(_, __) {
    g_csc.dragStop(this);
  }

}
