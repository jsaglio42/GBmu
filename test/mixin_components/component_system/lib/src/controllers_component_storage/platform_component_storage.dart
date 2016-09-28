// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_component_storage.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:18:20 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 12:31:27 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/local_storage.dart';
import './transformer_lse_idb_check.dart';
import './platform_indexeddb.dart';
import './platform_local_storage.dart';

// Did my best to limit data races, couldn't find a bullet proof solution
// This storage keeps track of all LsEntries, even the deleted one, to dampen
//  data-races effects.
class PlatformComponentStorage {

  // ATTRIBUTES ************************************************************* **
  final Map<int, LsEntry> _entries = <int, LsEntry>{};
  final PlatformIndexedDb _pidb;
  final PlatformLocalStorage _pls;

  final _rng = new Random.secure();
  static final int _maxint = pow(2, 32);

  Async.Stream<LsEntry> _entryDelete;
  Async.Stream<LsEntry> _entryNew;
  Async.Stream<Update<LsEntry>> _entryUpdate;

  // CONTRUCTION ************************************************************ **
  static PlatformComponentStorage _instance;

  factory PlatformComponentStorage(
      PlatformLocalStorage pls, PlatformIndexedDb pidb) {
    if (_instance == null)
      _instance = new PlatformComponentStorage._(pls, pidb);
    return _instance;
  }

  PlatformComponentStorage._(this._pls, this._pidb) {
    Ft.log('PlatformCS', 'contructor', []);
  }

  void start(TransformerLseIdbCheck tic) {
    Ft.log('PlatformCS', 'start', [tic]);

    _entryDelete = tic.lsEntryDelete.map(_handleDelete).asBroadcastStream();
    _entryNew = tic.lsEntryNew.map(_handleNew).asBroadcastStream();
    _entryUpdate = tic.lsEntryUpdate.map(_handleUpdate).asBroadcastStream();
  }

  // PUBLIC ***************************************************************** **

  Async.Stream<LsEntry> get entryDelete {
    assert(_entryDelete != null, 'from: PlatformCS.entryDelete');
    return _entryDelete;
  }

  Async.Stream<LsEntry> get entryNew {
    assert(_entryNew != null, 'from: PlatformCS.entryNew');
    return _entryNew;
  }

  Async.Stream<Update<LsEntry>> get entryUpdate {
    assert(_entryUpdate != null, 'from: PlatformCS.entryUpdate');
    return _entryUpdate;
  }

  LsEntry entryOptOfUid(int uid) =>
    _entries[uid];

  bool romHasRam(LsRom dst) =>
    _entries.values
    .where((LsEntry e) => e.life is Alive && e.type is Ram)
    .where((LsRam r) => r.romUid.isSome && r.romUid.v == dst.uid)
    .isNotEmpty;

  Async.Future newRom(Emulator.Rom r) async {
    Ft.log('PlatformCS', 'newRom', [r]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Rom.v, r);
    final int rs = r.pullHeaderValue(RomHeaderField.RAM_Size);
    final int gcs = r.pullHeaderValue(RomHeaderField.Global_Checksum);
    final LsRom e =
      new LsRom.unsafe(uid, Alive.v, idbid, rs, gcs);

    _pls.add(e);
  }

  Async.Future newRam(Emulator.Ram r) async {
    Ft.log('PlatformCS', 'newRam', [r]);

    final int uid = _makeUid();
    final int idbid = await _pidb.add(Ram.v, r);
    final int s = r.size;
    final LsRam e =
      new LsRam.unsafe(uid, Alive.v, idbid, s, new Ft.Option<int>.none());

    _pls.add(e);
  }

  // TODO: PlatformComponentStorage.addSs

  void bind(LsChip c, LsRom dst) {
    Ft.log('PlatformCS', 'bind', [c, dst]);
    if (_entries[c.uid] == null) {
      Ft.logerr('PlatformCS', 'bind#missing-element', [c]);
      return ;
    }
    if (c.romUid.isSome) {
      Ft.logerr('PlatformCS', 'bind#bound', [c]);
      return ;
    }
    if (c.life is Dead) {
      Ft.logerr('PlatformCS', 'bind#dead-chip', [c]);
      return ;
    }
    if (dst.life is Dead) {
      Ft.logerr('PlatformCS', 'bind#dead-rom', [c, dst]);
      return ;
    }
    if (c.type is Ram && this.romHasRam(dst)) {
      Ft.logerr('PlatformCS', 'bind#full-rom', [c, dst]);
      return ;
    }
    // TODO: Check Ss slot availability
    _pls.update(new LsChip.bind(c, dst.uid));
  }

  void unbind(LsChip c) {
    Ft.log('PlatformCS', 'unbind', [c]);
    if (_entries[c.uid] == null) {
      Ft.logerr('PlatformCS', 'unbind#missing-element', [c]);
      return ;
    }
    if (c.romUid.isNone) {
      Ft.logerr('PlatformCS', 'unbind#not-bound', [c]);
      return ;
    }
    if (c.life is Dead) {
      Ft.logerr('PlatformCS', 'unbind#dead', [c]);
      return ;
    }
    _pls.update(new LsChip.unbind(c));
  }

  Async.Future delete(LsEntry e) async {
    Ft.log('PlatformCS', 'delete', [e]);
    if (_entries[e.uid] == null) {
      Ft.logerr('PlatformCS', 'delete#missing-element', [e]);
      return ;
    }
    await _pidb.delete(e.type, e.idbid);
    _pls.delete(e);
  }

  // CALLBACKS ************************************************************** **
  LsEntry _handleDelete(LsEntry e) {
    LsEntry old;

    Ft.log('PlatformCS', '_handleDelete', [e]);
    old = _entries[e.uid];
    old.kill();
    return old;
  }

  LsEntry _handleNew(LsEntry e) {
    Ft.log('PlatformCS', '_handleNew', [e]);
    _entries[e.uid] = e;
    return e;
  }

  Update<LsEntry> _handleUpdate(Update<LsEntry> u) {
    LsEntry old;

    Ft.log('PlatformCS', '_handleUpdate', [u]);
    old = _entries[u.newValue.uid];
    _entries[u.newValue.uid] = u.newValue;
    return new Update<LsEntry>(oldValue: old, newValue: u.newValue);
  }

  // PRIVATE **************************************************************** **
  int _makeUid() {
    int uid;

    do {
      uid = _rng.nextInt(_maxint);
    } while (_entries[uid] != null);
    return uid;
  }

}
