// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   component_system.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 14:48:01 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/08 14:39:33 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

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

// Simple interface for Chip
abstract class IChip {

  bool get locked;
  Html.ImageElement get elt;
  ChipType get type;
  void lock();
  void unlock();

  set parent(AChipBank p);
  Ft.Option<AChipBank> get parent;

}

// Monadic `Chip` container, may have `[1, inf[` chip capacity
// jQuery's `Droppable` target for chips
abstract class AChipBank {

  Location get loc;
  bool get full;
  bool get empty;
  bool get locked;

  bool acceptType(ChipType t); // Type check only, not a capacity check
  void pop(IChip c);
  void push(IChip c);

  Js.JsObject _jsObjectOfJQueryObject(Js.JsObject jqElt) =>
    new Js.JsObject.fromBrowserObject(jqElt['context']);

  IChip _chipOfJQueryObject(jqob) =>
    _jsObjectOfJQueryObject(jqob)['chipInstance'];

  void onDrop(_, Js.JsObject ui)
  {
    final IChip c = _chipOfJQueryObject(ui['draggable']);

    assert(c.parent.isSome,
        "AChipBank._onDrop() missing parent field in Chip");
    c.parent.v.pop(c);
    this.push(c);
  }

  bool isAcceptable(Js.JsObject jqob)
  {
    final IChip c = _chipOfJQueryObject(jqob);

    assert(c.parent.isSome);
    return this.full != true && this.locked != true
      && this.acceptType(c.type) && c.parent.v != this;
  }

}
