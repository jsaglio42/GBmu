// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_component_events.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 15:55:47 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/06 15:29:24 by ngoguey          ###   ########.fr       //
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

class PlatformComponentEvents {

  // CONTRUCTION ************************************************************ **
  static PlatformComponentEvents _instance;

  factory PlatformComponentEvents() {
    if (_instance == null)
      _instance = new PlatformComponentEvents._();
    return _instance;
  }

  PlatformComponentEvents._() {
    Ft.log('PlatformCE', 'contructor', []);
  }

  // PUBLIC ***************************************************************** **
  // Notified by PlatformDomComponentStorage
  final Async.StreamController<CartEvent<DomCart>> _cartEvent =
    new Async.StreamController<CartEvent<DomCart>>.broadcast();
  void cartEvent(CartEvent<DomCart> that) => _cartEvent.add(that);
  Async.Stream<CartEvent<DomCart>> get onCartEvent => _cartEvent.stream;

  final Async.StreamController<ChipEvent<DomChip, DomCart>> _chipEvent =
    new Async.StreamController<ChipEvent<DomChip, DomCart>>.broadcast();
  void chipEvent(ChipEvent<DomChip, DomCart> that) => _chipEvent.add(that);
  Async.Stream<ChipEvent<DomChip, DomCart>> get onChipEvent => _chipEvent.stream;

  final Async.StreamController<SlotEvent<DomComponent>> _draggedChange =
    new Async.StreamController<SlotEvent<DomComponent>>.broadcast();
  void draggedChange(SlotEvent<DomComponent> that) => _draggedChange.add(that);
  Async.Stream<SlotEvent<DomComponent>> get onDraggedChange => _draggedChange.stream;

}
