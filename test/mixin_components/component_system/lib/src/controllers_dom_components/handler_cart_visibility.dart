// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_cart_visibility.dart                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 16:58:26 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 18:09:16 by ngoguey          ###   ########.fr       //
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

import 'package:component_system/src/include_cs.dart';
// import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerCartVisibility {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomComponentStorage _pdcs;
  final PlatformComponentEvents _pce;
  final PlatformDomEvents _pde;

  HtmlCartClosable _openingOpt;

  // CONSTRUCTION *********************************************************** **
  static HandlerCartVisibility _instance;

  factory HandlerCartVisibility(pdcs, pde, pce) {
    if (_instance == null)
      _instance = new HandlerCartVisibility._(pdcs, pde, pce);
    return _instance;
  }

  HandlerCartVisibility._(this._pdcs, this._pde, this._pce) {
    Ft.log('HandlerCartVisibility', 'contructor');

    _pde.onCartButtonClicked.forEach(_onCartButtonClicked);
    _pde.onCartDoneOpening.forEach(_onCartDoneOpening);
    _pce.onGbCartChange.forEach(_onGbCartChange);
    _pce.onCartNew.forEach(_onCartNew);
  }

  // CALLBACKS ************************************************************** **
  void _onCartButtonClicked(HtmlCartClosable that) {
    assert(that != _pdcs.gbCart.v, "_onCartButtonClicked() that in gb");
    if (_openingOpt == null) {
      if (that == _pdcs.openedCart.v) {

        // Click to close
        that.hcc_startClose();
        _pdcs.openedCartDismissal();
      }
      else {

        // Click to open
        that.hcc_startOpen();
        _openingOpt = that;
        if (_pdcs.openedCart.isSome) {
          _pdcs.openedCart.v.hcc_startClose();
          _pdcs.openedCartDismissal();
        }
      }
    }
  }

  void _onCartDoneOpening(HtmlCartClosable that) {
    assert(that != _pdcs.gbCart.v, "_onCartDoneOpening() that in gb");
    assert(that == _openingOpt, "_onCartDoneOpening() that not opening");
    assert(_pdcs.openedCart.isNone, "_onCartDoneOpening() with one open");
    _openingOpt = null;
    _pdcs.openedCartArrival(that);
  }

  void _onGbCartChange(SlotEvent<DomCart> ev) {
    final HtmlCartClosable that = ev.value;

    if (ev.type is Arrival) {
      assert(_openingOpt == null, '_onCartInGbOpt() with one opening');
      _pdcs.openedCartDismissal();
      that.hcc_hideButton();
    }
    else {
      that.hcc_showButton();
      if (_openingOpt != null || _pdcs.openedCart.isSome)
        that.hcc_startClose();
      else
        _pdcs.openedCartArrival(that);
    }
  }

  void _onCartNew(HtmlCartClosable that) {
    if (_openingOpt == null) {
      if (_pdcs.openedCart.isSome) {
        _pdcs.openedCart.v.hcc_startClose();
        _pdcs.openedCartDismissal();
      }
      that.hcc_startOpen();
      _openingOpt = that;
    }
  }

  // PRIVATE **************************************************************** **

}