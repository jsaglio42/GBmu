// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_global_styles.dart                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 14:19:56 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 18:33:56 by ngoguey          ###   ########.fr       //
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
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;
import 'package:emulator/constants.dart';

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerGlobalStyles {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  // CONTRUCTION ************************************************************ **
  HandlerGlobalStyles(this._pde, this._pce, this._pdcs) {
    Ft.log('HandlerGS', 'contructor');

    _pce.onCartEvent.forEach(_onCartEvent);
    _pce.onChipEvent.forEach(_onChipEvent);
  }

  // CALLBACKS ************************************************************** **
  void _onCartEvent(CartEvent<DomCart> ev) {
    if (ev.src is None || ev.dst is None) {
      if (_pdcs.hasCarts) {
        _pdcs.labelNoCart.style.display = "none";
        if (_pdcs.gbCart.isNone)
          _pdcs.labelGameBoySocketEmpty.style.display = "";
      }
      else {
        _pdcs.labelNoCart.style.display = "";
        _pdcs.labelGameBoySocketEmpty.style.display = "none";
      }
    }
    if (ev.src is GameBoy && ev.dst is! GameBoy) {
      _pdcs.labelRestart.style.visibility = "hidden";
      _pdcs.labelEject.style.visibility = "hidden";
      _pdcs.labelExtractRam.style.visibility = "hidden";
      _pdcs.labelGameBoySocketEmpty.style.display = "";
    }
    else if (ev.dst is GameBoy && ev.src is! GameBoy) {
      _pdcs.labelRestart.style.visibility = "visible";
      _pdcs.labelEject.style.visibility = "visible";
      _pdcs.labelGameBoySocketEmpty.style.display = "none";
      if (_pdcs.chipOfCartOpt(ev.cart, Ram.v) != null ||
          (ev.cart.data as LsRom).ramSize == 0)
        _pdcs.labelExtractRam.style.visibility = "hidden";
      else
        _pdcs.labelExtractRam.style.visibility = "visible";
    }
  }

  void _onChipEvent(ChipEvent<DomChip, DomCart> ev) {
    if (ev.chip.data.type is Ram) {
      if (ev.src is Attached && ev.srcCartOpt == _pdcs.gbCart.v) {
        if ((ev.chip.data as LsRam).size == 0)
          _pdcs.labelExtractRam.style.visibility = "hidden";
        else
          _pdcs.labelExtractRam.style.visibility = "visible";
      }
      else if (ev.dst is Attached && ev.dstCartOpt == _pdcs.gbCart.v)
        _pdcs.labelExtractRam.style.visibility = "hidden";
    }
    if (ev.src is None || ev.dst is None) {
      if (_pdcs.hasChips)
        _pdcs.labelNoChip.style.display = "none";
      else
        _pdcs.labelNoChip.style.display = "";
    }
  }

  // PRIVATE **************************************************************** **

}
