// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   controller_local_storage.dart                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 16:38:16 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 19:48:17 by ngoguey          ###   ########.fr       //
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

// Did my best to limit data races, couldn't find a bullet proof solution
class ControllerLocalStorage {

  // ATTRIBUTES ************************************************************* **
  final Async.StreamController<LsEntry> _lsEntryDelete =
    new Async.StreamController<LsEntry>();
  final Async.StreamController<LsEntry> _lsEntryNew =
    new Async.StreamController<LsEntry>();
  final Async.StreamController<Update<LsEntry>> _lsEntryUpdate =
    new Async.StreamController<Update<LsEntry>>();

  // CONTRUCTION ************************************************************ **
  static ControllerLocalStorage _instance;

  factory ControllerLocalStorage() {
    if (_instance == null)
      _instance = new ControllerLocalStorage._();
    return _instance;
  }

  ControllerLocalStorage._() {
    Ft.log('ControllerLS','contructor');
  }

  void start() {
    Ft.log('ControllerLS', 'start', []);
    Html.Window.storageEvent.forTarget(Html.window)
      .where((Html.StorageEvent e) => e.storageArea == Html.window.localStorage)
      .forEach(_onEventExt);
  }

  // PUBLIC ***************************************************************** **
  void write(LsEntry e) { //TODO create proper `delete()` function, NOT taking a dead element
    final String key = e.keyJson;
    final String oldValueOpt = Html.window.localStorage[key];
    String value;

    if (e.life is Dead) {
      if (!Html.window.localStorage.containsKey(key))
        Ft.logerr('ControllerLS', 'write#missing-key-on-delete');
      Html.window.localStorage.remove(key);
      Async.Timer.run(() {
        _onEvent(key, oldValueOpt, null);
      });
    }
    else {
      value = e.valueJson;
      Html.window.localStorage[key] = value;
      Async.Timer.run(() {
        _onEvent(key, oldValueOpt, value);
      });
    }
  }

  Async.Stream<LsEntry> get lsEntryDelete => _lsEntryDelete.stream;
  Async.Stream<LsEntry> get lsEntryNew => _lsEntryNew.stream;
  Async.Stream<Update<LsEntry>> get lsEntryUpdate => _lsEntryUpdate.stream;

  // CALLBACKS ************************************************************** **
  void _onEventExt(Html.StorageEvent ev) {
    Ft.log('ControllerLS','_onEventExt', [ev]);
    _onEvent(ev.key, ev.oldValue, ev.newValue);
  }

  void _onEvent(String key, String oldValue, String newValue) {
    LsEntry oldEntry, newEntry;

    Ft.log('ControllerLS','_onEvent', [key, oldValue, newValue]);
    if (key == null || (oldValue == null && newValue == null)) {
      Ft.logerr('ControllerLS', '_onEvent#unsound-parameters');
      return ;
    }
    try {
      if (oldValue != null)
        oldEntry = new LsEntry.json_exn(key, oldValue);
      if (newValue != null)
        newEntry = new LsEntry.json_exn(key, newValue);
    }
    catch (e, st) {
      Ft.logwarn('ControllerLS', '_onEvent#error', [e, st]);
      return ;
    }
    if (oldEntry == null) {
      _lsEntryNew.add(newEntry);
    }
    else if (newEntry == null) {
      _lsEntryDelete.add(oldEntry);
    }
    else {
      _lsEntryUpdate.add(new Update<LsEntry>(oldEntry, newEntry));
    }
  }

}
