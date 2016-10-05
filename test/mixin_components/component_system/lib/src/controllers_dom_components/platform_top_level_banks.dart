// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_top_level_banks.dart                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 16:51:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 16:46:29 by ngoguey          ###   ########.fr       //
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

class PlatformTopLevelBanks {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentEvents _pce;
  final PlatformDomEvents _pde;

  final DomGameBoySocket _dgbs;
  final DomDetachedCartBank _ddcb;

  // CONTRUCTION ************************************************************ **
  static PlatformTopLevelBanks _instance;

  factory PlatformTopLevelBanks(pde, pce) {
    if (_instance == null)
      _instance = new PlatformTopLevelBanks._(pde, pce);
    return _instance;
  }

  PlatformTopLevelBanks._(pde, this._pce)
    : _pde = pde
    , _dgbs = new DomGameBoySocket(pde)
    , _ddcb = new DomDetachedCartBank(pde) {
    Ft.log('PlatformTLB', 'contructor');

    _pce.onCartEvent.forEach(_handleCartEvent);
  }

  // PUBLIC ***************************************************************** **
  DomGameBoySocket get gbSocket => _dgbs;
  DomDetachedCartBank get cartBank => _ddcb;

  // CALLBACKS ************************************************************** **
  void _handleCartEvent(CartEvent<DomCart> ev) {
    Ft.log('PlatformTLB', '_handleCartEvent', [ev]);
    if (ev.isMove) {
      ev.cart.elt.style.left = '0px';
      ev.cart.elt.style.top = '0px';
    }

    if (ev.isNew || ev.isUnload)
      _ddcb.elt.nodes.add(ev.cart.elt);
    else if (ev.isLoad)
      _dgbs.elt.nodes = [ev.cart.elt];
    else if (ev.isDeleteOpened || ev.isDeleteClosed)
      _ddcb.elt.nodes.remove(ev.cart.elt);
    else if (ev.isDeleteGameBoy)
      _dgbs.elt.nodes = [];
    // else: Don't act on Open & Close
  }

}