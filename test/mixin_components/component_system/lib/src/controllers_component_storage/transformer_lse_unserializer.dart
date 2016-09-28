// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   transformer_lse_unserializer.dart                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 13:10:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 14:52:20 by ngoguey          ###   ########.fr       //
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
// import 'package:component_system/src/local_storage_components_intf.dart';
import 'package:component_system/src/local_storage_components.dart';
import './platform_local_storage.dart';

// Transformer Local Storage Event, Unserialize part
class TransformerLseUnserializer {

  // ATTRIBUTES ************************************************************* **
  Async.Stream<LsEntry> _lsEntryDelete;
  Async.Stream<LsEntry> _lsEntryNew;
  Async.Stream<Update<LsEntry>> _lsEntryUpdate;

  // CONTRUCTION ************************************************************ **
  static TransformerLseUnserializer _instance;

  factory TransformerLseUnserializer(PlatformLocalStorage pls) {
    if (_instance == null)
      _instance = new TransformerLseUnserializer._(pls);
    return _instance;
  }

  TransformerLseUnserializer._(PlatformLocalStorage pls)
  {
    Ft.log('TLSEUnserializer', 'contructor');
    _lsEntryDelete = pls.lsEntryDelete.transform(
      new Async.StreamTransformer<LsEvent, LsEntry>.fromHandlers(
          handleData: _handleDelete));
    _lsEntryNew = pls.lsEntryNew.transform(
      new Async.StreamTransformer<LsEvent, LsEntry>.fromHandlers(
          handleData: _handleNew));
    _lsEntryUpdate = pls.lsEntryUpdate.transform(
        new Async.StreamTransformer<LsEvent, Update<LsEntry>>.fromHandlers(
            handleData: _handleUpdate));
  }

  // PUBLIC ATTRIBUTES ****************************************************** **
  Async.Stream<LsEntry> get lsEntryDelete => _lsEntryDelete;
  Async.Stream<LsEntry> get lsEntryNew => _lsEntryNew;
  Async.Stream<Update<LsEntry>> get lsEntryUpdate => _lsEntryUpdate;

  // CALLBACKS ************************************************************** **
  void _handleDelete(LsEvent ev, Async.EventSink<LsEntry> sink) {
    LsEntry oldEntry;

    Ft.log('TLSEUnserializer', '_handleDelete', [ev.key]);
    try {
      oldEntry = new LsEntry.json_exn(ev.key, ev.oldValue);
    }
    catch (e, st) {
      Ft.logwarn('TLSEUnserializer', '_handleDelete#error', [e, st]);
      return ;
    }
    sink.add(oldEntry);
  }

  void _handleNew(LsEvent ev, Async.EventSink<LsEntry> sink) {
    LsEntry newEntry;

    Ft.log('TLSEUnserializer','_handleNew', [ev.key]);
    try {
      newEntry = new LsEntry.json_exn(ev.key, ev.newValue);
    }
    catch (e, st) {
      Ft.logwarn('TLSEUnserializer', '_handleNew#error', [e, st]);
      return ;
    }
    sink.add(newEntry);
  }

  void _handleUpdate(LsEvent ev, Async.EventSink<Update<LsEntry>> sink) {
    LsEntry newEntry, oldEntry;

    Ft.log('TLSEUnserializer','_handleNew', [ev.key, ev.newValue]);
    try {
      newEntry = new LsEntry.json_exn(ev.key, ev.newValue);
      oldEntry = new LsEntry.json_exn(ev.key, ev.oldValue);
    }
    catch (e, st) {
      Ft.logwarn('TLSEUnserializer', '_handleNew#error', [e, st]);
      return ;
    }
    sink.add(new Update<LsEntry>(oldValue: oldEntry, newValue: newEntry));
  }

}
