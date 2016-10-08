// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   chip.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 14:35:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/15 19:13:55 by ngoguey          ###   ########.fr       //
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
import './cart.dart';

class Chip implements IChip {

  final ChipType _type;
  final Html.ImageElement _elt;
  final Js.JsObject _jsObject;
  final Js.JsObject _jqObject;
  final Emufiledb.ProxyEntry _prox;

  bool _locked = true;
  Ft.Option<AChipBank> _parent = new Ft.Option<AChipBank>.none();

  // Construction *********************************************************** **

  static _img(String c)
  {
    return new Html.ImageElement()
      ..setAttribute('draggable', 'true')
      ..classes.addAll(["cart-$c-bis", "ui-widget-content"]);
  }

  Chip.detail(this._type, this._prox, elt, imgSrc, left)
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

  Chip.ram(Emufiledb.ProxyEntry prox)
    : this.detail(ChipType.Ram, prox, _img('ram'), "images/gb_ram.png", 92);
  Chip.ss(Emufiledb.ProxyEntry prox)
    : this.detail(ChipType.Ss, prox, _img('ss'), "images/gb_ss.png", 44);

  // From IChip ************************************************************* **

  Html.ImageElement get elt => _elt;
  bool get locked => _locked;
  ChipType get type => _type;
  Emufiledb.ProxyEntry get prox => _prox;

  set parent(AChipBank p) {
    _parent = new Ft.Option<AChipBank>.some(p);
  }

  Ft.Option<AChipBank> get parent => _parent;

  void lock()
  {
    _jqObject.callMethod('draggable', ['disable']);
    _locked = true;
  }

  void unlock()
  {
    _jqObject.callMethod('draggable', ['enable']);
    _locked = false;
  }

}
