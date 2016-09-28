// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage.dart                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 17:32:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 18:25:09 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/tmp_emulator_enums.dart';
import 'package:component_system/src/tmp_emulator_types.dart' as Emulator;

import 'package:component_system/src/variants.dart';
import 'package:component_system/src/local_storage_components.dart';
import 'package:component_system/src/controllers_component_storage/platform_component_storage.dart';
import './platform_dom_events.dart';

// import 'package:component_system/src/controllers_dom_components/platform_dom_events.dart';

import 'package:component_system/src/dom_components/html_cart_closable.dart';
import 'package:component_system/src/dom_components/html_cart_element.dart';
import 'package:component_system/src/dom_components/html_chipsocket_element.dart';
import 'package:component_system/src/dom_components/html_draggable.dart';
import 'package:component_system/src/dom_components/html_dropzone.dart';
import 'package:component_system/src/dom_components/mixin_assembly.dart';
import 'package:component_system/src/dom_components/mixin_interfaces.dart';

class PlatformDomComponentStorage {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final static Html.NodeValidatorBuilder _domCartValidator =
    new Html.NodeValidatorBuilder()
    ..allowHtml5()
    ..allowElement('button', attributes: ['href', 'data-parent', 'data-toggle'])
    ..allowElement('th', attributes: ['style'])
    ..allowElement('tr', attributes: ['style']);

  String _cartHtml;
  // Async.Stream<LsEntry> _entryDelete;
  // Async.Stream<LsEntry> _entryNew;
  // Async.Stream<Update<LsEntry>> _entryUpdate;

  // CONTRUCTION ************************************************************ **
  static PlatformDomComponentStorage _instance;

  factory PlatformDomComponentStorage(
      PlatformComponentStorage pcs, PlatformDomEvents pde) {
    if (_instance == null)
      _instance = new PlatformDomComponentStorage._(pcs, pde);
    return _instance;
  }

  PlatformDomComponentStorage._(this._pcs, this._pde) {
    Ft.log('PlatformDCS', 'contructor', [_pcs, _pde]);
  }

  Async.Future start() async {
    Ft.log('PlatformDCS', 'start', []);

    _cartHtml = await Html.HttpRequest.getString("cart_table.html");
    // _pcs.entryDelete.forEach(_handleDelete);
    _pcs.entryNew.forEach(_handleNew);
    // _pcs.entryUpdate.forEach(_handleUpdate);
  }

  // PUBLIC ***************************************************************** **
  // Async.Stream<LsEntry> get entryDelete {
  //   assert(_entryDelete != null, 'from: PlatformDCS.entryDelete');
  //   return _entryDelete;
  // }

  // Async.Stream<LsEntry> get entryNew {
  //   assert(_entryNew != null, 'from: PlatformDCS.entryNew');
  //   return _entryNew;
    // }

  // Async.Stream<Update<LsEntry>> get entryUpdate {
  //   assert(_entryUpdate != null, 'from: PlatformDCS.entryUpdate');
  //   return _entryUpdate;
  // }

  // CALLBACKS ************************************************************** **
  void _handleNew(LsEntry e) {
    DomElement de;

    Ft.log('PlatformDCS', '_handleNew', [e]);
    if (e.type is Rom) {
      de = new DomCart(_pde, _cartHtml, _domCartValidator);
      _pde.cartNew(de);
    }
  }

  // PRIVATE **************************************************************** **

}
