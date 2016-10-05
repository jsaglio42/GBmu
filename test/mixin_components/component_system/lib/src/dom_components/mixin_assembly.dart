// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 16:10:14 by ngoguey          ###   ########.fr       //
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
  , HtmlDraggable {
  DomCart(
      PlatformDomEvents pde, LsRom data, String cartHtml, Html.NodeValidator v)
    : super(pde, data) {
    Ft.log('DomCart', 'constructor', [pde, data, v]);
    this.hec_init(cartHtml, v);
    this.hcc_init();
    this.hdr_init(125, 143, 75, 99);
  }
}

// class DomChipSocket extends DomElement
  // with HtmlElementSimple
  // , HtmlDropZone {

  // ChipSocket(PlatformDomEvents pde, Html.Element elt)
  // {
    // Ft.log('ChipSocket', 'constructor');
  // }

// }

class DomGameBoySocket extends DomElement
  with HtmlElementSimple
  , HtmlDropZone
  , CartBank
  // , TopLevelBank
  // , SingleElementBank<DomCart>
{

  DomGameBoySocket(PlatformDomEvents pde)
    : super(pde) {
    Ft.log('DomGameBoySocket', 'constructor', [pde]);
    this.hes_init(Html.querySelector('#gb-slot'));
    this.hdz_init(HtmlDropZone.makeClassesMap(
            'gameboysocket-hover', null, 'gameboysocket-active', null));
  }

}

class DomDetachedCartBank extends DomElement
  with HtmlElementSimple
  , HtmlDropZone
  , CartBank
  // , TopLevelBank
  // , ListBank<DomCart>
{

  DomDetachedCartBank(PlatformDomEvents pde)
    : super(pde) {
    Ft.log('DomGameBoySocket', 'constructor', [pde]);
    this.hes_init(Html.querySelector('#accordion'));
    this.hdz_init(HtmlDropZone.makeClassesMap(
            'accordion-hover', null, 'accordion-active', null));
  }

}