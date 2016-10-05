// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/05 17:16:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 17:38:19 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

// library platform_cart;

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

// part 'platform_cart_parts.dart';

class PlatformChip
  // extends Object with _Actions implements _Super
{

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomDragged _pdd;
  final PlatformCart _pc;

  // CONSTRUCTION *********************************************************** **
  PlatformChip(this._pde, this._pce, this._pdd, this._pc) {
    Ft.log('PlatformChip', 'contructor');

    _pde.onDropReceived
      .where((v) => v is ChipBank)
      .map((v) => v as ChipBank)
      .forEach(_onDropReceived);
  }

  // PUBLIC ***************************************************************** **
  void newChip(DomChip that) {
  //   _actionNew(that);
  //   if (_openingOpt == null) {
  //     if (_openedCart.isSome) {
  //       openedCart.v.hcc_startClose();
  //       _actionClose();
  //     }
  //     that.hcc_startOpen();
  //     _openingOpt = that;
  //   }
  }

  void deleteChip(DomChip that) {
  //   if (that == _gbCart.v)
  //     _actionDeleteGameBoy();
  //   else if (that == _openedCart.v)
  //     _actionDeleteOpened();
  //   else {
  //     if (that == _openingOpt)
  //       that.hcc_abort();
  //     _actionDeleteClosed(that);
  //   }
  }

  // CALLBACKS ************************************************************** **
  // The almighty function that has the view on:
  //   The chip-socket, the cart its parent, and the dragged chip.
  void _onDropReceived(ChipBank that) {
    DomCart cart;
    DomChip chip;

    assert(_pdd.dragged.isSome, '_onDropReceived() with none dragged');
    chip = _pdd.dragged.v;
    if (that is DomDetachedChipBank)
      _pcs.unbind(chip.data);
    else {
      // cart = _pc.cartOfSocket(that);
      // if (chip.data.type is Ram)
        // _pcs.bindRam(chip.data, cart.data);
      // else
        // _pcs.bindSS(chip.data, cart.data, that.dcs_ssSlot);
      // TODO: uncomment for ss
    }
  }

  // PRIVATE **************************************************************** **

}