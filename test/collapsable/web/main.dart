// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 13:31:53 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/11 11:00:18 by ngoguey          ###   ########.fr       //
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

import './component_system.dart';
import './cart.dart';
import './chip.dart';
import './toplevel_banks.dart';
import './file_db.dart' as Filedb;

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

/*
 * Exposed Methods
 */

Async.Future init(Emulator.Emulator emu) async {
  Ft.log('cart_bank', 'init');

  await Filedb.init(emu);

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
    var cab = new CartBank(_cartHtml, _domCartValidator);
    cab.testAdd();
    cab.testAdd();
    cab.testAdd();

    var dcb = new DetachedChipBank();
    var cList = [dcb.newRam(), dcb.newRam(), dcb.newSs()];

    var gbs = new GameBoySocket();

  } catch (e, st) {
    print(e);
    print(st);
  }
  return ;
}

main () {
  print('Hello World');


  init(null)

    ..catchError((e) {
          print(e);

  });
}