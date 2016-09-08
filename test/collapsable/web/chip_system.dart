// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   chip_system.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 14:49:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/08 13:46:36 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import './component_system.dart';
import './cart_system.dart';

abstract class IChip {

  bool get locked;
  Html.ImageElement get elt;
  ChipType get type;
  void lock();
  void unlock();

  set parent(IChipBank p);
  Ft.Option<IChipBank> get parent;

}

class Chip implements IChip {

  final ChipType _type;
  final Html.ImageElement _elt;
  final Js.JsObject _jsObject;
  final Js.JsObject _jqObject;

  bool _locked = true;
  Ft.Option<IChipBank> _parent = new Ft.Option<IChipBank>.none();

  // Construction *********************************************************** **

  static _img(String c)
  {
    return new Html.ImageElement()
      ..setAttribute('draggable', 'true')
      ..classes.addAll(["cart-$c-bis", "ui-widget-content"]);
  }

  Chip.details(this._type, elt, imgSrc, left)
    : _elt = elt
    , _jsObject = new Js.JsObject.fromBrowserObject(elt)
    , _jqObject = Js.context.callMethod(r'$', [
      new Js.JsObject.fromBrowserObject(elt)])
  {
    _jqObject.callMethod('draggable', [new Js.JsObject.jsify({
      'helper': "original",
      'revert': true,
      'revertDuration': 50,
      'cursorAt': { 'left': left, 'top': 26 },
      'distance': 20,
      'cursor': "crosshair",
      'zIndex': "100",
    })]);
    _elt.setAttribute('src', imgSrc);
    _jsObject['chipInstance'] = this;
    this.unlock();
  }

  Chip.ram() : this.details(ChipType.Ram, _img('ram'), "images/gb_ram.png", 92);
  Chip.ss() : this.details(ChipType.Ss, _img('ss'), "images/gb_ss.png", 44);

  // From IChip ************************************************************* **

  Html.ImageElement get elt => _elt;
  bool get locked => _locked;
  ChipType get type => _type;

  set parent(IChipBank p) {
    _parent = new Ft.Option<IChipBank>.some(p);
  }

  Ft.Option<IChipBank> get parent => _parent;

  void lock()
  {
    assert(_locked == false, "Chip.lock() while locked");
    _jqObject.callMethod('draggable', ['disable']);
    _locked = true;
  }

  void unlock()
  {
    assert(_locked == true, "Chip.unlock() while unlocked");
    _jqObject.callMethod('draggable', ['enable']);
    _locked = false;
  }

}

// Monadic `Chip` container, may have `[1, inf[` chip capacity
// jQuery's `Droppable` target.
abstract class IChipBank {

  Location get loc;
  bool get full;
  bool get empty;
  bool get locked;

  bool acceptType(ChipType t); // Type check only, not a capacity check
  void pop(Chip c);
  void push(Chip c);
}

class DetachedChipBank extends IChipBank {

  List<Chip> _chips = [];
  final Html.Element _elt = Html.querySelector('#detached-chip-bank');

  // Construction *********************************************************** **

  DetachedChipBank();

  // From ChipBank ********************************************************** **

  Location get loc => Location.DetachedChipBank;
  bool get full => false;
  bool get empty => _chips.isEmpty;
  bool get locked => false;

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
