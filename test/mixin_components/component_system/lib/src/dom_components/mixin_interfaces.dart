// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_interfaces.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:19:17 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 13:25:54 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

abstract class DomElement {

  // ATTRIBUTES ************************************************************* **
  PlatformDomEvents _pde;

  // CONSTRUCTION *********************************************************** **
  DomElement(this._pde);

  // PUBLIC ***************************************************************** **
  PlatformDomEvents get pde => _pde;

  Html.Element get elt;
  Js.JsObject get jsElt;
  Js.JsObject get jqElt;

}

abstract class DomComponent extends DomElement {

  // ATTRIBUTES ************************************************************* **
  LsEntry _data;

  // CONSTRUCTION *********************************************************** **
  DomComponent(PlatformDomEvents pde, this._data)
    : super(pde);

  // PUBLIC ***************************************************************** **
  LsEntry get data => _data;

}

abstract class Bank {

}

abstract class CartBank implements Bank {

}

abstract class ChipBank implements Bank {

}

abstract class TopLevelBank implements Bank {

}