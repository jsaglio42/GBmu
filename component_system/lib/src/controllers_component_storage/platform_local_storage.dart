// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_local_storage.dart                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 13:08:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 18:58:44 by ngoguey          ###   ########.fr       //
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

// Did my best to limit data races, couldn't find a bullet proof solution
class PlatformLocalStorage {

  // ATTRIBUTES ************************************************************* **
  final Async.StreamController<LsEvent> _lsEntryDelete =
    new Async.StreamController<LsEvent>();
  final Async.StreamController<LsEvent> _lsEntryNew =
    new Async.StreamController<LsEvent>();
  final Async.StreamController<LsEvent> _lsEntryUpdate =
    new Async.StreamController<LsEvent>();

  // CONTRUCTION ************************************************************ **
  static PlatformLocalStorage _instance;

  factory PlatformLocalStorage() {
    if (_instance == null)
      _instance = new PlatformLocalStorage._();
    return _instance;
  }

  PlatformLocalStorage._() {
    Ft.log('PlatformLS','contructor');
  }

  void start() {
    final List<LsEvent> chips = <LsEvent>[];

    Ft.log('PlatformLS', 'start', []);
    Html.Window.storageEvent.forTarget(Html.window)
      .where((Html.StorageEvent e) => e.storageArea == Html.window.localStorage)
      .forEach(_onEvent);
    Html.window.localStorage.forEach((String k, String v) {
      if (k.contains('Rom'))
        _lsEntryNew.add(new LsEvent(k, oldValue: null, newValue: v));
      else
        chips.add(new LsEvent(k, oldValue: null, newValue: v));
    });
    for (var c in chips) {
      _lsEntryNew.add(c);
    }
  }

  // PUBLIC ***************************************************************** **
  void delete(LsEntry e) {
    final String key = e.keyJson;
    String oldValue;

    Ft.log('PlatformLS','delete', [e]);
    assert(e.life is Alive, "PlatformLS.delete()");
    if (!Html.window.localStorage.containsKey(key)) {
      Ft.logerr('PlatformLS', 'delete#missing-key');
      return ;
    }
    oldValue = Html.window.localStorage[key];
    Html.window.localStorage.remove(key);
    Async.Timer.run(() {
      _lsEntryDelete.add(new LsEvent(key, oldValue: oldValue, newValue: null));
    });
  }

  void add(LsEntry e) {
    final String key = e.keyJson;
    String value;

    Ft.log('PlatformLS','add', [e]);
    assert(e.life is Alive, "PlatformLS.update()");
    if (Html.window.localStorage.containsKey(key)) {
      Ft.logerr('PlatformLS', 'update#extraneous-key');
      return ;
    }
    value = e.valueJson;
    Html.window.localStorage[key] = value;
    Async.Timer.run(() {
      _lsEntryNew.add(new LsEvent(key, oldValue: null, newValue: value));
    });

  }

  void update(LsEntry e) {
    final String key = e.keyJson;
    String value, oldValue;

    Ft.log('PlatformLS','update', [e]);
    assert(e.life is Alive, "PlatformLS.update()");
    if (!Html.window.localStorage.containsKey(key)) {
      Ft.logerr('PlatformLS', 'update#missing-key');
      return ;
    }
    value = e.valueJson;
    oldValue = Html.window.localStorage[key];
    Html.window.localStorage[key] = value;
    Async.Timer.run(() {
      _lsEntryUpdate.add(new LsEvent(key, oldValue: oldValue, newValue: value));
    });
  }

  Async.Stream<LsEvent> get lsEntryDelete => _lsEntryDelete.stream;
  Async.Stream<LsEvent> get lsEntryNew => _lsEntryNew.stream;
  Async.Stream<LsEvent> get lsEntryUpdate => _lsEntryUpdate.stream;

  // CALLBACKS ************************************************************** **
  void _onEvent(Html.StorageEvent ev) {
    final LsEvent lse = new LsEvent(
        ev.key, oldValue: ev.oldValue, newValue: ev.newValue);

    // Ft.log('PlatformLS','_onEvent', [ev]);
    if (ev.key == null || (ev.oldValue == null && ev.newValue == null)) {
      Ft.logerr('PlatformLS', '_onEvent#unsound-parameters');
      return ;
    }
    if (ev.oldValue == null)
      _lsEntryNew.add(lse);
    else if (ev.newValue == null)
      _lsEntryDelete.add(lse);
    else
      _lsEntryUpdate.add(lse);
  }

}
