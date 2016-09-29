// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_drag_drop.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 18:08:03 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 18:35:14 by ngoguey          ###   ########.fr       //
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
// import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerDragDrop {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomComponentStorage _pdcs;
  final PlatformComponentEvents _pce;
  final PlatformDomEvents _pde;

  // CONSTRUCTION *********************************************************** **
  static HandlerDragDrop _instance;

  factory HandlerDragDrop(pdcs, pde, pce) {
    if (_instance == null)
      _instance = new HandlerDragDrop._(pdcs, pde, pce);
    return _instance;
  }

  HandlerDragDrop._(this._pdcs, this._pde, this._pce) {
    Ft.log('HandlerDragDrop', 'contructor');

    _pde.onDragStart.forEach(_onDragStart);
    _pde.onDragStop.forEach(_onDragStop);
    _pde.onDropReceived.forEach(_onDropReceived);
  }

  // CALLBACKS ************************************************************** **
  void _onDragStart(HtmlDraggable that) {
    _pdcs.draggedArrival(that as DomComponent);
  }

  void _onDragStop(HtmlDraggable that) {
    _pdcs.draggedDismissal();
  }

  // Filtering impossible drops such as:
  //  - stacked drop-zone of different types
  //  - chip dropped on incompatible chip-socket
  void _onDropReceived(HtmlDropZone that) {
    assert(_pdcs.dragged.isSome, '_onDropReceived() with none dragged');
    if (_pdcs.dragged.v is DomCart && that is CartBank) {
      if (that is DomGameBoySocket)
        _pdcs.gbCartArrival(_pdcs.dragged.v);
      else
        _pdcs.gbCartDismissal();
    }
    // else if (_pdcs.dragged.v is DomChip && that is ChipBank) {
    //   //TODO implement
    // }
  }

}

// abstract class HtmlDropZoneFaceController<HtmlDraggableSubClass, HtmlDropZoneSubClass> {

//   // ATTRIBUTES ************************************************************* **
//   HtmlDraggable _draggedOpt;
//   List<HtmlDropZone> _monitoredHtmlDropZoneList;

//   // CONSTRUCTION *********************************************************** **
//   void init() {
//     Ft.log('HtmlDropZoneFaceController', 'init');
//     g_csc.onDragStart
//       .where((HtmlDraggable d) => d is HtmlDraggableSubClass).forEach(_onDragStart);
//     g_csc.onDragStop
//       .where((HtmlDraggable d) => d is HtmlDraggableSubClass).forEach(_onDragStop);
//     g_csc.onHtmlDropZoneEntered
//       .where((HtmlDropZone d) => d is HtmlDropZoneSubClass).forEach(_onHtmlDropZoneEntered);
//     g_csc.onHtmlDropZoneLeaved
//       .where((HtmlDropZone d) => d is HtmlDropZoneSubClass).forEach(_onHtmlDropZoneLeaved);

//     // TODO:
//     // Need to dynamically update _monitoredHtmlDropZoneList
//   }

//   // CALLBACKS ************************************************************** **
//   void _onDragStart(HtmlDraggable that) {
//     assert(_draggedOpt == null, "_onDragStop() with some dragged");
//     _draggedOpt = that;

//     // TODO:
//     // Need to match all `_monitoredHtmlDropZoneList` to `that`

//     // Gather booleans for suitability
//     // Gather tooltip messages for unsuitable ones
//     // Do this asynchronously
//   }

//   void _onDragStop(HtmlDraggable that) {
//     assert(that == _draggedOpt, '_onDragStop() with strange parameter($that)');
//     _draggedOpt = null;
//   }

//   void _onHtmlDropZoneEntered(HtmlDropZone that) {
//     assert(_monitoredHtmlDropZoneList.contains(that)
//         , "_onHtmlDropZoneEntered() with strange parameter($that)");
//   }

//   void _onHtmlDropZoneLeaved(HtmlDropZone that) {
//     assert(_monitoredHtmlDropZoneList.contains(that)
//         , "_onHtmlDropZoneLeaved() with strange parameter($that)");
//   }

//   // PRIVATE **************************************************************** **

// }