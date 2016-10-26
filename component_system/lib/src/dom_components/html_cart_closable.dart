// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_cart_closable.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:16:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/26 16:32:06 by ngoguey          ###   ########.fr       //
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
abstract class HtmlCartClosable implements HtmlElementCart, DomElement {

  // ATTRIBUTES ************************************************************* **
  bool _abort = false;
  final Ft.BinaryToggle _buttonShown = Ft.checkedOnlyBinaryToggle(true);
  final Ft.BinaryToggle _closing = Ft.checkedOnlyBinaryToggle(false);

  // CONSTRUCTION *********************************************************** **
  void hcc_init() {
    // Ft.log('HtmlCartClosable', 'hcc_init');
    this.btn.onClick.forEach(_onClick);
    this.jqBody.callMethod('on', ['shown.bs.collapse', _onShown]);
    this.jqBody.callMethod('on', ['hidden.bs.collapse', _onHidden]);
  }

  // PUBLIC ***************************************************************** **
  void hcc_startClose() {
    assert(__opened.toggleFalseValid(), 'hcc_startClose() while closed');
    if (!_closing.toggleTrueValid())
      assert(false, 'hcc_startClose() while closing');
    this.jqBody.callMethod('collapse', ["hide"]);
    this.btn.classes.add('collapsed');
  }

  void hcc_startOpen() {
    assert(__opened.toggleTrueValid(), 'hcc_startOpen() invalid');
    this.jqBody.callMethod('collapse', ["show"]);
    this.btn.classes.remove('collapsed');
  }

  void hcc_showButton() {
    if (!_buttonShown.toggleTrueValid())
      assert(false, 'hcc_showButton() invalid');
    assert(__opened.state == true, 'hcc_showButton() invalid open state');
  }

  void hcc_hideButton() {
    if (!_buttonShown.toggleFalseValid())
      assert(false, 'hcc_hideButton() invalid');
    assert(__opened.state == true, 'hcc_hideButton() invalid open state');
  }

  void hcc_abort() {
    assert(_abort == false && __opened.state == true, "hcc_abort() invalid");
    _abort = true;
  }

  // CALLBACKS ************************************************************** **
  void _onClick(_) {
    if (_buttonShown.state && !_closing.state)
      this.pde.cartButtonClicked(this);
  }

  void _onShown(_) {
    if (_abort) {
      _abort = false;
      this.hcc_startClose();
    }
    else
      this.pde.cartDoneOpening(this);
  }

  void _onHidden(_) {
    if (!_closing.toggleFalseValid())
      assert(false, 'HtmlCartClosable._onHidden while not closing');
  }

  // INVARIANTS ************************************************************* **
  final Ft.BinaryToggle __opened = Ft.checkedOnlyBinaryToggle(false);

}
