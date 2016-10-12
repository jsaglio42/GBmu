// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_dropzone.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:26:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 18:56:43 by ngoguey          ###   ########.fr       //
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
abstract class HtmlDropZone implements DomElement {

  // ATTRIBUTES ************************************************************* **
  List<bool> _activePairOpt = null;
  bool _tooltipActive = false;
  Map<bool, Map<bool, String>> _classesOpt;

  // CONSTRUCTION *********************************************************** **
  // `_classesOpt` parameter format:
  // {true:  {true:  hover&suitable, false:  hover&!suitable},
  //  false: {true: !hover&suitable, false: !hover&!suitable},}
  static Map<bool, Map<bool, String>> makeClassesMap(
      String hs, String hns, String nhs, String nhns) =>
    <bool, Map<bool, String>>{
      true: <bool, String>{true: hs, false: hns},
      false: <bool, String>{true: nhs, false: nhns},
    };

  void hdz_init(Map<bool, Map<bool, String>> classesOpt) {
    // Ft.log('HtmlDropZone', 'hdz_init');

    _classesOpt = classesOpt;
    this.jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'drop': _onDrop,
      'over': _onEnter,
      'out': _onLeave,
      'tolerance': 'pointer',
    })]);
    this.jqElt.callMethod('droppable', ['disable']);
  }

  // PUBLIC ***************************************************************** **
  // `GameBoySocket` is disabled if full
  // `DetachedCartBank` is never disabled
  // `DetachedChipBank` is never disabled
  // `ChipSocket` is disabled if `full` or `in closed cart`
  void hdz_enable() {
    assert(__stateChangeValid(true), "hdz_enable() invalid");
    this.jqElt.callMethod('droppable', ['enable']);
  }

  void hdz_disable() {
    assert(__stateChangeValid(false), "hdz_disable() invalid");
    this.jqElt.callMethod('droppable', ['disable']);
  }

  void hdz_setFace(bool hover, bool suitable) {
    _cleanCurrentOptClass();
    if (_classesOpt[hover][suitable] != null) {
      this.elt.classes.add(_classesOpt[hover][suitable]);
      _activePairOpt = <bool>[hover, suitable];
    }
  }

  void hdz_setTooltip(String msg) {
    _cleanCurrentOptTooltip();
    // TODO: set tooltip
    _tooltipActive = true;
  }

  void hdz_unsetAllStyles() {
    _cleanCurrentOptClass();
    _cleanCurrentOptTooltip();
  }

  // CALLBACKS ************************************************************** **
  void _onDrop(_, __) {
    this.pde.dropReceived(this);
  }

  void _onEnter(_, __){
    this.pde.dropEntered(this);
  }

  void _onLeave(_, __){
    this.pde.dropLeft(this);
  }

  // PRIVATE **************************************************************** **
  void _cleanCurrentOptClass() {
    if (_activePairOpt != null) {
      this.elt.classes.remove(
          _classesOpt[_activePairOpt[0]][_activePairOpt[1]]);
      _activePairOpt = null;
    }
  }

  void _cleanCurrentOptTooltip() {
    if (_tooltipActive) {
      // TODO: remove tooltip
      _tooltipActive = false;
    }
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
