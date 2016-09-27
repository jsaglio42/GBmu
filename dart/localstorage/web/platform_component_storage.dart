// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_component_storage.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 14:18:20 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 14:21:56 by ngoguey          ###   ########.fr       //
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
// import './controller_local_storage.dart';

// TODO?: Filter `lsEntry*` streams multiple time
//   1. LocalStorage Events, Unserialization    ControllerLocalStorage
//   2. Event consistency, regarding AppStorage ControllerLocalStorageDataCheck
//   3. Event consistency, regarding IndexedDb  ControllerLocalStorageEventIndexedDbCheck
// TODO?:
//  PlatformComponentStorage
//  PlatformIndexedDb
//  PlatformLocalStorage
//  TransformerLSEUnserialization
//  TransformerLSEDataCheck
//  TransformerLSEIndexedDbCheck

// Did my best to limit data races, couldn't find a bullet proof solution
// This storage keeps track of all LsEntries, even the deleted one, to dampen
//  data-races effects.
// The `Ft.log{warn|err}` instruction indicated the gravity of the data-race.
class PlatformComponentStorage {

  // ATTRIBUTES ************************************************************* **
  final Map<int, LsEntry> _entries = <int, LsEntry>{};

  // CONTRUCTION ************************************************************ **
  static PlatformComponentStorage _instance;

  factory PlatformComponentStorage() {
    if (_instance == null)
      _instance = new PlatformComponentStorage._();
    return _instance;
  }

  PlatformComponentStorage._() {
    Ft.log('PlatformCS', 'contructor', []);
  }

  // PUBLIC ***************************************************************** **
  LsEntry entryOptOfUid(int uid) =>
    _entries[uid];

  // CALLBACKS ************************************************************** **


}
