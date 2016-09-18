// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   controller_cart_system.dart                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/18 17:31:14 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 17:38:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './mixin_assembly.dart';
import './html_draggable.dart';
import './html_cart_closable.dart';
import './html_dropzone.dart';
import './controller_html_cart_closable.dart';

class ControllerCartSystem {

  // SUB CONTROLLERS ******************************************************** **
  final ControllerHtmlCartClosable _ccc = new ControllerHtmlCartClosable();

  // CONTRUCTION ************************************************************ **
  static int _instanceCount = 0;
  ControllerCartSystem._()
  {
    assert(_instanceCount++ == 0);
  }

  // PUBLIC ***************************************************************** **
  Async.Future init() async {
    Ft.log('ControllerCartSystem', 'init');
    _ccc.init();
  }

  // STREAMS **************************************************************** **
  // Notified by HtmlCartClosable
  final Async.StreamController<DomCart> _cartButtonClicked =
    new Async.StreamController<DomCart>.broadcast();
  void cartButtonClicked(DomCart that) => _cartButtonClicked.add(that);
  Async.Stream<DomCart> get onCartButtonClicked => _cartButtonClicked.stream;

  final Async.StreamController<DomCart> _cartDoneOpening =
    new Async.StreamController<DomCart>.broadcast();
  void cartDoneOpening(DomCart that) => _cartDoneOpening.add(that);
  Async.Stream<DomCart> get onCartDoneOpening => _cartDoneOpening.stream;

  // Notified by ControllerHtmlCartClosable
  final Async.StreamController<DomCart> _cartOpenedOpt =
    new Async.StreamController<DomCart>.broadcast();
  void cartOpenedOpt(DomCart that) => _cartOpenedOpt.add(that);
  Async.Stream<DomCart> get onCartOpenedOpt => _cartOpenedOpt.stream;

  // Notified by HtmlDraggable
  final Async.StreamController<HtmlDraggable> _dragStart =
    new Async.StreamController<HtmlDraggable>.broadcast();
  void dragStart(HtmlDraggable that) => _dragStart.add(that);
  Async.Stream<HtmlDraggable> get onDragStart => _dragStart.stream;

  final Async.StreamController<HtmlDraggable> _dragStop =
    new Async.StreamController<HtmlDraggable>.broadcast();
  void dragStop(HtmlDraggable that) => _dragStop.add(that);
  Async.Stream<HtmlDraggable> get onDragStop => _dragStop.stream;

  // Notified by HtmlDropZone
  final Async.StreamController<HtmlDropZone> _dropReceived =
    new Async.StreamController<HtmlDropZone>.broadcast();
  void dropReceived(HtmlDropZone that) => _dropReceived.add(that);
  Async.Stream<HtmlDropZone> get onDropReceived => _dropReceived.stream;

  final Async.StreamController<HtmlDropZone> _dropEntered =
    new Async.StreamController<HtmlDropZone>.broadcast();
  void dropEntered(HtmlDropZone that) => _dropEntered.add(that);
  Async.Stream<HtmlDropZone> get onDropEntered => _dropEntered.stream;

  final Async.StreamController<HtmlDropZone> _dropLeaved =
    new Async.StreamController<HtmlDropZone>.broadcast();
  void dropLeaved(HtmlDropZone that) => _dropLeaved.add(that);
  Async.Stream<HtmlDropZone> get onDropLeaved => _dropLeaved.stream;

  // Notified by CartDragDropController
  // Notified by ????
  final Async.StreamController<DomCart> _cartNew =
    new Async.StreamController<DomCart>.broadcast();
  void cartNew(DomCart that) => _cartNew.add(that);
  Async.Stream<DomCart> get onCartNew => _cartNew.stream;

  final Async.StreamController<DomCart> _cartInGbOpt =
    new Async.StreamController<DomCart>.broadcast();
  void cartInGbOpt(DomCart that) => _cartInGbOpt.add(that);
  Async.Stream<DomCart> get onCartInGbOpt => _cartInGbOpt.stream;


}

Async.Future<ControllerCartSystem> make() async {
  Ft.log('ControllerCartSystem', 'make');

  return new ControllerCartSystem._();
}
