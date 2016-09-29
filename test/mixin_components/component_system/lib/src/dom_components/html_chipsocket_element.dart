// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_chipsocket_element.dart                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:22:26 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:14:23 by ngoguey          ###   ########.fr       //
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

abstract class HtmlChipSocketElement {

  // ATTRIBUTES ************************************************************* **
  Html.Element _elt;

  // CONSTRUCTION *********************************************************** **
  void csh_init(this._elt) {
    Ft.log('HtmlChipSocketElement', 'csh_init');
  }

  // PUBLIC ***************************************************************** **
  Html.Element get elt => _elt;
  Js.JsObject get jsElt => new Js.JsObject.fromBrowserObject(_elt);
  Js.JsObject get jqElt => Js.context.callMethod(r'$', [this.jsElt]);

}
