// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_cart_closable.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:16:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 17:39:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './globals.dart';
import './html_cart_element.dart';

abstract class HtmlCartClosable implements HtmlCartElement {

  // CONSTRUCTION *********************************************************** **
  void hcc_init() {
    Ft.log('HtmlCartClosable', 'hcc_init');
    this.btn.onClick.forEach(_onClick);
    this.jqBody.callMethod('on', ['shown.bs.collapse', _onShown]);
  }

  // PUBLIC ***************************************************************** **
  void hcc_startClose() {
    assert(__openChangeValid(false), 'hcc_startClose() invalid');
    this.jqBody.callMethod('collapse', ["hide"]);
 }

  void hcc_startOpen() {
    assert(__openChangeValid(true), 'hcc_startOpen() invalid');
    this.jqBody.callMethod('collapse', ["show"]);
  }

  void hcc_showButton() {
    assert(__buttonChangeValid(true), 'hcc_showButton() invalid');
    assert(__opened, 'hcc_showButton() invalid open state');
    //TODO: make mouse ignore button
    this.btn.disabled = false;
  }

  void hcc_hideButton() {
    assert(__buttonChangeValid(false), 'hcc_hideButton() invalid');
    assert(__opened, 'hcc_hideButton() invalid open state');
    this.btn.disabled = true;
  }

  // CALLBACKS ************************************************************** **
  void _onClick(_) {
    g_csc.cartButtonClicked(this);
  }

  void _onShown(_) {
    g_csc.cartDoneOpening(this);
  }

  // INVARIANTS ************************************************************* **
  bool __opened = false;
  bool __buttonShown = true;

  bool __openChangeValid(bool opened) {
    if (__opened == opened)
      return false;
    else {
      __opened = opened;
      return true;
    }
  }

  bool __buttonChangeValid(bool buttonShown) {
    if (__buttonShown == buttonShown)
      return false;
    else {
      __buttonShown = buttonShown;
      return true;
    }
  }

}
