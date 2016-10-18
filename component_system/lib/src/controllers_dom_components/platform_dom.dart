// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/08 13:55:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/18 16:00:41 by ngoguey          ###   ########.fr       //
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

class PlatformDom {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;
  final PlatformCart _pc;
  final PlatformChip _pch;

  final static Html.NodeValidatorBuilder _domCartValidator =
    new Html.NodeValidatorBuilder()
    ..allowHtml5()
    ..allowElement('button', attributes: ['href', 'data-parent', 'data-toggle'])
    ..allowElement('th', attributes: ['style'])
    ..allowElement('tr', attributes: ['style']);
  String _cartHtml;

  // CONTRUCTION ************************************************************ **
  PlatformDom(
      this._pcs, this._pde, this._pce, this._pdcs, this._pc, this._pch) {
    Ft.log('PlatformDCSL', 'contructor');
  }

  Async.Future start() async {
    Ft.log('PlatformDCSL', 'start', []);

    _cartHtml = await Html.HttpRequest.getString("cart_table.html");
    _pcs.entryDelete.forEach(_handleDelete);
    _pcs.entryNew.forEach(_handleNew);
    _pcs.entryUpdate.forEach(_handleUpdate);
  }

  // PUBLIC ***************************************************************** **

  // CALLBACKS ************************************************************** **
  void _handleNew(LsEntry e) {
    DomComponent de;

    Ft.log('PlatformDom', '_handleNew', [e]);
    if (e.type is Rom) {
      de = new DomCart(_pde, e, _cartHtml, _domCartValidator);
      _pdcs.setDomComponent(de);
      _pc.newCart(de);
    }
    else {
      de = new DomChip(_pde, e);
      _pdcs.setDomComponent(de);
      _pch.newChip(de);
    }
  }

  void _handleDelete(LsEntry e) {
    DomComponent de;

    Ft.log('PlatformDom', '_handleDetele', [e]);
    de = _pdcs.componentOfUid(e.uid);
    _pdcs.deleteDomComponent(de);
    if (e.type is Rom)
      _pc.deleteCart(de);
    else
      _pch.deleteChip(de);
  }

  void _handleUpdate(Update<LsEntry> u) {
    DomComponent de;

    Ft.log('PlatformDom', '_handleUpdate', [u]);
    de = _pdcs.componentOfUid(u.newValue.uid);
    _pch.updateChip(de, u);
  }

}
