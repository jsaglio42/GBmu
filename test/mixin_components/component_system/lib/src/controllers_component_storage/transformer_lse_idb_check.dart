// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   transformer_lse_idb_check.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:29:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 11:43:18 by ngoguey          ###   ########.fr       //
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

import 'package:component_system/src/variants.dart';
import 'package:component_system/src/local_storage.dart';
import './platform_component_storage.dart';
import './platform_indexeddb.dart';
import './transformer_lse_data_check.dart';

// Transformer Local Storage Event, Data Check part
class TransformerLseIdbCheck {

  // ATTRIBUTES ************************************************************* **
  final PlatformIndexedDb _pidb;
  final TransformerLseDataCheck _tdc;

  final Async.StreamController<LsEntry> _entryNew =
    new Async.StreamController<LsEntry>();
  final Async.StreamController<Update<LsEntry>> _entryUpdate =
    new Async.StreamController<Update<LsEntry>>();

  // CONTRUCTION ************************************************************ **
  static TransformerLseIdbCheck _instance;

  factory TransformerLseIdbCheck(
      PlatformIndexedDb pidb, TransformerLseDataCheck tdc) {
    if (_instance == null)
      _instance = new TransformerLseIdbCheck._(pidb, tdc);
    return _instance;
  }

  TransformerLseIdbCheck._(this._pidb, this._tdc) {
    Ft.log('TLSEIdbCheck','contructor');
    _tdc.lsEntryNew.forEach(_handleNew);
    _tdc.lsEntryUpdate.forEach(_handleUpdate);
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get lsEntryDelete =>
    _tdc.lsEntryDelete.where(_handleDelete);
  Async.Stream<LsEntry> get lsEntryNew => _entryNew.stream;
  Async.Stream<Update<LsEntry>> get lsEntryUpdate => _entryUpdate.stream;

  // CALLBACKS ************************************************************** **
  bool _handleDelete(LsEntry e) {
    Ft.log('TLSEIdbCheck','_handleDelete', [e]);
    return true;
  }

  Async.Future _handleNew(LsEntry e) async {
    Ft.log('TLSEIdbCheck','_handleNew', [e]);

    if (await _pidb.contains(e.type, e.idbid))
      _entryNew.add(e);
    else
      Ft.logwarn('TLSEIdbCheck','_handleNew#missing-from-db');
    return ;
  }

  Async.Future _handleUpdate(Update<LsEntry> u) async {
    Ft.log('TLSEIdbCheck','_handleUpdate', [u.newValue]);

    if (await _pidb.contains(u.newValue.type, u.newValue.idbid))
      _entryUpdate.add(u);
    else
      Ft.logwarn('TLSEIdbCheck','_handleUpdate#missing-from-db');
    return ;
  }


}
