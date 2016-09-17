// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_html.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:35:57 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 20:36:53 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

// import './cart.dart';

abstract class CartHtml {

  // ATTRIBUTES ************************************************************* **
  Html.Element _elt;
  Html.ButtonElement _btn;
  Html.Element _body;

  // CONSTRUCTION *********************************************************** **
  void ch_init(String cartHtml, Html.NodeValidator v) {
    Ft.log('CartHtml', 'ch_init');
    _elt = new Html.Element.html(cartHtml, validator: v);
    _btn = _elt.querySelector('.bg-head-btn');
    _body = _elt.querySelector('.panel-collapse');
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

}