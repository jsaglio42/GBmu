// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_interfaces.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:19:17 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 18:10:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import 'package:component_system/src/controllers_dom_components/platform_dom_events.dart';

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
