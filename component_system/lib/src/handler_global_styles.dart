// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_global_styles.dart                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 14:19:56 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/14 15:36:30 by ngoguey          ###   ########.fr       //
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

    _pde.onCartSystemHover.forEach(_onCartSystemHover);
    _pce.onCartEvent.forEach(_onCartEvent);
  }

  // CALLBACKS ************************************************************** **
  void _onCartSystemHover(bool b) {
    if (b)
      _pdcs.carts.forEach((DomCart c){
        c.btnText.text = c.data.fileName;
      });
    else
      _pdcs.carts.forEach((DomCart c){
        c.btnText.text = "";
      });
  }

  void _onCartEvent(CartEvent<DomCart> ev) {
    if (ev.src is None && _pdcs.cartSystemHovered) {
      ev.cart.btnText.text = ev.cart.data.fileName;
    }
  }

  // PRIVATE **************************************************************** **

}
