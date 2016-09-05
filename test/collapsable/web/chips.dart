// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   chips.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/05 15:47:53 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/05 19:42:42 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import './dom_state.dart' as State;

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

callJQueryMethodOnDartElement(Html.Element e, String name, List params)
{
  var jse = new Js.JsObject.fromBrowserObject(e);
  var jqe = Js.context.callMethod(r'$', [jse]);

  jqe.callMethod(name, new Js.JsObject.jsify(params));
}

class Chip {

  final ChipType _type;
  ChipBank _bank;
  ChipBank get bank => _bank;
  Location get loc => _bank.loc;
  final Html.ImageElement elt = new Html.ImageElement()
    ..setAttribute('draggable', 'true')
    ..classes.addAll(["cart-ram-bis", "ui-widget-content"]);

  Chip.details(this._bank, this._type, src, left)
  {
    this.elt.src = src;
    callJQueryMethodOnDartElement(this.elt, 'draggable', [{
      'helper': "original",
      'revert': true,
      'revertDuration': 50,
      'cursorAt': { 'left': left, 'top': 26 },
      'distance': 20,
      'cursor': "crosshair",
      'zIndex': "100",
    }]);
  }

  Chip.ram(b) : this.details(b, ChipType.Ram, "images/gb_ram.png", 92);
  Chip.ss(b) : this.details(b, ChipType.Ss, "images/gb_ss.png", 44);

  void changeBank(ChipBank b)
  {
    Ft.log('Chip', 'changeBank', b);
    assert(_bank.enabled
        , "Chip.changeBank($b) with disabled Bank source $_bank"
           );
    assert(b.enabled
        , "Chip.changeBank($b) with disabled Bank target"
           );
    assert(b.acceptType(_type)
        , "Chip.changeBank($b) does not accept $_type"
           );
    assert(!b.full
        , "Chip.changeBank($b) is full"
           );
    _bank.pop(this);
    _bank = b;
    _bank.push(this);
  }

}

// Monadic `Chip` container, may have `[1, inf[` chip capacity
// jQuery's `Droppable` target.
abstract class ChipBank {

  Location get loc;
  bool get full;
  bool get empty;
  bool get acceptRam; // Type check only, not a capacity check
  bool get acceptSs; // Type check only, not a capacity check
  bool get enabled;

  bool acceptType(ChipType t); // Type check only, not a capacity check
  void pop(Chip c);
  void push(Chip c);

}

class DetachedChipBank extends ChipBank {

  List<Chip> _chips = [];
  final Html.Element _elt = Html.querySelector('#detached-chip-bank');

  DetachedChipBank();

  Location get loc => Location.DetachedChipBank;
  bool get full => false;
  bool get empty => _chips.isEmpty;
  bool get acceptRam => true;
  bool get acceptSs => true;
  bool get enabled => true;

  bool acceptType(ChipType t) => true;
  void pop(Chip toPop)
  {
    Ft.log('DetachedChipBank', 'pop', toPop);
    final bool poped = _chips.remove(toPop);

    assert(poped
        , "DetachedChipBank.pop($toPop) not found"
           );
    _elt.nodes = _chips.map((c) => c.elt);
  }

  void push(Chip toPush)
  {
    Ft.log('DetachedChipBank', 'push', toPush);
    assert(!_chips.contains(toPush)
        , "DetachedChipBank.push($toPush) already in"
           );
    _chips.add(toPush);
    _elt.nodes = _chips.map((c) => c.elt);
  }

  Chip newRam()
  {
    var c = new Chip.ram(this);
    this.push(c);
    return c;
  }
  Chip newSs()
  {
    var c = new Chip.ss(this);
    this.push(c);
    return c;
  }

}

class CartSocket extends ChipBank {

  Ft.Option<Chip> _chip = new Ft.Option<Chip>.none();
  final Cart _parent;
  final Html.Element _elt;
  final int _id;
  final ChipType chipType;

  CartSocket(this._parent, this._elt, this._id, this.chipType);

  Location get loc =>
    _parent.loc == CartLocation.GameBoy ? Location.GameBoy : Location.CartBank;
  bool get full => _chip.isSome;
  bool get empty => _chip.isNone;
  bool get acceptRam => this.chipType == ChipType.Ram;
  bool get acceptSs => this.chipType == ChipType.Ss;
  bool get enabled => _parent.enabled;

  CartLocation get cartLoc => _parent.loc;

  bool acceptType(ChipType t) => t == this.chipType;
  void pop(Chip c)
  {
    Ft.log('CartSocket', 'pop', c);
    assert(_parent.enabled
        , "CartSocket.pop($c) with disabled parent $_parent"
           );
    assert(_chip.isSome && _chip.v == c
        , "CartSocket.pop($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.none();
    _elt.nodes = [];
  }

  void push(Chip c)
  {
    Ft.log('CartSocket', 'push', c);
    assert(_parent.enabled
        , "CartSocket.push($c) with disabled parent $_parent"
           );
    assert(_chip.isNone
        , "CartSocket.push($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.some(c);
    _elt.nodes = [_chip.v.elt];
  }
}

class Cart {

  final Html.Element elt;
  CartSocket _ramSocket;
  CartSocket get ramSocket => _ramSocket;

  final List<CartSocket> ssSockets = new List(4);

  static int _ids = 0;
  final int id;
  final String _bodyId;

  bool _enabled = true; //dynamic with collapse status
  bool get enabled => _enabled;

  CartLocation _loc = CartLocation.CartBank;
  CartLocation get loc => _loc;

  Cart.element(eltParam, idParam)
    : elt = eltParam
    , id = idParam
    , _bodyId = 'cart$idParam-body'
  {
    final ramElt = elt.querySelector('.cart-ram-socket');
    final ssElts = elt.querySelectorAll('.cart-ss-socket');
    var btn = elt.querySelector('.bg-head-btn');

    print(elt);
    print(ssElts);
    print(ramElt);
    _ramSocket = new CartSocket(this, ramElt, 0, ChipType.Ram);
    for (int i = 0; i < 4; i++) {
      this.ssSockets[i] =
        new CartSocket(this, ssElts[i], i, ChipType.Ss);
      print('bordel: ${ssSockets[i]}');
    }

    btn.setAttribute('href', '#$_bodyId');
    _makeCollapsable();
  }

  Cart(String cartHtml, Html.NodeValidator v) : this.element(
      new Html.Element.html(cartHtml, validator: v), _ids++);

  void _makeCollapsable()
  {
    var btn = this.elt.querySelector('.bg-head-btn');

    btn.disabled = false;
    this.elt.querySelector('.panel-collapse')
      .id = _bodyId;
  }

  void _unmakeCollapsable()
  {
    var btn = this.elt.querySelector('.bg-head-btn');

    btn.disabled = true;
    this.elt.querySelector('.panel-collapse')
      .id = null;
  }

}

class CartBank {

  List<Cart> _carts = [];
  List<Cart> get carts => _carts;

  final Html.DivElement _elt = Html.querySelector('#accordion');

  final String _cartHtml;
  final Html.NodeValidator _validator;

  static bool _instanciated = false;
  CartBank(this._cartHtml, this._validator)
  {
    assert(_instanciated == false, "CartBank()");
    _instanciated = true;
    assert(_elt != null, "CartBank._elt");

  }

  testAdd() {
    _carts.add(new Cart(_cartHtml, _validator));
    _elt.nodes = _carts.map((c) => c.elt);

  }

}
