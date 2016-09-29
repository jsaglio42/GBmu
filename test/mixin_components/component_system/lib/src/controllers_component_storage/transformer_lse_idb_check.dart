// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   transformer_lse_idb_check.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:29:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:11:44 by ngoguey          ###   ########.fr       //
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

// Transformer Local Storage Event, Data Check part
class TransformerLseIdbCheck {

  // ATTRIBUTES ************************************************************* **
  final PlatformIndexedDb _pidb;
  Async.Stream<LsEntry> _lsEntryDelete;
  Async.Stream<LsEntry> _lsEntryNew;
  Async.Stream<Update<LsEntry>> _lsEntryUpdate;

  // CONTRUCTION ************************************************************ **
  static TransformerLseIdbCheck _instance;

  factory TransformerLseIdbCheck(
      PlatformIndexedDb pidb, TransformerLseDataCheck tdc) {
    if (_instance == null)
      _instance = new TransformerLseIdbCheck._(pidb, tdc);
    return _instance;
  }

  TransformerLseIdbCheck._(this._pidb, TransformerLseDataCheck tdc) {
    Ft.log('TLSEIdbCheck','contructor');
    _lsEntryDelete = tdc.lsEntryDelete.where(_handleDelete);
    _lsEntryNew = tdc.lsEntryNew.asyncMap(_handleNew).where((v) => v != null);
    _lsEntryUpdate =
      tdc.lsEntryUpdate.asyncMap(_handleUpdate).where((v) => v != null);
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get lsEntryDelete => _lsEntryDelete;
  Async.Stream<LsEntry> get lsEntryNew => _lsEntryNew;
  Async.Stream<Update<LsEntry>> get lsEntryUpdate => _lsEntryUpdate;

  // CALLBACKS ************************************************************** **
  bool _handleDelete(LsEntry e) {
    Ft.log('TLSEIdbCheck','_handleDelete', [e]);
    return true;
  }

  Async.Future<LsEntry> _handleNew(LsEntry e) async {
    Ft.log('TLSEIdbCheck','_handleNew', [e]);

    if (await _pidb.contains(e.type, e.idbid))
      return e;
    else {
      Ft.logwarn('TLSEIdbCheck','_handleNew#missing-from-db');
      return null;
    }
  }

  Async.Future<Update<LsEntry>> _handleUpdate(Update<LsEntry> u) async {
    Ft.log('TLSEIdbCheck','_handleUpdate', [u.newValue]);

    if (await _pidb.contains(u.newValue.type, u.newValue.idbid))
      return u;
    else {
      Ft.logwarn('TLSEIdbCheck','_handleUpdate#missing-from-db');
      return null;
    }
    return ;
  }


}
