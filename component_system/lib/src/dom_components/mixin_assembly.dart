// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 17:55:31 by ngoguey          ###   ########.fr       //
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
  with HtmlElementCart
  , HtmlCartClosable
  , HtmlDraggable
  , ChipSocketContainer {

  DomCart(
      PlatformDomEvents pde, LsRom data, String cartHtml, Html.NodeValidator v)
    : super(pde, data) {
    // Ft.log('DomCart', 'constructor', [pde, data, v]);
    this.hec_init(cartHtml, v);
    this.hcc_init();
    this.hdr_init(125, 143, 75, 99);
    this.csc_init();
  }

}

class DomChip extends DomComponent
  with HtmlElementSimple
  , HtmlDraggable {

  DomChip(PlatformDomEvents pde, LsChip data)
    : super(pde, data) {
    int hCenter;
    final Html.DivElement elt = new Html.DivElement();
    final Html.DivElement txt = new Html.DivElement();

    // Ft.log('DomChip', 'constructor', [pde, data]);
    txt.text = data.fileName;
    elt.nodes = [txt];
    if (data.type is Ram) {
      hCenter = 92;
      elt.classes.addAll(["cart-ram-bis", "ui-widget-content"]);
    }
    else {
      hCenter = 44;
      elt.classes.addAll(["cart-ss-bis", "ui-widget-content"]);
    }
    this.hes_init(elt);
    this.hdr_init(hCenter, 26, 20, 100);
  }

}

class DomChipSocket extends DomElement
  with HtmlElementSimple
  , HtmlDropZone
  , ChipBank {

  DomChipSocket(PlatformDomEvents pde, Html.Element elt, Chip type)
    : super(pde) {
    // Ft.log('DomChipSocket', 'constructor');

    this.hes_init(elt);
    if (type is Ram)
      this.hdz_init(HtmlDropZone.makeClassesMap(
              'cart-ram-socket-hover', 'cart-ram-socket-invalid',
              'cart-ram-socket-active', 'cart-ram-socket-invalid'));
    else
      this.hdz_init(HtmlDropZone.makeClassesMap(
              'cart-ss-socket-hover', 'cart-ss-socket-invalid',
              'cart-ss-socket-active', 'cart-ss-socket-invalid'));
  }

}


// TOP LEVEL BANKS ********************************************************** **
class DomGameBoySocket extends DomElement
  with HtmlElementSimple
  , HtmlDropZone
  , CartBank
{

  DomGameBoySocket(PlatformDomEvents pde)
    : super(pde) {
    // Ft.log('DomGameBoySocket', 'constructor', [pde]);
    this.hes_init(Html.querySelector('#gb-slot'));
    this.hdz_init(HtmlDropZone.makeClassesMap(
            'gameboysocket-hover', null, 'gameboysocket-active', null));
  }

}

class DomDetachedCartBank extends DomElement
  with HtmlElementSimple
  , HtmlDropZone
  , CartBank
{

  DomDetachedCartBank(PlatformDomEvents pde)
    : super(pde) {
    // Ft.log('DomDetachedCartBank', 'constructor', [pde]);
    this.hes_init(Html.querySelector('#accordion'));
    this.hdz_init(HtmlDropZone.makeClassesMap(
            'accordion-hover', null, 'accordion-active', null));
  }

}

class DomDetachedChipBank extends DomElement
  with HtmlElementSimple
  , HtmlDropZone
  , ChipBank
{

  DomDetachedChipBank(PlatformDomEvents pde)
    : super(pde) {
    // Ft.log('DomDetachedChipBank', 'constructor', [pde]);
    this.hes_init(Html.querySelector('#detached-chip-bank'));
    this.hdz_init(HtmlDropZone.makeClassesMap(
            'chipbank-hover', null, 'chipbank-active', null));
  }

}
