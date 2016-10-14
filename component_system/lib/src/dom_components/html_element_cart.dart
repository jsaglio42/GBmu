// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_element_cart.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 13:35:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/14 14:44:29 by ngoguey          ###   ########.fr       //
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

abstract class HtmlElementCart {

  // ATTRIBUTES ************************************************************* **
  Html.Element _elt;
  Html.ButtonElement _btn;
  Html.Element _body;
  Html.DivElement _btnText;

  // CONSTRUCTION *********************************************************** **
  void hec_init(String cartHtml, Html.NodeValidator v) {
    // Ft.log('HtmlElementCart', 'hec_init');
    _elt = new Html.Element.html(cartHtml, validator: v);
    _btn = _elt.querySelector('.bg-head-btn');
    _body = _elt.querySelector('.panel-collapse');
    _btnText = _elt.querySelector('.bg-head-btn .text');
  }

  // PUBLIC ***************************************************************** **
  Html.Element get elt => _elt;
  Js.JsObject get jsElt => new Js.JsObject.fromBrowserObject(_elt);
  Js.JsObject get jqElt => Js.context.callMethod(r'$', [this.jsElt]);

  Html.ButtonElement get btn => _btn;
  Js.JsObject get jsBtn => new Js.JsObject.fromBrowserObject(_btn);
  Js.JsObject get jqBtn => Js.context.callMethod(r'$', [this.jsBtn]);

  Html.ButtonElement get body => _body;
  Js.JsObject get jsBody => new Js.JsObject.fromBrowserObject(_body);
  Js.JsObject get jqBody => Js.context.callMethod(r'$', [this.jsBody]);

  Html.DivElement get btnText => _btnText;
  Js.JsObject get jsBtnText => new Js.JsObject.fromBrowserObject(_btnText);
  Js.JsObject get jqBtnText => Js.context.callMethod(r'$', [this.jsBtnText]);

}
