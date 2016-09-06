// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cart_bank.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/05 12:21:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/06 10:35:13 by ngoguey          ###   ########.fr       //
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
import './chips.dart' as Chips;

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

/*
 * Internal Methods
 */
// callJQueryMethodOnDartElement(this.panel, 'draggable', [{
//   'helper': "original",
//   'revert': true,
//   'revertDuration': 50,
//   'cursorAt': { 'left': 125, 'top': 30 },
//   'distance': 75,
//   'cursor': "crosshair",
//   'zIndex': "100",
// }]);

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
  try {
    var cab = new Chips.CartBank(_cartHtml, _domCartValidator);
    cab.testAdd();
    cab.testAdd();
    cab.testAdd();

    var dcb = new Chips.DetachedChipBank();
    var cList = [dcb.newRam(), dcb.newRam(), dcb.newSs()];

    print(cab);
    print(cab.carts[1]);
    print(cab.carts[1].ssSockets[1]);

    cList[2].changeBank(
        cab.carts[1].ssSockets[1]
                        );
    cList[1].changeBank(
        cab.carts[1].ramSocket
                        );

  } catch (e, st) {
    print(e);
    print(st);
  }
  return ;
}

main () {
  print('Hello World');


  init(null);
}