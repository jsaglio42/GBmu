// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_collapsing.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:26:43 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 19:39:43 by ngoguey          ###   ########.fr       //
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
import './cart_html.dart';

abstract class ClosableCart implements CartHtml {

  // CONSTRUCTION *********************************************************** **
  void cc_init() {
    Ft.log('ClosableCart', 'cc_init');
    this.btn.onClick.forEach(_onClick);
    this.jqBody.callMethod('on', ['shown.bs.collapse', _onShown]);
  }

  // PUBLIC ***************************************************************** **
  void cc_startClose() {
    // this.jqBody.callMethod('slideUp', []);
    this.jqBody.callMethod('collapse', ["hide"]);
 }

  void cc_startOpen() {
    // this.jqBody.callMethod('slideDown', []);
    this.jqBody.callMethod('collapse', ["show"]);
  }

  void cc_showButton() {
    this.btn.disabled = false; //TODO: make mouse ignore button
  }

  void cc_hideButton() {
    this.btn.disabled = true;
  }

  // CALLBACKS ************************************************************** **
  void _onClick(_) {
    g_csc.cartButtonClicked(this);
  }

  void _onShown(_) {
    g_csc.cartDoneOpening(this);
  }

}

class ClosableCartController {

  // ATTRIBUTES ************************************************************* **
  ClosableCart _inGbOpt;
  ClosableCart _openedOpt;
  ClosableCart _openingOpt;

  // CONSTRUCTION *********************************************************** **
  void init() {
    Ft.log('ClosableCartController', 'init');
    g_csc.onCartButtonClicked.forEach(_onCartButtonClicked);
    g_csc.onCartDoneOpening.forEach(_onCartDoneOpening);
    g_csc.onCartNew.forEach(_onCartNew);
  }

  // CALLBACKS ************************************************************** **
  void _onCartButtonClicked(ClosableCart that) {
    assert(that != _inGbOpt, "_onCartButtonClicked() that in gb");
    if (_openingOpt == null) {
      if (that == _openedOpt) {

        // Click to close

        that.cc_startClose();
        _setOpenedOpt(null);
      }
      else {

        // Click to open

        that.cc_startOpen();
        _openingOpt = that;
        if (_openedOpt != null) {
          _openedOpt.cc_startClose();
          _setOpenedOpt(null);
        }
      }
    }
  }

  void _onCartDoneOpening(ClosableCart that) {
    assert(that != _inGbOpt, "_onCartDoneOpening() that in gb");
    assert(that == _openingOpt, "_onCartDoneOpening() that not opening");
    assert(_openedOpt == null, "_onCartDoneOpening() with one open");
    _openingOpt = null;
    _setOpenedOpt(that);
  }

  void _onCartInGbOpt(ClosableCart that) {
    if (that != null) {

      // that to GB

      assert(_openedOpt == that, '_onCartInGbOpt() a cart not opened');
      assert(_inGbOpt == null, '_onCartInGbOpt() with one in');
      assert(_openingOpt == null, '_onCartInGbOpt() with one opening');
      _setOpenedOpt(null);
      that.cc_hideButton();
      _inGbOpt = that;
    }
    else {

      // _inGbOpt out of GB

      assert(_inGbOpt != null, '_onCartInGbOpt() without one in');
      _inGbOpt.cc_showButton();
      if (_openingOpt != null || _openedOpt != null)
        _inGbOpt.startClose();
      else
        _setOpenedOpt(_inGbOpt);
      _inGbOpt = null;
    }
  }

  void _onCartNew(ClosableCart that) {
    if (_openingOpt == null) {
      if (_openedOpt != null) {
        _openedOpt.cc_startClose();
        _setOpenedOpt(null);
      }
      that.cc_startOpen();
      _openingOpt = that;
    }
  }

  // PRIVATE **************************************************************** **
  void _setOpenedOpt(ClosableCart that) {
    _openedOpt = that;
    g_csc.cartOpenedOpt(that);
  }

}