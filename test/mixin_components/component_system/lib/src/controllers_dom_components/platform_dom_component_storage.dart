// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage.dart                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 17:32:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 12:59:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library platform_dom_component_storage;

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

part './platform_dom_component_storage_parts.dart';

abstract class _super {

  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;

  _super(this._pcs, this._pde);

}

class PlatformDomComponentStorage extends _super
  with _OpenedCartStorage {

  // ATTRIBUTES ************************************************************* **
  final static Html.NodeValidatorBuilder _domCartValidator =
    new Html.NodeValidatorBuilder()
    ..allowHtml5()
    ..allowElement('button', attributes: ['href', 'data-parent', 'data-toggle'])
    ..allowElement('th', attributes: ['style'])
    ..allowElement('tr', attributes: ['style']);
  String _cartHtml;

  final Map<int, DomComponent> _components = <int, DomComponent>{};


  // CONTRUCTION ************************************************************ **
  static PlatformDomComponentStorage _instance;

  factory PlatformDomComponentStorage(
      PlatformComponentStorage pcs, PlatformDomEvents pde) {
    if (_instance == null)
      _instance = new PlatformDomComponentStorage._(pcs, pde);
    return _instance;
  }

  PlatformDomComponentStorage._(
      PlatformComponentStorage pcs, PlatformDomEvents pde)
    : super(pcs, pde){
    Ft.log('PlatformDCS', 'contructor', [_pcs, _pde]);
  }

  Async.Future start() async {
    Ft.log('PlatformDCS', 'start', []);

    _cartHtml = await Html.HttpRequest.getString("cart_table.html");
    _pcs.entryDelete.forEach(_handleDelete);
    _pcs.entryNew.forEach(_handleNew);
    _pcs.entryUpdate.forEach(_handleUpdate);
  }

  // PUBLIC ***************************************************************** **

  // CALLBACKS ************************************************************** **
  void _handleNew(LsEntry e) {
    DomComponent de;

    Ft.log('PlatformDCS', '_handleNew', [e]);
    if (e.type is Rom) {
      de = new DomCart(_pde, e, _cartHtml, _domCartValidator);
      _components[e.uid] = de;
      _pde.cartNew(de);
    }
  }

  void _handleDelete(LsEntry e) {
    DomComponent de;

    Ft.log('PlatformDCS', '_handleDetele', [e]);
    if (e.type is Rom) {
      de = _components[e.uid];
      _components.remove(e.uid);
      _pde.cartDelete(de);
    }
  }

  void _handleUpdate(Update<LsEntry> u) {
    DomComponent de;

    Ft.log('PlatformDCS', '_handleUpdate', [u]);
  }

  // PRIVATE **************************************************************** **

}
