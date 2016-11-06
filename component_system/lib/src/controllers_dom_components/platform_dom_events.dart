// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_events.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 17:46:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 19:05:49 by ngoguey          ###   ########.fr       //
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


  final Async.StreamController<bool> _fileDrag =
    new Async.StreamController<bool>.broadcast();
  void fileDrag(bool that) => _fileDrag.add(that);
  Async.Stream<bool> get onFileDrag => _fileDrag.stream;

  final Async.StreamController<bool> _cartSystemFileHover =
    new Async.StreamController<bool>.broadcast();
  void cartSystemFileHover(bool that) => _cartSystemFileHover.add(that);
  Async.Stream<bool> get onCartSystemFileHover => _cartSystemFileHover.stream;

  final Async.StreamController<List<Html.File>> _cartSystemFilesDrop =
    new Async.StreamController<List<Html.File>>.broadcast();
  void cartSystemFilesDrop(List<Html.File> that) => _cartSystemFilesDrop.add(that);
  Async.Stream<List<Html.File>> get onCartSystemFilesDrop => _cartSystemFilesDrop.stream;


  final Async.StreamController<DomComponent> _dropDownClick =
    new Async.StreamController<DomComponent>.broadcast();
  void dropDownClick(DomComponent that) => _dropDownClick.add(that);
  Async.Stream<DomComponent> get onDropDownClick => _dropDownClick.stream;

  final Async.StreamController<DomChip> _requestInstallSaveState =
    new Async.StreamController<DomChip>.broadcast();
  void requestInstallSaveState(DomChip that) => _requestInstallSaveState.add(that);
  Async.Stream<DomChip> get onRequestInstallSaveState => _requestInstallSaveState.stream;

  final Async.StreamController<DomChip> _requestExtractSaveState =
    new Async.StreamController<DomChip>.broadcast();
  void requestExtractSaveState(DomChip that) => _requestExtractSaveState.add(that);
  Async.Stream<DomChip> get onRequestExtractSaveState => _requestExtractSaveState.stream;

  final Async.StreamController<DomChip> _requestSaveToFile =
    new Async.StreamController<DomChip>.broadcast();
  void requestSaveToFile(DomChip that) => _requestSaveToFile.add(that);
  Async.Stream<DomChip> get onRequestSaveToFile => _requestSaveToFile.stream;

  final Async.StreamController<DomChip> _requestDetach =
    new Async.StreamController<DomChip>.broadcast();
  void requestDetach(DomChip that) => _requestDetach.add(that);
  Async.Stream<DomChip> get onRequestDetach => _requestDetach.stream;

  final Async.StreamController<DomChip> _requestDuplicate =
    new Async.StreamController<DomChip>.broadcast();
  void requestDuplicate(DomChip that) => _requestDuplicate.add(that);
  Async.Stream<DomChip> get onRequestDuplicate => _requestDuplicate.stream;

  final Async.StreamController<DomComponent> _requestDelete =
    new Async.StreamController<DomComponent>.broadcast();
  void requestDelete(DomComponent that) => _requestDelete.add(that);
  Async.Stream<DomComponent> get onRequestDelete => _requestDelete.stream;

  final Async.StreamController<DomCart> _requestInsert =
    new Async.StreamController<DomCart>.broadcast();
  void requestInsert(DomCart that) => _requestInsert.add(that);
  Async.Stream<DomCart> get onRequestInsert => _requestInsert.stream;

  final Async.StreamController<DomCart> _requestEject =
    new Async.StreamController<DomCart>.broadcast();
  void requestEject(DomCart that) => _requestEject.add(that);
  Async.Stream<DomCart> get onRequestEject => _requestEject.stream;

}
