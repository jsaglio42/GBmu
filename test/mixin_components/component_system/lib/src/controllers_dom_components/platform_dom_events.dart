// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_events.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 17:46:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:58:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_dc.dart';

class PlatformDomEvents {

  // CONTRUCTION ************************************************************ **
  static PlatformDomEvents _instance;

  factory PlatformDomEvents() {
    if (_instance == null)
      _instance = new PlatformDomEvents._();
    return _instance;
  }

  PlatformDomEvents._() {
    Ft.log('PlatformDE', 'contructor', []);
  }

  // PUBLIC ***************************************************************** **
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

  final Async.StreamController<HtmlDropZone> _dropLeft =
    new Async.StreamController<HtmlDropZone>.broadcast();
  void dropLeft(HtmlDropZone that) => _dropLeft.add(that);
  Async.Stream<HtmlDropZone> get onDropLeft => _dropLeft.stream;

  // Notified by PlatformDomComponentStorage
  final Async.StreamController<DomCart> _cartNew =
    new Async.StreamController<DomCart>.broadcast();
  void cartNew(DomCart that) => _cartNew.add(that);
  Async.Stream<DomCart> get onCartNew => _cartNew.stream;

  final Async.StreamController<DomCart> _cartDelete =
    new Async.StreamController<DomCart>.broadcast();
  void cartDelete(DomCart that) => _cartDelete.add(that);
  Async.Stream<DomCart> get onCartDelete => _cartDelete.stream;

  final Async.StreamController<SlotEvent<DomCart>> _openedCartChange =
    new Async.StreamController<SlotEvent<DomCart>>.broadcast();
  void openedCartChange(SlotEvent<DomCart> that) => _openedCartChange.add(that);
  Async.Stream<SlotEvent<DomCart>> get onOpenedCartChange => _openedCartChange.stream;



  // Notified by CartDragDropController
  // Notified by ????

  final Async.StreamController<DomCart> _cartInGbOpt =
    new Async.StreamController<DomCart>.broadcast();
  void cartInGbOpt(DomCart that) => _cartInGbOpt.add(that);
  Async.Stream<DomCart> get onCartInGbOpt => _cartInGbOpt.stream;

  // Async.Stream<LsEntry> get entryDelete {
  //   assert(_entryDelete != null, 'from: PlatformDE.entryDelete');
  //   return _entryDelete;
  // }

  // Async.Stream<LsEntry> get entryNew {
  //   assert(_entryNew != null, 'from: PlatformDE.entryNew');
  //   return _entryNew;
  // }

  // Async.Stream<Update<LsEntry>> get entryUpdate {
  //   assert(_entryUpdate != null, 'from: PlatformDE.entryUpdate');
  //   return _entryUpdate;
  // }


  // CALLBACKS ************************************************************** **

  // PRIVATE **************************************************************** **

}
