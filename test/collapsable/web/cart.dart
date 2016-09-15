// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 14:31:31 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 16:18:02 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/filedb.dart' as Emufiledb;

import './component_system.dart';
import './component_system_dom.dart';
import './chip.dart';

class ChipSocket extends AChipBank {

  final Html.DivElement _elt;
  final Js.JsObject _jsElt;
  final Js.JsObject _jqElt;
  final ChipType chipType;

  CartLocation _cartLoc = CartLocation.CartBank;
  bool _locked = true;

  CartLocation get cartLoc => _cartLoc;

  Ft.Option<Chip> _chip = new Ft.Option<Chip>.none();

  // Construction *********************************************************** **

  ChipSocket(elt, jsElt, this.chipType, String c)
    : _elt = elt
    , _jsElt = jsElt
    , _jqElt = Js.context.callMethod(r'$', [jsElt])
  {
    _jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'accept': this.isAcceptable,
      'greedy': true,
      'classes': {
        'ui-droppable-active': 'cart-$c-socket-active',
        'ui-droppable-hover': 'cart-$c-socket-hover',
      },
    })]);
    _jqElt.callMethod('on', ['drop', this.onDrop]);
  }

  ChipSocket.ram(elt): this(
      elt, new Js.JsObject.fromBrowserObject(elt), ChipType.Ram, 'ram');
  ChipSocket.ss(elt): this(
      elt, new Js.JsObject.fromBrowserObject(elt), ChipType.Ss, 'ss');

  // From AChipBank ********************************************************* **

  Location get loc =>
    _cartLoc == CartLocation.GameBoy ? Location.GameBoy : Location.CartBank;
  bool get full => _chip.isSome;
  bool get empty => _chip.isNone;
  bool get locked => _locked;
  Html.Element get elt => _elt;

  bool acceptType(ChipType t) => t == this.chipType;

  void pop(IChip c)
  {
    Ft.log('ChipSocket', 'pop', c);
    assert(_chip.isSome && _chip.v == c
        , "ChipSocket.pop($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.none();
    _elt.nodes = [];
  }

  void push(IChip c)
  {
    Ft.log('ChipSocket', 'push', c);
    assert(_chip.isNone
        , "ChipSocket.push($c) with `_chip.v = ${_chip.v}`"
           );
    _chip = new Ft.Option<Chip>.some(c);
    _elt.nodes = [_chip.v.elt];
    c.elt.style.left = '0px';
    c.elt.style.top = '0px';
    c.parent = this;
  }

  // ************************************************************************ **

  void lock()
  {
    // assert(_locked == false, "ChipSocket.lock() while locked");
    this._locked = true;
    _jqElt.callMethod('droppable', ['disable']);
    if (_chip.isSome)
      _chip.v.lock();
  }

  void unlock()
  {
    // assert(_locked == true, "ChipSocket.unlock() while unlocked");
    this._locked = false;
    _jqElt.callMethod('droppable', ['enable']);
    if (_chip.isSome)
      _chip.v.unlock();
  }

}

class Cart implements ICart {

  static int _ids = 0;

  final Html.Element _elt;
  final Js.JsObject _jqElt;
  final Html.ButtonElement _btn;
  final Js.JsObject _jqBtn;
  final Js.JsObject _jqBody;
  final int _id;
  final String _bodyId;
  final ChipSocket _ramSocket;
  final List<ChipSocket> _ssSockets;
  final Emufiledb.ProxyEntry _prox;

  bool _locked = false;
  bool _collapsed = true;
  CartLocation _loc = CartLocation.CartBank;
  Ft.Option<ACartBank> _parent = new Ft.Option<ACartBank>.none();

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

  Cart._detail2(elt, jsElt, btn, this._prox)
    : _elt = elt
    , _jqElt = Js.context.callMethod(r'$', [jsElt])
    , _btn = btn
    , _jqBtn = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(btn)])
    , _jqBody = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(elt.querySelector('.panel-collapse'))])
    , _id = _ids++
    , _bodyId = 'cart${_ids - 1}Param-body'
    , _ramSocket = _ramSocketOfElt(elt)
    , _ssSockets = _ssSocketsOfElt(elt)
  {
    _btn.setAttribute('href', '#$_bodyId');
    _jqBody.callMethod('on', ['shown.bs.collapse', _onOpenned]);
    _jqBody.callMethod('on', ['hide.bs.collapse', _onCollapsed]);

    _jqElt.callMethod('draggable', [new Js.JsObject.jsify({
      'helper': "original",
      'revert': true,
      'revertDuration': 50,
      'cursorAt': { 'left': 125, 'top': 143 },
      'distance': 75,
      'cursor': "crosshair",
      'zIndex': "99",
      'cancel': "input,textarea,select,option",
    })]);
    jsElt['chipInstance'] = this;

    _updateControls();
    _loadChips();
  }

  Cart._detail1(elt, prox): this._detail2(
      elt, new Js.JsObject.fromBrowserObject(elt),
      elt.querySelector('.bg-head-btn'), prox);

  Cart(String cartHtml, Html.NodeValidator v, Emufiledb.ProxyEntry prox)
    : this._detail1(new Html.Element.html(cartHtml, validator: v), prox);

  Async.Future _loadChips() async {
    final Map<String, dynamic> cartInfo = await g_dbProxy.info(_prox);
    IChip c;

    if (cartInfo['ram'] != null) {
      c = new Chip.ram(g_dbProxy.rams[cartInfo['ram']]);
      _ramSocket.push(c);
    }
  }

  // ICart implementation *************************************************** **

  AChipBank get ramSocket => _ramSocket;
  List<AChipBank> get ssSockets => _ssSockets;
  bool get locked => _locked;
  int get id => _id;
  CartLocation get loc => _loc;
  Html.Element get elt => _elt;

  set parent(ACartBank p) {
    _parent = new Ft.Option<ACartBank>.some(p);
  }

  Ft.Option<ACartBank> get parent => _parent;

  void setLocation(CartLocation loc)
  {
    assert(loc != _loc, "Cart.setLocation($loc)");
    _loc = loc;
    _updateControls();
  }

  void collapse()
  {
    if (_collapsed == false)
      _jqBody.callMethod('collapse', ["hide"]);
  }

  void open()
  {
    if (_collapsed == true)
      _jqBody.callMethod('collapse', ["show"]);
  }

  // ************************************************************************ **

  void _onCollapsed(_)
  {
    _collapsed = true;
    _updateControls();
  }

  void _onOpenned(_)
  {
    _collapsed = false;
    _updateControls();
  }

  /*                   dragGb  ClickBtn  dragSock  dropSock
   * GameBoySocket     true    false     false     false
   * CartBank.closed   false   true      false     false
   * CartBank.shown    true    true      true      true
   */

  void _updateControls()
  {
    if (_loc == CartLocation.GameBoy) {
      allowDragGb();
      denyCollapseUpdate();
      denyChipUpdate();
    }
    else if (_collapsed) {
      denyDragGb();
      allowCollapseUpdate();
      denyChipUpdate();
    }
    else if (!_collapsed) {
      allowDragGb();
      allowCollapseUpdate();
      allowChipUpdate();
    }
    else
      assert(false, "unreachable");
  }

  // ************************************************************************ **

  void allowDragGb()
  {
    _jqElt.callMethod('draggable', ['enable']);

  }
  void denyDragGb()
  {
    _jqElt.callMethod('draggable', ['disable']);

  }
  void allowCollapseUpdate()
  {
    _elt.querySelector('.panel-collapse').id = _bodyId;
    _btn.disabled = false;
  }
  void denyCollapseUpdate()
  {
    _elt.querySelector('.panel-collapse').id = null;
    _btn.disabled = true;
  }
  void allowChipUpdate()
  {
    _ramSocket.unlock();
    _ssSockets.forEach((p) => p.unlock());
  }
  void denyChipUpdate()
  {
    _ramSocket.lock();
    _ssSockets.forEach((p) => p.lock());
  }

}
