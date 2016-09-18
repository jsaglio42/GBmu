// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 17:29:18 by ngoguey          ###   ########.fr       //
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
// import './.dart';
// import './.dart';
// import './.dart';

// Caution: Mixins are partially ordered. Concerns imports/implements/init
class DomCart extends Object
  with HtmlCartElement
  , HtmlCartClosable
  , HtmlDraggable
  implements HtmlElement_intf
{

  DomCart(String cartHtml, Html.NodeValidator v) {
    Ft.log('Cart', 'constructor');
    this.hce_init(cartHtml, v);
    this.hcc_init();
    this.hdr_init(125, 143, 75, 99);
  }

}

class DomChipSocket extends Object
  with ChipSocketHtmlElement
  , HtmlDropZone
  implements HtmlElement_intf
{

  ChipSocket(Html.Element elt)
  {
    Ft.log('ChipSocket', 'constructor');
    this.hcs_init(elt);
    this.hdz_init();
  }

}