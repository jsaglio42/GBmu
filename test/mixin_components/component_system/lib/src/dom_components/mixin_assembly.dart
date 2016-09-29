// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 13:00:53 by ngoguey          ###   ########.fr       //
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

class DomCart extends DomComponent
  with HtmlCartElement
  , HtmlCartClosable
  , HtmlDraggable
{

  DomCart(
      PlatformDomEvents pde, LsRom data, String cartHtml, Html.NodeValidator v)
    : super(pde, data) {
    Ft.log('DomCart', 'constructor');
    this.hce_init(cartHtml, v);
    this.hcc_init();
    this.hdr_init(125, 143, 75, 99);
  }

}

class DomChipSocket extends DomElement
  with ChipSocketHtmlElement
  , HtmlDropZone
{

  // ChipSocket(PlatformDomEvents pde, Html.Element elt)
  // {
    // Ft.log('ChipSocket', 'constructor');
    // this.hcs_init(elt);
    // this.hdz_init();
  // }

}