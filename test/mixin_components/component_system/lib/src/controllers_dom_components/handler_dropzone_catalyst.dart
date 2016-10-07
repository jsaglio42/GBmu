// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_dropzone_catalyst.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/01 16:41:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/07 18:30:28 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerDropZoneCatalyst {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  List<HtmlDropZone> _suitableOpt;
  List<HtmlDropZone> _unsuitableOpt;

  // CONSTRUCTION *********************************************************** **
  HandlerDropZoneCatalyst(this._pde, this._pce, this._pdcs) {
    Ft.log('HandlerDropZoneCatalyst', 'contructor');

    _pce.onDraggedChange.forEach(_onDragChange);
    _pde.onDropEntered.forEach(_onDropEntered);
    _pde.onDropLeft.forEach(_onDropLeft);
  }

  // CALLBACKS ************************************************************** **
  void _onDragChange(SlotEvent<DomComponent> ev) {
    if (ev.isArrival) {
      assert(_suitableOpt == null, '_onDragChange() Arrival with some enabled');
      if (ev.value is DomCart)
        _startCart(ev.value);
      else
        _startChip(ev.value);
      _suitableOpt.forEach((dz){
            dz.hdz_enable();
            dz.hdz_setFace(false, true);
          });
      _unsuitableOpt.forEach((dz){
            dz.hdz_setFace(false, false);
          });
    }
    else {
      assert(_suitableOpt != null,
          '_onDragChange() Dismissal with none enabled');
      _suitableOpt.forEach((dz) => dz.hdz_disable());
      _suitableOpt.forEach((dz) => dz.hdz_unsetAllStyles());
      _suitableOpt = null;
      _unsuitableOpt.forEach((dz) => dz.hdz_unsetAllStyles());
      _unsuitableOpt = null;
    }
  }

  void _onDropEntered(HtmlDropZone e) {
    if (_suitableOpt.contains(e))
      e.hdz_setFace(true, true);
    else
      e.hdz_setFace(true, false);
  }

  void _onDropLeft(HtmlDropZone e) {
    if (_suitableOpt.contains(e))
      e.hdz_setFace(false, true);
    else
      e.hdz_setFace(false, false);
  }

  // PRIVATE **************************************************************** **
  void _startCart(DomCart c) {
    _suitableOpt = <HtmlDropZone>[];
    _unsuitableOpt = <HtmlDropZone>[];
    if (_pdcs.gbCart.v == c) {
      _suitableOpt.add(_pdcs.cartBank);
    }
    else if (_pdcs.openedCart.v == c) {
      if (_pdcs.gbCart.isNone) {
        _suitableOpt.add(_pdcs.gbSocket);
      }
    }
    else
      assert(false, 'from: _startCart()');
  }

  void _startChip(DomChip dragged) {
    final LsChip data = dragged.data as LsChip;
    Iterable<DomChipSocket> it;

    _suitableOpt = <HtmlDropZone>[];
    _unsuitableOpt = <HtmlDropZone>[];
    if (data.isBound)
      _suitableOpt.add(_pdcs.chipBank);
    if (_pdcs.gbCart.isSome)
      _enableCartSockets(_pdcs.gbCart.v, dragged);
    if (_pdcs.openedCart.isSome)
      _enableCartSockets(_pdcs.openedCart.v, dragged);
  }

  void _enableCartSockets(DomCart c, DomChip dragged) {
    final LsChip chdata = dragged.data as LsChip;
    final LsRom cadata = c.data as LsRom;

    if (chdata.type is Ram) {
      if (_pdcs.chipOfCartOpt(c, Ram.v) == null) {
        if (cadata.isCompatible(chdata))
          _suitableOpt.add(c.ramSocket);
        else
          _unsuitableOpt.add(c.ramSocket);
      }
    }
    else {
      for (int i = 0; i < 4; i++) {
        if (_pdcs.chipOfCartOpt(c, Ss.v, i) == null) {
          if (cadata.isCompatible(chdata))
            _suitableOpt.add(c.ssSocket(i));
          else
            _unsuitableOpt.add(c.ssSocket(i));
        }
      }
    }
  }

  // Iterable<DomChipSocket> _shownChipSocketsType(Chip type) sync* {
  //   if (type is Ram) {
  //     if (_pdcs.gbCart.isSome)
  //       yield _pdcs.gbCart.v.ramSocket;
  //     if (_pdcs.openedCart.isSome)
  //       yield _pdcs.openedCart.v.ramSocket;
  //   }
  //   else {
  //     if (_pdcs.gbCart.isSome)
  //       yield* _pdcs.gbCart.v.ssSockets;
  //     if (_pdcs.openedCart.isSome)
  //       yield* _pdcs.openedCart.v.ssSockets;
  //   }
  // }


}
