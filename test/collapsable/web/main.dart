// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/08 13:31:53 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/11 16:29:57 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;

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

// String _cartHtml;
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

typedef void _callback_t(key, value);

class _IdbStoreIteratorCallback extends Filedb.IdbStoreIterator {

  final _callback_t _cb;

  _IdbStoreIteratorCallback(Idb.Database db, Filedb.IdbStore v, this._cb)
    : super(db, v, 'readonly');

  void forEach(k, v)
  {
    _cb(k, v);
  }

}

Async.Future init(Emulator.Emulator emu) async {
  Ft.log('main', 'init', [emu]);

  final filedbFut = Filedb.init(emu);
  final cartHtmlFut = Html.HttpRequest.getString("cart_table.html");

  final filedb = await filedbFut;
  final cartHtml = await cartHtmlFut;

  var cab = new CartBank(cartHtml, _domCartValidator);
  var dcb = new DetachedChipBank();
  var gbs = new GameBoySocket();

  // final List iterators = [
  //   new _IdbStoreIteratorCallback(filedb, Filedb.IdbStore.Rom, (k, v){
  //     print('rom $k, $v');
  //   }),
  //   new _IdbStoreIteratorCallback(filedb, Filedb.IdbStore.Ram, (k, v){
  //     print('ram $k, $v');
  //   }),
  //   new _IdbStoreIteratorCallback(filedb, Filedb.IdbStore.Ss, (k, v){
  //     print('ss $k, $v');
  //   }),
  //   new _IdbStoreIteratorCallback(filedb, Filedb.IdbStore.Cart, (k, v){
  //     print('cart $k, $v');
  //   }),
  // ];

  // await Async.Future.wait(iterators.map((it) => it.tra.completed));

  // cab.testAdd();
  // cab.testAdd();
  // cab.testAdd();

  // var cList = [dcb.newRam(), dcb.newRam(), dcb.newSs()];


  return ;
}

main () {
  print('Hello World');

  init(null)
    ..catchError((e, st) {
          print(e);
          print(st);
  });
}