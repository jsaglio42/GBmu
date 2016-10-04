// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_component_events.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 15:55:47 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/04 18:49:37 by ngoguey          ###   ########.fr       //
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

  // // final Async.StreamController<DomCart> _cartNew =
  // //   new Async.StreamController<DomCart>.broadcast();
  // // void cartNew(DomCart that) => _cartNew.add(that);
  // // Async.Stream<DomCart> get onCartNew => _cartNew.stream;
  // Async.Stream<DomCart> get onCartNew =>
  //   onCartEvent
  //   .where((CartEvent<DomCart> ev) => ev.src is None)
  //   .map((CartEvent<DomCart> ev) => ev.cart);

  // // (cartNew|cartDelete|openedCartChange|gbCartChange)

  // // final Async.StreamController<DomCart> _cartDelete =
  // //   new Async.StreamController<DomCart>.broadcast();
  // // void cartDelete(DomCart that) => _cartDelete.add(that);
  // // Async.Stream<DomCart> get onCartDelete => _cartDelete.stream;
  // Async.Stream<DomCart> get onCartDelete =>
  //   onCartEvent
  //   .where((CartEvent<DomCart> ev) => ev.dst is None)
  //   .map((CartEvent<DomCart> ev) => ev.cart);

  // // final Async.StreamController<SlotEvent<DomCart>> _openedCartChange =
  // //   new Async.StreamController<SlotEvent<DomCart>>.broadcast();
  // // void openedCartChange(SlotEvent<DomCart> that) => _openedCartChange.add(that);
  // // Async.Stream<SlotEvent<DomCart>> get onOpenedCartChange => _openedCartChange.stream;
  // Async.Stream<SlotEvent<DomCart>> get onOpenedCartChange =>
  //   onCartEvent
  //   .where((CartEvent<DomCart> ev) => ev.isOpenedChange)
  //   .map((CartEvent<DomCart> ev) => ev.src is Opened
  //       ? new SlotEvent<DomCart>.Dismissal(ev.cart)
  //       : new SlotEvent<DomCart>.Arrival(ev.cart));

  // // final Async.StreamController<SlotEvent<DomCart>> _gbCartChange =
  // //   new Async.StreamController<SlotEvent<DomCart>>.broadcast();
  // // void gbCartChange(SlotEvent<DomCart> that) => _gbCartChange.add(that);
  // // Async.Stream<SlotEvent<DomCart>> get onGbCartChange => _gbCartChange.stream;
  // Async.Stream<SlotEvent<DomCart>> get onGbCartChange =>
  //   onCartEvent
  //   .where((CartEvent<DomCart> ev) => ev.isGbChange)
  //   .map((CartEvent<DomCart> ev) => ev.src is GameBoy
  //       ? new SlotEvent<DomCart>.Dismissal(ev.cart)
  //       : new SlotEvent<DomCart>.Arrival(ev.cart));


  final Async.StreamController<SlotEvent<DomComponent>> _draggedChange =
    new Async.StreamController<SlotEvent<DomComponent>>.broadcast();
  void draggedChange(SlotEvent<DomComponent> that) => _draggedChange.add(that);
  Async.Stream<SlotEvent<DomComponent>> get onDraggedChange => _draggedChange.stream;

}
