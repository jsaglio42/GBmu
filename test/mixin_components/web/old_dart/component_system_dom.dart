// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   component_system_dom.dart                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/15 16:07:18 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 19:30:45 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/filedb.dart' as Emufiledb;

import './component_system.dart';

enum Dragging {
  None,

  Cart,
    /* Grabbable ->
     *   (#CartBank .openCart)
     *   (#GBCartSocket.non-empty)
     * Droppable ->
     *   (#CartBank)
     *   (#GBCartSocket.empty)
     */

  Ram,
    /* Grabbable ->
     *   (#CartBank .openCart .cart-ram-socket.non-empty)
     *   (#ChipBank .ram)
     * Droppable ->
     *   (#CartBank .openCart .cart-ram-socket.empty)
     *   (#ChipBank)
     */

  Ss,
    /* Grabbable ->
     *   (#CartBank .openCart .cart-ss-socket.non-empty)
     *   (#ChipBank .ss)
     * Droppable ->
     *   (#CartBank .openCart .cart-ss-socket.empty)
     *   (#ChipBank)
     */

  File,
    /* Droppable ->
     *   (#CartBank)
     *   (#ChipBank)
     * Grabbable ->
     *   (Out of browser)
     */
}

enum ChipType {
  Ram,
  Ss,
}

enum Location {
  DetachedChipBank,
  CartBank,
  GameBoy,
}

enum CartLocation {
  CartBank,
  GameBoy,
}

// Some Jquery getters
Js.JsObject _jsObjectOfJQueryObject(Js.JsObject jqElt) =>
  new Js.JsObject.fromBrowserObject(jqElt['context']);

dynamic _instanceOfJQueryObject(jqob) =>
  _jsObjectOfJQueryObject(jqob)['chipInstance'];

// Simple interface for Chip
abstract class IChip
{

  bool get locked;
  Html.ImageElement get elt;
  ChipType get type;
  Emufiledb.ProxyEntry get prox;
  void lock();
  void unlock();

  set parent(AChipBank p);
  Ft.Option<AChipBank> get parent;
}

// Abstract class for a monadic `Chip` container that
//   may have `[1, inf[` chip capacity.
// jQuery's `Droppable` target for chips
abstract class AChipBank
{
  bool _procedureLocked = false;

  Location get loc;
  bool get full;
  bool get empty;
  bool get locked;
  Html.Element get elt;
  Ft.Option<Emufiledb.ProxyEntry> get cartProx;
  Ft.Option<int> get slot;

  bool acceptType(ChipType t); // Is a type check only, not a capacity check
  void pop(IChip c);
  void push(IChip c);

  Async.Future _chipTransferAsync(IChip c) async {

    final AChipBank parent = c.parent.v;
    final cartProxOpt = this.cartProx;
    final slotOpt = this.slot;

    if (cartProxOpt.isNone)
      await g_dbProxy.detach(c.prox);
    else if (cartProxOpt.isSome)
      await g_dbProxy.join(c.prox, cartProxOpt.v, slotOpt.v);
    c.parent.v.pop(c);
    this.push(c);
  }

  void _chipTransfer(IChip c) {
    final AChipBank parent = c.parent.v;

    c.lock();
    _procedureLocked = true;
    parent._procedureLocked = true;

    _chipTransferAsync(c)
      ..catchError((e) {
            //TODO: .log to .logwarn
            Ft.log('${this.runtimeType}', 'onDrop#transer-failed', [e]);
          })
      ..whenComplete(() {
        c.unlock();
        _procedureLocked = false;
        parent._procedureLocked = false;
      });
  }

  void onDrop(Js.JsObject event, Js.JsObject ui)
  {
    Ft.log('${this.runtimeType}', 'onDrop');
    final target = event['target'];

    if (!_procedureLocked && target == this.elt) {
      final IChip c = _instanceOfJQueryObject(ui['draggable']);

      assert(c.parent.isSome,
          "AChipBank._onDrop() missing parent field in Chip");

      _chipTransfer(c);
    }
  }

  bool isAcceptable(Js.JsObject jqob)
  {
    final c = _instanceOfJQueryObject(jqob);

    if (_procedureLocked)
      return false;
    if (c is IChip) {
      assert(c.parent.isSome);
      //TODO: check g_dbProxy for match
      return this.full != true && this.locked != true
        && this.acceptType(c.type) && c.parent.v != this;
    }
    else
      return false;
  }

}

// Simple interface for Cart
abstract class ICart
{

  Html.Element get elt;
  Emufiledb.ProxyEntry get prox;

  void setLocation(CartLocation loc);
  void collapse();

  set parent(ACartBank p);
  Ft.Option<ACartBank> get parent;
}

// Abstract class for a monadic `Cart` container that
//   may have `[1, inf[` cart capacity.
// jQuery's `Droppable` target for carts
abstract class ACartBank
{
  bool get full;
  bool get empty;
  Html.Element get elt;

  void pop(ICart c);
  void push(ICart c);

  void onDrop(Js.JsObject event, Js.JsObject ui)
  {
    Ft.log('${this.runtimeType}', 'onDrop');
    final target = event['target'];

    if (target == this.elt) {
      final ICart c = _instanceOfJQueryObject(ui['draggable']);

      assert(c.parent.isSome,
          "ACartBank._onDrop() missing parent field in Cart");
      c.parent.v.pop(c);
      this.push(c);
    }
  }

  bool isAcceptable(Js.JsObject jqob)
  {
    final c = _instanceOfJQueryObject(jqob);

    if (c is ICart) {
      assert(c.parent.isSome);
      return this.full != true && c.parent.v != this;
    }
    else
      return false;
  }

}

void ftdump(name, obj) //debug
{
  print('$name: ($obj), (${obj.runtimeType}), (${obj.hashCode})');
  Js.context['console'].callMethod('log', [obj]);
}
