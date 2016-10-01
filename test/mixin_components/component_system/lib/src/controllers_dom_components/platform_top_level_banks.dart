// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_top_level_banks.dart                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 16:51:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/01 17:03:28 by ngoguey          ###   ########.fr       //
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

    _pce.onCartNew.forEach(_handleCartNew);
    _pce.onCartDelete.forEach(_handleCartDelete);
    _pce.onGbCartChange.forEach(_handleGbCartChange);
  }

  // PUBLIC ***************************************************************** **
  DomGameBoySocket get gbSocket => _dgbs;
  DomDetachedCartBank get cartBank => _ddcb;

  // CALLBACKS ************************************************************** **
  void _handleCartNew(DomCart c) {
    Ft.log('PlatformTLB', '_handleCartNew', [c]);
    _ddcb.elt.nodes.add(c.elt);
  }

  void _handleCartDelete(DomCart c) {
    Ft.log('PlatformTLB', '_handleCartDelete', [c]);
    if (_ddcb.elt.nodes.contains(c.elt))
      _ddcb.elt.nodes.remove(c.elt);
  }

  void _handleGbCartChange(SlotEvent<DomCart> ev) {
    final DomCart that = ev.value;

    if (ev.type is Dismissal)
      _ddcb.elt.nodes.add(that.elt);
    else
      _dgbs.elt.nodes = [that.elt];
  }

}