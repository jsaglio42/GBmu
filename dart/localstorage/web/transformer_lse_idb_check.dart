// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   transformer_lse_idb_check.dart                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:29:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 14:34:23 by ngoguey          ###   ########.fr       //
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

import './variants.dart';
import './local_storage.dart';
import './platform_component_storage.dart';
import './transformer_lse_data_check.dart';

// Transformer Local Storage Event, Data Check part
class TransformerLseIdbCheck {

  // ATTRIBUTES ************************************************************* **
  final TransformerLseDataCheck _tdc;

  // CONTRUCTION ************************************************************ **
  static TransformerLseIdbCheck _instance;

  factory TransformerLseIdbCheck(TransformerLseDataCheck tdc) {
    if (_instance == null)
      _instance = new TransformerLseIdbCheck._(tdc);
    return _instance;
  }

  TransformerLseIdbCheck._(this._tdc) {
    Ft.log('TLSEIdbCheck','contructor');
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get lsEntryDelete =>
    _tdc.lsEntryDelete.where(_handleDelete);
  Async.Stream<LsEntry> get lsEntryNew =>
    _tdc.lsEntryNew.where(_handleNew);
  Async.Stream<Update<LsEntry>> get lsEntryUpdate =>
    _tdc.lsEntryUpdate.where(_handleUpdate);

  // CALLBACKS ************************************************************** **
  bool _handleDelete(LsEntry e) {
    Ft.log('TLSEIdbCheck','_handleDelete', [e]);
    return true;
  }

  bool _handleNew(LsEntry e) {
    Ft.log('TLSEIdbCheck','_handleNew', [e]);
    return true;
  }

  bool _handleUpdate(Update<LsEntry> e) {
    Ft.log('TLSEIdbCheck','_handleUpdate', [e.newValue]);
    return true;
  }

}
