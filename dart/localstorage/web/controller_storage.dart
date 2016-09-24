// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   controller_storage.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 16:38:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 17:43:20 by ngoguey          ###   ########.fr       //
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
import './controller_local_storage.dart';

// Did my best to limit data races, couldn't find a bullet proof solution
// This storage keeps track of all LsEntries, even the deleted one, to dampen
//  data-races effects.
// The `Ft.log{warn|err}` instruction indicated the gravity of the data-race.
class ControllerStorage {

  // ATTRIBUTES ************************************************************* **
  final Async.StreamController<LsEntry> _entryDelete =
    new Async.StreamController<LsEntry>.broadcast();
  final Async.StreamController<LsEntry> _entryNew =
    new Async.StreamController<LsEntry>.broadcast();
  final Async.StreamController<Update<LsEntry>> _entryUpdate =
    new Async.StreamController<Update<LsEntry>>.broadcast();
  final Map<int, LsEntry> _entries = <int, LsEntry>{};

  // CONTRUCTION ************************************************************ **
  static ControllerStorage _instance;

  factory ControllerStorage(ControllerLocalStorage cls) {
    if (_instance == null)
      _instance = new ControllerStorage._(cls);
    return _instance;
  }

  ControllerStorage._(ControllerLocalStorage cls) {
    Ft.log('ControllerS', 'contructor', []);
    cls.lsEntryDelete.forEach(_onLsDelete);
    cls.lsEntryNew.forEach(_onLsNew);
    cls.lsEntryUpdate.forEach(_onLsUpdate);
  }

  void start() {
    Ft.log('ControllerS', 'start', []);
    Html.window.localStorage.forEach((String k, String v){
      LsEntry e;

      try {
        e = new LsEntry.json_exn(k, v);
        _entries[e.uid] = e;
      }
      catch (e, st) {
        Ft.log('ControllerS', 'start#unknown-entry', [k, v, e]);
        return ;
      }
    });
    _entries.values
      .where((LsEntry e) => e.type is Rom)
      .forEach((LsRom e){
        _entryNew.add(e);
      });
    _entries.values
      .where((LsEntry e) => !(e.type is Rom))
      .forEach((LsEntry e){
        _entryNew.add(e);
      });
  }

  // PUBLIC ***************************************************************** **
  Async.Stream<LsEntry> get entryDelete => _entryDelete.stream;
  Async.Stream<LsEntry> get entryNew => _entryNew.stream;
  Async.Stream<Update<LsEntry>> get entryUpdate => _entryUpdate.stream;

  // CALLBACKS ************************************************************** **
  void _onLsDelete(LsEntry e) {
    final LsEntry current = _entries[e.uid];

    Ft.log('ControllerS', '_onLsDelete', [e]);
    if (current == null) {
      Ft.logerr('ControllerS', '_onLsDelete#data-race-missing-entry');
      return ;
    }
    if (current.life is Dead) {
      Ft.logwarn('ControllerS', '_onLsDelete#data-race-deleted-entry');
      return ;
    }
    _entries[e.uid] = new LsEntry.kill(e);
    _entryDelete.add(e);
  }

  void _onLsNew(LsEntry e) {
    final LsEntry current = _entries[e.uid];

    Ft.log('ControllerS', '_onLsNew', [e]);
    if (current != null) {
      Ft.logerr('ControllerS', '_onLsNew#data-race-duplicate-entry');
      return ;
    }
    _entries[e.uid] = e;
    _entryNew.add(e);
  }

  void _onLsUpdate(Update<LsEntry> e) {
    final LsEntry current = _entries[e.newValue.uid];

    Ft.log('ControllerS', '_onLsUpdate', [e]);
    if (current == null) {
      Ft.logwarn('ControllerS', '_onLsUpdate#data-race-missing-entry');
      Ft.log('ControllerS', '_onLsUpdate#redirecting-to-lsNew');
      _onLsNew(e.newValue);
      return ;
    }
    if (current.life is Dead) {
      Ft.logwarn('ControllerS', '_onLsUpdate#data-race-deleted-entry');
      return ;
    }
    _entries[e.newValue.uid] = e.newValue;
    _entryUpdate.add(e);
  }

}
