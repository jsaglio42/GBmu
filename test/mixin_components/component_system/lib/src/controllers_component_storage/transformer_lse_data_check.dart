// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   transformer_lse_data_check.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:01:20 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 17:11:34 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/local_storage_components.dart';
import './platform_component_storage.dart';
import './transformer_lse_unserializer.dart';

// Transformer Local Storage Event, Data Check part
// The `Ft.log{warn|err}` instruction indicated the gravity of the data-race.
class TransformerLseDataCheck {

  // ATTRIBUTES ************************************************************* **
  final PlatformComponentStorage _pcs;
  Async.Stream<LsEntry> _lsEntryDelete;
  Async.Stream<LsEntry> _lsEntryNew;
  Async.Stream<Update<LsEntry>> _lsEntryUpdate;

  // CONTRUCTION ************************************************************ **
  static TransformerLseDataCheck _instance;

  factory TransformerLseDataCheck(
      PlatformComponentStorage pcs, TransformerLseUnserializer tu) {
    if (_instance == null)
      _instance = new TransformerLseDataCheck._(pcs, tu);
    return _instance;
  }

  TransformerLseDataCheck._(this._pcs, TransformerLseUnserializer tu) {
    Ft.log('TLSEDataCheck', 'contructor');
    _lsEntryDelete = tu.lsEntryDelete.where(_handleDelete);
    _lsEntryNew = tu.lsEntryNew.where(_handleNew);
    _lsEntryUpdate = tu.lsEntryUpdate.where(_handleUpdate);
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get lsEntryDelete => _lsEntryDelete;
  Async.Stream<LsEntry> get lsEntryNew => _lsEntryNew;
  Async.Stream<Update<LsEntry>> get lsEntryUpdate => _lsEntryUpdate;

  // CALLBACKS ************************************************************** **
  // Does data-race checks
  // Disallow rom deletion if busy
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
    if (e.type is Rom && _pcs.romHasAnyChip(e)) {
      Ft.logerr('TLSEDataCheck', '_handleDelete#rom-busy');
      return false;
    }
    return true;
  }

  // Does data-race checks
  // Does `romUid` check
  // Disallow impossible bind
  bool _handleNew(LsEntry e) {
    final LsEntry current = _pcs.entryOptOfUid(e.uid);

    Ft.log('TLSEDataCheck','_handleNew', [e]);
    if (current != null) {
      Ft.logerr('TLSEDataCheck', '_handleNew#data-race-duplicate-entry');
      return false;
    }
    if (e.type is Chip) {
      if ((e as LsChip).isBound && !_bindPossible(e))
        return false;
    }
    return true;
  }

  // Does data-race checks
  // Disallow update on roms
  // Checks old/current match
  // Disallow impossible bind
  bool _handleUpdate(Update<LsEntry> e) {
    final LsEntry current = _pcs.entryOptOfUid(e.newValue.uid);
    LsChip cold, cnew, ccur;

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
    ccur = current;
    cold = e.oldValue;
    cnew = e.newValue;
    if (ccur.romUid.v != cold.romUid.v) {
      Ft.logwarn('TLSEDataCheck', '_handleUpdate#unsound-old');
      return false;
    }
    if (cold.isBound == cnew.isBound) {
      Ft.logwarn('TLSEDataCheck', '_handleUpdate#unsound-update');
      return false;
    }
    if (cnew.type is Chip) {
      if ((cnew as LsChip).isBound && !_bindPossible(cnew))
        return false;
    }
    return true;
  }

  // PRIVATE **************************************************************** **
  bool _bindPossible(LsChip c) {
    final LsEntry e = _pcs.entryOptOfUid(c.romUid.v);

    if (e == null) {
      Ft.logerr('TLSEDataCheck', '_bindPossible#missing-rom');
      return false;
    }
    if (!(e.type is Rom)) {
      Ft.logerr('TLSEDataCheck', '_bindPossible#bad-rom');
      return false;
    }
    if (!(e as LsRom).isCompatible(c)) {
      Ft.logerr('TLSEDataCheck', '_bindPossible#incompatible-rom');
      return false;
    }
    if (c is Ram && _pcs.romHasRam(e)) {
      Ft.logwarn('TLSEDataCheck', '_bindPossible#rom-busy');
      return false;
    }
    if (c is Ss && _pcs.romSlotBusy(e, c.slot.v)) {
      Ft.logwarn('TLSEDataCheck', '_bindPossible#rom-busy');
      return false;
    }
    return true;
  }

}
