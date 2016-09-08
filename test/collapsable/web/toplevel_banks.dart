// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   toplevel_banks.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 14:29:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/08 14:38:57 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import './component_system.dart';
import './cart.dart';
import './chip.dart';
// import './toplevel_banks.dart';

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

class DetachedChipBank extends AChipBank {

  List<Chip> _chips = [];
  final Html.Element _elt = Html.querySelector('#detached-chip-bank');

  // Construction *********************************************************** **

  DetachedChipBank()
  {
    var jqElt = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(_elt)]);

    jqElt.callMethod('droppable', [new Js.JsObject.jsify({
      'accept': this.isAcceptable,
      'classes': {
        'ui-droppable-active': 'chipbank-active',
        'ui-droppable-hover': 'chipbank-hover',
      },
    })]);
    jqElt.callMethod('on', ['drop', this.onDrop]);
  }

  // From ChipBank ********************************************************** **

  Location get loc => Location.DetachedChipBank;
  bool get full => false;
  bool get empty => _chips.isEmpty;
  bool get locked => false;

  bool acceptType(ChipType t) => true;

  void pop(IChip toPop)
  {
    Ft.log('DetachedChipBank', 'pop', toPop);
    final bool poped = _chips.remove(toPop);

    assert(poped
        , "DetachedChipBank.pop($toPop) not found"
           );
    _elt.nodes = _chips.map((c) => c.elt);
  }

  void push(IChip toPush)
  {
    Ft.log('DetachedChipBank', 'push', toPush);
    assert(!_chips.contains(toPush)
        , "DetachedChipBank.push($toPush) already in"
           );
    _chips.add(toPush);
    _elt.nodes = _chips.map((c) => c.elt);
    toPush.elt.style.left = '0px';
    toPush.elt.style.top = '0px';
    toPush.parent = this;
  }

  // ************************************************************************ **

  Chip newRam()
  {
    var c = new Chip.ram();
    this.push(c);
    return c;
  }
  Chip newSs()
  {
    var c = new Chip.ss();
    this.push(c);
    return c;
  }

}
