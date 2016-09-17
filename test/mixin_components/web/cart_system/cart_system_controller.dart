// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_system_controller.dart                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 17:03:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 17:43:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './mixin_assembly.dart';
import './cart_collapsing.dart';

class CartSystemController {

  // SUB CONTROLLERS ******************************************************** **
  final ClosableCartController _ccc = new ClosableCartController();

  // CONTRUCTION ************************************************************ **
  static int _instanceCount = 0;
  CartSystemController._()
  {
    assert(_instanceCount++ == 0);
  }

  // PUBLIC ***************************************************************** **
  Async.Future init() async {
    Ft.log('CartSystemController', 'init');
    _ccc.init();
  }

  // STREAMS **************************************************************** **
  // Notified by ClosableCart
  final Async.StreamController<Cart> _cartButtonClicked =
    new Async.StreamController<Cart>.broadcast();
  void cartButtonClicked(Cart that) => _cartButtonClicked.add(that);
  Async.Stream<Cart> get onCartButtonClicked => _cartButtonClicked.stream;

  final Async.StreamController<Cart> _cartDoneOpening =
    new Async.StreamController<Cart>.broadcast();
  void cartDoneOpening(Cart that) => _cartDoneOpening.add(that);
  Async.Stream<Cart> get onCartDoneOpening => _cartDoneOpening.stream;

  // Notified by ClosableCartController
  final Async.StreamController<Cart> _cartOpenedOpt =
    new Async.StreamController<Cart>.broadcast();
  void cartOpenedOpt(Cart that) => _cartOpenedOpt.add(that);
  Async.Stream<Cart> get onCartOpenedOpt => _cartOpenedOpt.stream;

  // Notified by ????
  final Async.StreamController<Cart> _cartNew =
    new Async.StreamController<Cart>.broadcast();
  void cartNew(Cart that) => _cartNew.add(that);
  Async.Stream<Cart> get onCartNew => _cartNew.stream;

  final Async.StreamController<Cart> _cartInGbOpt =
    new Async.StreamController<Cart>.broadcast();
  void cartInGbOpt(Cart that) => _cartInGbOpt.add(that);
  Async.Stream<Cart> get onCartInGbOpt => _cartInGbOpt.stream;

}

Async.Future<CartSystemController> make() async {
  Ft.log('CartSystemController', 'make');

  return new CartSystemController._();
}