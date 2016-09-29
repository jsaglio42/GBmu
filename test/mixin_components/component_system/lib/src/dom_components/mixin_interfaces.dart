// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_interfaces.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:19:17 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:14:15 by ngoguey          ###   ########.fr       //
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

import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

abstract class DomElement {

  // ATTRIBUTES ************************************************************* **
  PlatformDomEvents _pde;

  // CONSTRUCTION *********************************************************** **
  void de_init(PlatformDomEvents pde) {
    Ft.log('DomElement', 'de_init', [pde]);
    _pde = pde;
  }

  // PUBLIC ***************************************************************** **
  PlatformDomEvents get de_pde => _pde;
}

abstract class HtmlElement_intf {
  Html.Element get elt;
  Js.JsObject get jsElt;
  Js.JsObject get jqElt;
}
