// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage.dart                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 17:32:51 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/08 12:48:45 by ngoguey          ###   ########.fr       //
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
  final DomGameBoySocket _dgbs;
  final DomDetachedCartBank _ddcb;
  final DomDetachedChipBank _ddchb;

  final Map<int, DomComponent> _components = <int, DomComponent>{};
  final Map<DomChipSocket, DomCart> _cartOfSocket = <DomChipSocket, DomCart>{};

  Ft.Option<DomCart> _openedCart = new Ft.Option<DomCart>.none();
  Ft.Option<DomCart> _gbCart = new Ft.Option<DomCart>.none();
  Ft.Option<DomComponent> _dragged = new Ft.Option<DomCart>.none();

  // CONTRUCTION ************************************************************ **
  PlatformDomComponentStorage(this._dgbs, this._ddcb, this._ddchb);

  // LIBRARY PUBLIC ********************************************************* **
  _setDomComponent(DomComponent c) {
    DomCart ca;

    if (c is DomCart) {
      for (DomChipSocket s in (c as DomCart).sockets)
        _cartOfSocket[s] = c as DomCart;
    }
    _components[c.data.uid] = c;
  }

  _deleteDomComponent(DomComponent c) {
    assert(_components.containsKey(c.data.uid));
    if (c is DomCart) {
      for (DomChipSocket s in (c as DomCart).sockets)
        _cartOfSocket.remove(s);
    }
    _components.remove(c.data.uid);
  }

  // PUBLIC ***************************************************************** **
  DomGameBoySocket get gbSocket => _dgbs;
  DomDetachedCartBank get cartBank => _ddcb;
  DomDetachedChipBank get chipBank => _ddchb;
  Ft.Option<DomCart> get openedCart => _openedCart;
  Ft.Option<DomCart> get gbCart => _gbCart;
  Ft.Option<DomComponent> get dragged => _dragged;

  // Components getters ********************************* **
  // Most of them are linear in time
  DomCart cartOfSocket(DomChipSocket s) {
    assert(_cartOfSocket[s] != null);
    return _cartOfSocket[s];
  }

  DomComponent componentOfUid(int i) {
    assert(_components.containsKey(i), 'form: componentOfUid($i)');
    return _components[i];
  }

  DomCart cartOfChip(DomChip c) {
    final int id = (c.data as LsChip).romUid.v;
    final cart = _components[id];

    assert(cart is DomCart, 'form: cartOfChip($c)');
    return cart;
  }

  Iterable<DomChip> chipsOfCart(DomCart c) =>
    _components.values
    .where((DomComponent co) {
      LsChip data;

      if (co is! DomChip)
        return false;
      data = co.data as LsChip;
      return data.isBound && data.romUid.v == c.data.uid;
    });

  DomChip chipOfCartOpt(DomCart c, Chip type, [int slot]) {
    assert(type is Ram || slot != null);
    return  _components.values
      .where((DomComponent co) {
        LsChip data;

        if (co is! DomChip)
          return false;
        data = co.data as LsChip;
        if (!data.isBound || data.romUid.v != c.data.uid)
          return false;
        if (data.type is Ram && type is Ram)
          return true;
        else if (data.type is Ss && type is Ss && data.slot.v == slot)
          return true;
        else
          return false;
      })
      .take(1)
      .fold(null, (_, e) => e);
  }

  // Ft.Option handling ********************************* **
  void set openedCart(DomCart c) {
    assert(_openedCart.isNone, 'from: openedCart($c)');
    _openedCart = new Ft.Option<DomCart>.some(c);
  }

  void unsetOpenedCart() {
    assert(_openedCart.isSome, 'from: unsetOpenedCart()');
    _openedCart = new Ft.Option<DomCart>.none();
  }

  void set gbCart(DomCart c) {
    assert(_gbCart.isNone, 'from: gbCart($c)');
    _gbCart = new Ft.Option<DomCart>.some(c);
  }

  void unsetGbCart() {
    assert(_gbCart.isSome, 'from: unsetGbCart()');
    _gbCart = new Ft.Option<DomCart>.none();
  }

  void set dragged(DomComponent c) {
    assert(_dragged.isNone, 'from: dragged($c)');
    _dragged = new Ft.Option<DomComponent>.some(c);
  }

  void unsetDragged() {
    assert(_dragged.isSome, 'from: unsetDragged()');
    _dragged = new Ft.Option<DomCart>.none();
  }

  // PRIVATE **************************************************************** **

}

//TODO: Rename class
class PlatformDomComponentStorageLogic {

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
  PlatformDomComponentStorageLogic(
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

    Ft.log('PlatformDCSL', '_handleNew', [e]);
    if (e.type is Rom) {
      de = new DomCart(_pde, e, _cartHtml, _domCartValidator);
      _pdcs._setDomComponent(de);
      _pc.newCart(de);
    }
    else {
      de = new DomChip(_pde, e);
      _pdcs._setDomComponent(de);
      _pch.newChip(de);
    }
  }

  void _handleDelete(LsEntry e) {
    DomComponent de;

    Ft.log('PlatformDCSL', '_handleDetele', [e]);
    de = _pdcs.componentOfUid(e.uid);
    _pdcs._deleteDomComponent(de);
    if (e.type is Rom)
      _pc.deleteCart(de);
    else
      _pch.deleteChip(de);
  }

  void _handleUpdate(Update<LsEntry> u) {
    DomComponent de;

    Ft.log('PlatformDCSL', '_handleUpdate', [u]);
    de = _pdcs.componentOfUid(u.newValue.uid);
    // _pch.deleteChip(_pdcs.componentOfUid(u.newValue.uid));
    // de = new DomChip(_pde, u.newValue);
    // _pdcs._setDomComponent(de);
    _pch.updateChip(de, u);
  }

}
