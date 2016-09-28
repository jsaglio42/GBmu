// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 18:16:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './mixin_interfaces.dart';
import './html_cart_element.dart';
import './html_cart_closable.dart';
import './html_draggable.dart';
import './html_chipsocket_element.dart';
import './html_dropzone.dart';
import 'package:component_system/src/controllers_dom_components/platform_dom_events.dart';
// import './.dart';
// import './.dart';
// import './.dart';

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