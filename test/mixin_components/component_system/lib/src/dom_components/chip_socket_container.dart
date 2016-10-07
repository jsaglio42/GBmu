// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   chip_socket_container.dart                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/07 15:07:52 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/07 15:25:09 by ngoguey          ###   ########.fr       //
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

abstract class ChipSocketContainer implements DomElement {

  // ATTRIBUTES ************************************************************* **
  DomChipSocket _ram;
  List<DomChipSocket> _ss;

  // CONSTRUCTION *********************************************************** **
  void csc_init() {
    Ft.log('ChipSocketContainer', 'csc_init');
    int i = 0;

    _ram = new DomChipSocket(
        this.pde, this.elt.querySelector('.cart-ram-socket'));
    _ss = new List<DomChipSocket>.from(
        this.elt.querySelectorAll('.cart-ss-socket')
        .map((elt) => new DomChipSocket(this.pde, elt)), growable: false);
    assert(_ss != null && _ss.length == 4);
  }

  // PUBLIC ***************************************************************** **
  DomChipSocket get ramSocket => _ram;
  DomChipSocket getSsSocket(int i) => _ss[i];

}