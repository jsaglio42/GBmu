// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:14:11 by ngoguey          ###   ########.fr       //
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

class DomCart extends Object
  with DomElement
  , HtmlCartElement
  , HtmlCartClosable
  , HtmlDraggable
  implements HtmlElement_intf
{

  DomCart(PlatformDomEvents pde, String cartHtml, Html.NodeValidator v) {
    Ft.log('DomCart', 'constructor');
    this.de_init(pde);
    this.hce_init(cartHtml, v);
    this.hcc_init();
    this.hdr_init(125, 143, 75, 99);
  }

}

class DomChipSocket extends Object
  with DomElement
  , ChipSocketHtmlElement
  , HtmlDropZone
  implements HtmlElement_intf
{

  ChipSocket(PlatformDomEvents pde, Html.Element elt)
  {
    Ft.log('ChipSocket', 'constructor');
    this.de_init(pde);
    this.hcs_init(elt);
    this.hdz_init();
  }

}