// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_bank.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/05 12:21:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/05 14:22:38 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

// import 'package:emulator/constants.dart';
// import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

String _cartHtml;
final Html.NodeValidatorBuilder _domCartValidator =
  new Html.NodeValidatorBuilder()
  ..allowHtml5()
  ..allowElement('button', attributes: ['href', 'data-parent', 'data-toggle'])
  ..allowElement('th', attributes: ['style'])
  ..allowElement('tr', attributes: ['style'])
  ;
final _DomCartAccordion _accor = new _DomCartAccordion();

/*
 * Internal Methods
 */

callJQueryMethodOnDartElement(Html.Element e, String name, List params)
{
  var jse = new Js.JsObject.fromBrowserObject(e);
  var jqe = Js.context.callMethod(r'$', [jse]);

  jqe.callMethod(name, new Js.JsObject.jsify(params));
}

class _DomCart {

  static int _ids = 0;
  final int id = _ids++;

  bool _hidden = true;
  bool get hidden => _hidden;

  final Html.DivElement panel = new Html.Element.html(
      _cartHtml, validator: _domCartValidator);

  _DomCart()
  {
    Ft.log('cart_bank', '_DomCart');
    final bodyName = 'cart${this.id}-body';

    this.panel.querySelector('.bg-head-btn')
      .setAttribute('href', '#$bodyName');
    this.panel.querySelector('.panel-collapse')
      .id = bodyName;

    print( '#$bodyName .cart-ss-bis');
    this.panel.querySelectorAll('.cart-ss-bis').forEach((e){
          callJQueryMethodOnDartElement(e, 'draggable', [{
            'helper': "original",
            'revert': true,
            'revertDuration': 50,
            'cursorAt': { 'left': 44, 'top': 26 },
            'distance': 20,
            'cursor': "crosshair",
            'zIndex': "100",
          }]);
        });
    callJQueryMethodOnDartElement(
        this.panel.querySelector('.cart-ram-bis'), 'draggable', [{
          'helper': "original",
          'revert': true,
          'revertDuration': 50,
          'cursorAt': { 'left': 92, 'top': 26 },
          'distance': 20,
          'cursor': "crosshair",
          'zIndex': "100",
        }]);
    callJQueryMethodOnDartElement(this.panel, 'draggable', [{
      'helper': "original",
      'revert': true,
      'revertDuration': 50,
      'cursorAt': { 'left': 125, 'top': 30 },
      'distance': 75,
      'cursor': "crosshair",
      'zIndex': "100",
    }]);

    return ;
  }

}

class _DomCartAccordion {


  List<_DomCart> _domCarts = [];
  final Html.DivElement _div = Html.querySelector('#accordion');

  static bool _instanciated = false;
  _DomCartAccordion()
  {
    assert(_instanciated == false, "_DomCartAccordion()");
    _instanciated = true;
    assert(_div != null, "_DomCartAccordion._div");


  }

  testAdd()
  {
    _domCarts.add(new _DomCart());
    _div.nodes = _domCarts.map((dc) => dc.panel);
  }

}

/*
 * Exposed Methods
 */

Async.Future init(Emulator.Emulator emu) async {
  Ft.log('cart_bank', 'init');

  await (
      Html.HttpRequest.getString("cart_table.html")
      ..then(
          (resp){
            Ft.log('cart_bank', 'HttpRequest.then', 'content...');
            _cartHtml = resp;
          })
      ..catchError((e){
            Ft.log('cart_bank', 'HttpRequest.getString()..catchError', e);
          })
         );
  _accor.testAdd();
  _accor.testAdd();
  _accor.testAdd();
  return ;
}

main () {
  print('Hello World');

  init(null);
}