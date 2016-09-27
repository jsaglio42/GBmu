// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   transformer_lse_data_check.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:01:20 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 17:04:57 by ngoguey          ###   ########.fr       //
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
import './transformer_lse_unserializer.dart';

// Transformer Local Storage Event, Data Check part
class TransformerLseDataCheck {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  final TransformerLseUnserializer _tu;

  // CONTRUCTION ************************************************************ **
  static TransformerLseDataCheck _instance;

  factory TransformerLseDataCheck(
      PlatformComponentStorage pcs, TransformerLseUnserializer tu) {
    if (_instance == null)
      _instance = new TransformerLseDataCheck._(pcs, tu);
    return _instance;
  }

  TransformerLseDataCheck._(this._pcs, this._tu) {
    Ft.log('TLSEDataCheck','contructor');
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get lsEntryDelete =>
    _tu.lsEntryDelete.where(_handleDelete);
  Async.Stream<LsEntry> get lsEntryNew =>
    _tu.lsEntryNew.where(_handleNew);
  Async.Stream<Update<LsEntry>> get lsEntryUpdate =>
    _tu.lsEntryUpdate.where(_handleUpdate);

  // CALLBACKS ************************************************************** **
  // Does data-race checks
  bool _handleDelete(LsEntry e) {
    final LsEntry current = _pcs.entryOptOfUid(e.uid);

    Ft.log('TLSEDataCheck','_handleDelete', [e]);
    if (current == null) {
      Ft.logerr('TLSEDataCheck', '_handleDelete#data-race-missing-entry');
      return false;
    }
    if (current.life is Dead) {
      Ft.logwarn('TLSEDataCheck', '_handleDelete#data-race-deleted-entry');
      return false;
    }
    return true;
  }

  // Does data-race checks
  // Does `romUid` check
  bool _handleNew(LsEntry e) {
    final LsEntry current = _pcs.entryOptOfUid(e.uid);
    LsChip c;

    Ft.log('TLSEDataCheck','_handleNew', [e]);
    if (current != null) {
      Ft.logerr('TLSEDataCheck', '_handleNew#data-race-duplicate-entry');
      return false;
    }
    if (e.type is Chip) {
      c = e as LsChip;
      if (c.romUid.isSome && _pcs.entryOptOfUid(c.romUid.v) == null) {
        Ft.logwarn('TLSEDataCheck', '_handleNew#missing-rom');
        return false;
      }
    }
    return true;
  }

  // Does data-race checks
  // Disallow update on roms
  bool _handleUpdate(Update<LsEntry> e) {
    final LsEntry current = _pcs.entryOptOfUid(e.newValue.uid);

    Ft.log('TLSEDataCheck','_handleUpdate', [e.newValue]);
    if (current == null) {
      Ft.logerr('TLSEDataCheck', '_handleUpdate#data-race-missing-entry');
      return false;
    }
    if (current.life is Dead) {
      Ft.logwarn('TLSEDataCheck', '_handleUpdate#data-race-deleted-entry');
      return false;
    }
    if (current.type is Rom) {
      Ft.logwarn('TLSEDataCheck', '_handleUpdate#update-on-rom');
      return false;
    }
    return true;
  }

}
