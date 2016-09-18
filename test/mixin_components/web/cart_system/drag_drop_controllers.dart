// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   drag_drop_controllers.dart                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:47:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 15:58:26 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './mixin_interfaces.dart';
import './globals.dart';

// abstract class CartDragDropController {

//   // ATTRIBUTES ************************************************************* **
//   Draggable _inGbOpt;
//   Draggable _openedOpt;
//   Draggable _draggedOpt;

//   // CONSTRUCTION *********************************************************** **
//   void init() {
//     Ft.log('CartDragDropController', 'init');
//     g_csc.onCartOpenedOpt.forEach(_onCartOpenedOpt);
//     g_csc.onDragStart.where((Draggable d) => d is Cart).forEach(_onDragStart);
//     g_csc.onDragStop.where((Draggable d) => d is Cart).forEach(_onDragStop);
//     // g_csc.onDropReceived
//       // .where((DropZone z) => d is TODO).forEach(_onDropReceived);
//   }

//   // CALLBACKS ************************************************************** **
//   void _onCartOpenedOpt(Draggable that) {
//     assert(that != _openedOpt
//         , '_onCartOpenedOpt() with strange parameter($that)');
//     _openedOpt = that;
//   }

//   void _onDragStart(Draggable that) {
//     assert(_draggedOpt == null, "_onDragStop() with some dragged");
//     assert(that == _inGbOpt || that == _openedOpt
//         , '_onDragStart() with strange parameter');
//     _draggedOpt = that;
//   }

//   // Asserts that `stop` occurs after `drop`
//   void _onDragStop(Draggable that) {
//     assert(that == _draggedOpt, '_onDragStop() with strange parameter($that)');
//     _draggedOpt = null;
//   }

//   // At most 2 dropReceived might fire at once, hence `.where()` in `.init()`
//   // Both `GbSocket` and `CartBank` will listen to `onCartInGbOpt` to update
//   //   their nodes. TODO: OR NOT?
//   void _onDropReceived(DropZone that) {
//     assert(_draggedOpt != null, "_onDropReceived() with none dragged");
//     if (_draggedOpt == _openedOpt && that is GameBoySocket) {
//       assert(_inGbOpt == null, "_onDropReceived() to gb with one in");
//       _setInGbOpt(_openedOpt);
//     }
//     else if (_draggedOpt == _inGbOpt && that is CartBank) {
//       _setInGbOpt(null);
//     }
//     else {
//       assert(that is GameBoySocket || that is CartBank
//           , '_onDropReceived() with strange parameter($that)');
//     }
//   }

//   // PRIVATE **************************************************************** **
//   void _setInGbOpt(Draggable that) {
//     _inGbOpt = that;
//     g_csc.cartInGbOpt(that);
//   }

// }

// abstract class DropZoneFaceController<DraggableSubClass, DropZoneSubClass> {

//   // ATTRIBUTES ************************************************************* **
//   Draggable _draggedOpt;
//   List<DropZone> _monitoredDropZoneList;

//   // CONSTRUCTION *********************************************************** **
//   void init() {
//     Ft.log('DropZoneFaceController', 'init');
//     g_csc.onDragStart
//       .where((Draggable d) => d is DraggableSubClass).forEach(_onDragStart);
//     g_csc.onDragStop
//       .where((Draggable d) => d is DraggableSubClass).forEach(_onDragStop);
//     g_csc.onDropZoneEntered
//       .where((DropZone d) => d is DropZoneSubClass).forEach(_onDropZoneEntered);
//     g_csc.onDropZoneLeaved
//       .where((DropZone d) => d is DropZoneSubClass).forEach(_onDropZoneLeaved);

//     // TODO:
//     // Need to dynamically update _monitoredDropZoneList
//   }

//   // CALLBACKS ************************************************************** **
//   void _onDragStart(Draggable that) {
//     assert(_draggedOpt == null, "_onDragStop() with some dragged");
//     _draggedOpt = that;

//     // TODO:
//     // Need to match all `_monitoredDropZoneList` to `that`

//     // Gather booleans for suitability
//     // Gather tooltip messages for unsuitable ones
//     // Do this asynchronously
//   }

//   void _onDragStop(Draggable that) {
//     assert(that == _draggedOpt, '_onDragStop() with strange parameter($that)');
//     _draggedOpt = null;
//   }

//   void _onDropZoneEntered(DropZone that) {
//     assert(_monitoredDropZoneList.contains(that)
//         , "_onDropZoneEntered() with strange parameter($that)");
//   }

//   void _onDropZoneLeaved(DropZone that) {
//     assert(_monitoredDropZoneList.contains(that)
//         , "_onDropZoneLeaved() with strange parameter($that)");
//   }

//   // PRIVATE **************************************************************** **

// }