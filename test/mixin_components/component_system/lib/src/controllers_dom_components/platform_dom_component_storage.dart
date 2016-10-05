// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage.dart                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 17:32:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/05 17:40:51 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class PlatformDomComponentStorage {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformCart _pc;
  final PlatformChip _pch;

  final static Html.NodeValidatorBuilder _domCartValidator =
    new Html.NodeValidatorBuilder()
    ..allowHtml5()
    ..allowElement('button', attributes: ['href', 'data-parent', 'data-toggle'])
    ..allowElement('th', attributes: ['style'])
    ..allowElement('tr', attributes: ['style']);
  String _cartHtml;

  final Map<int, DomComponent> _components = <int, DomComponent>{};

  // CONTRUCTION ************************************************************ **
  PlatformDomComponentStorage(
      this._pcs, this._pde, this._pce, this._pc, this._pch) {
    Ft.log('PlatformDCS', 'contructor');
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
      _pc.newCart(de);
    }
    else {
      if (e.type is Ram)
        de = new DomChip(_pde, e);
      else
        de = new DomChip(_pde, e);
      _components[e.uid] = de;
      _pch.newChip(de);
    }
  }

  void _handleDelete(LsEntry e) {
    DomComponent de;

    Ft.log('PlatformDCS', '_handleDetele', [e]);
    de = _components[e.uid];
    _components.remove(e.uid);
    if (e.type is Rom)
      _pc.deleteCart(de);
    else {
      _pch.deleteChip(de);
    }
  }

  void _handleUpdate(Update<LsEntry> u) {
    DomComponent de;

    Ft.log('PlatformDCS', '_handleUpdate', [u]);
  }

  // PRIVATE **************************************************************** **

}
