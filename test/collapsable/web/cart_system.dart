// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_system.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 14:48:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/08 13:51:59 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import './component_system.dart';
import './chip_system.dart';

class ChipSocket extends IChipBank {

  final Html.DivElement _elt;
  final Js.JsObject _jsElt;
  final Js.JsObject _jqElt;
  final ChipType chipType;

  CartLocation _cartLoc = CartLocation.CartBank;
  bool _locked = true;

  CartLocation get cartLoc => _cartLoc;
  // Html.Element get elt => _elt;

  Ft.Option<Chip> _chip = new Ft.Option<Chip>.none();

  // Construction *********************************************************** **

  ChipSocket(elt, jsElt, this.chipType, String c)
    : _elt = elt
    , _jsElt = jsElt
    , _jqElt = Js.context.callMethod(r'$', [jsElt])
  {
    _jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      // 'accept': '.cart-$c-bis',
      'accept': _isAcceptable,
      'classes': {
        'ui-droppable-active': 'cart-$c-socket-active',
        'ui-droppable-hover': 'cart-$c-socket-hover',
      },
    })]);
    _jqElt.callMethod('on', ['drop', _onDrop]);
  }

  ChipSocket.ram(elt): this(
      elt, new Js.JsObject.fromBrowserObject(elt), ChipType.Ram, 'ram');
  ChipSocket.ss(elt): this(
      elt, new Js.JsObject.fromBrowserObject(elt), ChipType.Ss, 'ss');

  // From ChipBank ********************************************************** **

  Location get loc =>
    _cartLoc == CartLocation.GameBoy ? Location.GameBoy : Location.CartBank;
  bool get full => _chip.isSome;
  bool get empty => _chip.isNone;
  bool get locked => _locked;

  bool acceptType(ChipType t) => t == this.chipType;

  void pop(Chip c)
  {
    Ft.log('ChipSocket', 'pop', c);
    assert(_chip.isSome && _chip.v == c
        , "ChipSocket.pop($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.none();
    _elt.nodes = [];
  }

  void push(Chip c)
  {
    Ft.log('ChipSocket', 'push', c);
    assert(_chip.isNone
        , "ChipSocket.push($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.some(c);
    c.parent = this;
    _elt.nodes = [_chip.v.elt];
  }

  Js.JsObject _jsObjectOfJQueryObject(Js.JsObject jqElt)
  {
    return new Js.JsObject.fromBrowserObject(jqElt['context']);
  }

  void _onDrop(Js.JsObject event, Js.JsObject ui)
  {
    final Js.JsObject drag = ui['draggable'];
    ftdump("drag", drag);

    final Html.ImageElement cont = drag['context'];
    ftdump("cont", cont);

    final Js.JsObject ob = new Js.JsObject.fromBrowserObject(cont);
    ftdump("ob", ob);

    final Chip cl = ob['chipInstance'];
    ftdump("cl", cl);

    assert(cl.parent.isSome,
        "ChipSocket._onDrop() missing parent field in Chip");

    cl.parent.v.pop(cl);
    this.push(cl);
  }

  bool _isAcceptable(Js.JsObject jqob)
  {
    final Chip c = _jsObjectOfJQueryObject(jqob)['chipInstance'];

    return this.full != true && this.locked != true && this.acceptType(c.type);
  }

  // ************************************************************************ **

  void lock()
  {
    assert(_locked == false, "ChipSocket.lock() while locked");
    this._locked = true;
    _jqElt.callMethod('droppable', ['disable']);
    if (_chip.isSome)
      _chip.v.lock();
  }

  void unlock()
  {
    assert(_locked == true, "ChipSocket.unlock() while unlocked");
    this._locked = false;
    _jqElt.callMethod('droppable', ['enable']);
    if (_chip.isSome)
      _chip.v.unlock();
  }

}

void ftdump(name, obj)
{
  print('$name: ($obj), (${obj.runtimeType}), (${obj.hashCode})');
  Js.context['console'].callMethod('log', [obj]);
}

class Cart {

  static int _ids = 0;

  final Html.Element _elt;
  final Html.ButtonElement _btn;
  final Js.JsObject _jqBtn;
  final int _id;
  final String _bodyId;
  final ChipSocket _ramSocket;
  final List<ChipSocket> _ssSockets;

  bool _locked = false;
  bool _collapsed = false;
  CartLocation _loc = CartLocation.CartBank;

  ChipSocket get ramSocket => _ramSocket;
  List<ChipSocket> get ssSockets => _ssSockets;
  bool get locked => _locked;
  int get id => _id;
  CartLocation get loc => _loc;
  Html.Element get elt => _elt;

  // Construction *********************************************************** **

  static _ramSocketOfElt(elt)
  {
    final ramElt = elt.querySelector('.cart-ram-socket');

    return new ChipSocket.ram(ramElt);
  }

  static _ssSocketsOfElt(elt)
  {
    final ssElts = elt.querySelectorAll('.cart-ss-socket');
    var l = [];

    for (int i = 0; i < 4; i++) {
      l.add(new ChipSocket.ss(ssElts[i]));
    }
    return new List<ChipSocket>.unmodifiable(l);
  }

  Cart.elements(elt, btn)
    : _elt = elt
    , _btn = btn
    , _jqBtn = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(btn)])
    , _id = _ids++
    , _bodyId = 'cart${_ids - 1}Param-body'
    , _ramSocket = _ramSocketOfElt(elt)
    , _ssSockets = _ssSocketsOfElt(elt)
  {
    var body = elt.querySelector('.panel-collapse');
    var jqBody = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(body)]);

    _btn.setAttribute('href', '#$_bodyId');
    jqBody.callMethod('on', ['shown.bs.collapse', _onOpenned]);
    jqBody.callMethod('on', ['hide.bs.collapse', _onCollapsed]);

    _makeCollapsable();
  }
  Cart.element(elt): this.elements(elt, elt.querySelector('.bg-head-btn'));

  Cart(String cartHtml, Html.NodeValidator v) : this.element(
      new Html.Element.html(cartHtml, validator: v));

  // ************************************************************************ **

  void setLocation(CartLocation loc)
  {
    assert(loc != _loc, "Cart.setLocation($loc)");
    _loc = loc;
    if (_loc == CartLocation.CartBank) {
      _makeCollapsable();
      _unlock();
    }
    else {
      _unmakeCollapsable();
      _lock();
    }
  }

  void _onCollapsed(_)
  {
    _collapsed = true;
    _lock();
  }

  void _onOpenned(_)
  {
    _collapsed = false;
    _unlock();
  }

  // ************************************************************************ **

  void _makeCollapsable()
  {
    _elt.querySelector('.panel-collapse')
      .id = _bodyId;
    _btn.disabled = false;
  }

  void _unmakeCollapsable()
  {
    _elt.querySelector('.panel-collapse')
      .id = null;
    _btn.disabled = true;
  }

  void _lock()
  {
    // assert(_locked == false, "Cart.lock() while locked");
    _locked = true;
    _ramSocket.lock();
    _ssSockets.forEach((p) => p.lock());
  }

  void _unlock()
  {
    // assert(_locked == true, "Cart.unlock() while unlocked");
    _locked = false;
    _ramSocket.unlock();
    _ssSockets.forEach((p) => p.unlock());
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
