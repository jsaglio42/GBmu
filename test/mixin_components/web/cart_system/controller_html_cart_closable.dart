// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   controller_html_cart_closable.dart                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:38:12 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 17:38:34 by ngoguey          ###   ########.fr       //
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
import './html_cart_closable.dart';

class ControllerHtmlCartClosable {

  // ATTRIBUTES ************************************************************* **
  HtmlCartClosable _inGbOpt;
  HtmlCartClosable _openedOpt;
  HtmlCartClosable _openingOpt;

  // CONSTRUCTION *********************************************************** **
  void init() {
    Ft.log('ControllerHtmlCartClosable', 'init');
    g_csc.onCartButtonClicked.forEach(_onCartButtonClicked);
    g_csc.onCartDoneOpening.forEach(_onCartDoneOpening);
    g_csc.onCartNew.forEach(_onCartNew);
  }

  // CALLBACKS ************************************************************** **
  void _onCartButtonClicked(HtmlCartClosable that) {
    assert(that != _inGbOpt, "_onCartButtonClicked() that in gb");
    if (_openingOpt == null) {
      if (that == _openedOpt) {

        // Click to close
        that.hcc_startClose();
        _setOpenedOpt(null);
      }
      else {

        // Click to open
        that.hcc_startOpen();
        _openingOpt = that;
        if (_openedOpt != null) {
          _openedOpt.hcc_startClose();
          _setOpenedOpt(null);
        }
      }
    }
  }

  void _onCartDoneOpening(HtmlCartClosable that) {
    assert(that != _inGbOpt, "_onCartDoneOpening() that in gb");
    assert(that == _openingOpt, "_onCartDoneOpening() that not opening");
    assert(_openedOpt == null, "_onCartDoneOpening() with one open");
    _openingOpt = null;
    _setOpenedOpt(that);
  }

  void _onCartInGbOpt(HtmlCartClosable that) {
    if (that != null) {

      // that to GB
      assert(_openedOpt == that, '_onCartInGbOpt() a cart not opened');
      assert(_inGbOpt == null, '_onCartInGbOpt() with one in');
      assert(_openingOpt == null, '_onCartInGbOpt() with one opening');
      _setOpenedOpt(null);
      that.hcc_hideButton();
      _inGbOpt = that;
    }
    else {

      // _inGbOpt out of GB
      assert(_inGbOpt != null, '_onCartInGbOpt() without one in');
      _inGbOpt.hcc_showButton();
      if (_openingOpt != null || _openedOpt != null)
        _inGbOpt.startClose();
      else
        _setOpenedOpt(_inGbOpt);
      _inGbOpt = null;
    }
  }

  void _onCartNew(HtmlCartClosable that) {
    if (_openingOpt == null) {
      if (_openedOpt != null) {
        _openedOpt.hcc_startClose();
        _setOpenedOpt(null);
      }
      that.hcc_startOpen();
      _openingOpt = that;
    }
  }

  // PRIVATE **************************************************************** **
  void _setOpenedOpt(HtmlCartClosable that) {
    _openedOpt = that;
    g_csc.cartOpenedOpt(that);
  }

}