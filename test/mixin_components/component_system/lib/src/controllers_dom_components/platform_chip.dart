// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/05 17:16:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/07 18:01:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library platform_chip;

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

part 'platform_chip_parts.dart';

class PlatformChip extends Object with _Actions implements _Super
{

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  // CONSTRUCTION *********************************************************** **
  PlatformChip(this._pcs, this._pde, this._pce, this._pdcs) {
    Ft.log('PlatformChip', 'contructor');

    _pde.onDropReceived
      .where((v) => v is ChipBank)
      .map((v) => v as ChipBank)
      .forEach(_onDropReceived);
  }

  // PUBLIC ***************************************************************** **
  void newChip(DomChip that) {
    final LsChip data = that.data as LsChip;

    if (!data.isBound)
      _actionNewDetached(that);
    else
      _actionNewAttached(that);
  }

  void deleteChip(DomChip that) {
    final LsChip data = that.data as LsChip;

    if (!data.isBound)
      _actionDeleteDetached(that);
    else
      _actionDeleteAttached(that);
  }

  // CALLBACKS ************************************************************** **
  // The almighty function that has the view on:
  //   The chip-socket, the cart, and the dragged chip.
  void _onDropReceived(ChipBank that) {
    DomCart cart;
    DomChip chip;
    LsChip chdata;

    assert(_pdcs.dragged.isSome, '_onDropReceived() with none dragged');
    chip = _pdcs.dragged.v;
    chdata = chip.data as LsChip;
    if (that is DomDetachedChipBank)
      _pcs.unbind(chdata);
    else {
      cart = _pdcs.cartOfSocket(that as DomChipSocket);
      if (chdata.type is Ram)
        _pcs.bindRam(chdata, cart.data);
      else
        _pcs.bindSs(chdata, cart.data, cart.ssSocketIndex(that));
    }
  }

  // PRIVATE **************************************************************** **

}