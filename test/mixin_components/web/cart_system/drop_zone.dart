// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   drop_zone.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:16:09 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 20:47:36 by ngoguey          ###   ########.fr       //
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

// DropZone to DropRegion? DropArea?
abstract class DropZone implements HtmlElement_intf {

  // ATTRIBUTES ************************************************************* **
  List<bool> _activePairOpt = null;
  Map<bool, Map<bool, String>> _classesOpt;

  // CONSTRUCTION *********************************************************** **
  // Parameter format:
  // {true:  {true:  hover&suitable, false:  hover&!suitable},
  //  false: {true: !hover&suitable, false: !hover&!suitable},}
  void dz_init(Map<bool, Map<bool, String>> classesOpt) {
    Ft.log('DropZone', 'dr_init');
    _facesOpt = facesOpt;

    this.jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'drop': _onDrop,
      'over': _onEnter,
      'out': _onLeave,
    })]);

  }

  // PUBLIC ***************************************************************** **
  void dz_enable() {
    this.jqElt.callMethod('droppable', ['enable']);
    // TODO?: notify activation status as a DropZone
  }

  void dz_disable() {
    this.jqElt.callMethod('droppable', ['disable']);
    // TODO?: notify activation status as a DropZone
  }

  void dz_take(Draggable that); // ABSTRACT
  void dz_lose(Draggable that); // ABSTRACT

  void dz_setFace(bool hover, bool suitable) {
    this.dz_unsetAllFace();
    if (_classesOpt[hover][suitable] != null) {
      this.elt.classes.add(_classesOpt[hover][suitable]);
      _activePairOpt = <bool>[hover, suitable];
    }
  }

  void dz_unsetAllFace() {
    if (_activePairOpt != null) {
      this.elt.classes.remove(
          _classesOpt[_activePairOpt[0]][_activePairOpt[1]]);
      _activePairOpt = null;
    }
  }

  void dz_setTooltip(String msg) { //TODO ?
  }

  // CALLBACKS ************************************************************** **
  void _onDrop(_, __) {
    g_csc.dropReceived(that);
  }

  void _onEnter(_, __){
    g_csc.dropZoneEntered(that);
  }

  void _onLeave(_, __){
    g_csc.dropZoneLeaved(that);
  }

  // PRIVATE **************************************************************** **

}