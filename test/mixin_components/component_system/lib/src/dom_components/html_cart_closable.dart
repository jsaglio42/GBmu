// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_cart_closable.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:16:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:16:06 by ngoguey          ###   ########.fr       //
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

abstract class HtmlCartClosable implements HtmlCartElement, DomElement {

  // ATTRIBUTES ************************************************************* **
  bool _abort = false;

  // CONSTRUCTION *********************************************************** **
  void hcc_init() {
    Ft.log('HtmlCartClosable', 'hcc_init');
    this.btn.onClick.forEach(_onClick);
    this.jqBody.callMethod('on', ['shown.bs.collapse', _onShown]);
  }

  // PUBLIC ***************************************************************** **
  void hcc_startClose() {
    assert(__opened.toggleFalseValid(), 'hcc_startClose() invalid');
    this.jqBody.callMethod('collapse', ["hide"]);
  }

  void hcc_startOpen() {
    assert(__opened.toggleTrueValid(), 'hcc_startOpen() invalid');
    this.jqBody.callMethod('collapse', ["show"]);
  }

  void hcc_showButton() {
    assert(__buttonShown.toggleTrueValid(), 'hcc_showButton() invalid');
    assert(__opened.state == true, 'hcc_showButton() invalid open state');
    //TODO: make mouse ignore button
    this.btn.disabled = false;
  }

  void hcc_hideButton() {
    assert(__buttonShown.toggleFalseValid(), 'hcc_hideButton() invalid');
    assert(__opened.state == true, 'hcc_hideButton() invalid open state');
    this.btn.disabled = true;
  }

  void hcc_abort() {
    assert(_abort == false && __enabled.state == true, "hcc_abort() invalid");
    _abort = true;
  }

  // CALLBACKS ************************************************************** **
  void _onClick(_) {
    de_pde.cartButtonClicked(this);
  }

  void _onShown(_) {
    if (_abort) {
      _abort = false;
      this.hcc_startClose();
    }
    else
      de_pde.cartDoneOpening(this);
  }

  // INVARIANTS ************************************************************* **
  final Ft.BinaryToggle __opened = Ft.checkedOnlyBinaryToggle(false);
  final Ft.BinaryToggle __buttonShown = Ft.checkedOnlyBinaryToggle(true);

}
