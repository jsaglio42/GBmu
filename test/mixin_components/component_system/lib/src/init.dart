// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   init.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:21:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 11:43:11 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import './variants.dart';
import './local_storage.dart';

import './controllers_component_storage/platform_local_storage.dart';
import './controllers_component_storage/platform_component_storage.dart';
import './controllers_component_storage/platform_indexeddb.dart';
import './controllers_component_storage/transformer_lse_unserializer.dart';
import './controllers_component_storage/transformer_lse_data_check.dart';
import './controllers_component_storage/transformer_lse_idb_check.dart';

import './tmp_emulator_enums.dart';
import './tmp_emulator_types.dart' as Emulator;

Async.Future init(_) async {
  print('Hello World');
  PlatformLocalStorage pls;
  PlatformComponentStorage pcs;
  PlatformIndexedDb pidb;
  TransformerLseUnserializer tu;
  TransformerLseDataCheck tdc;
  TransformerLseIdbCheck tic;

  final Emulator.Rom rom = new Emulator.Rom(0, 400);
  final Emulator.Ram ram = new Emulator.Ram(0, 400);
  LsRom lsrom;
  LsRam lsram;

  try {
    pidb = new PlatformIndexedDb();
    pls = new PlatformLocalStorage();
    pcs = new PlatformComponentStorage(pls, pidb);
    tu = new TransformerLseUnserializer(pls);
    tdc = new TransformerLseDataCheck(pcs, tu);
    tic = new TransformerLseIdbCheck(pidb, tdc);

    await pidb.start(Html.window.indexedDB);
    pls.start();
    pcs.start(tic);

    pcs.newRom(rom);
    pcs.newRam(ram);

    lsrom = await pcs.entryNew.where((LsEntry e) => e.type is Rom).first;
    lsram = await pcs.entryNew.where((LsEntry e) => e.type is Ram).first;

    pcs.bind(lsram, lsrom);

    // lsram = (await pcs.entryUpdate.first).newValue;
    // await new Async.Future.delayed(new Duration(seconds: 2));
    // print('go!');
    // pcs.unbind(lsram);

    // lsram = (await pcs.entryUpdate.first).newValue;
    // await new Async.Future.delayed(new Duration(seconds: 2));
    // print('go!');
    // pcs.delete(lsram);

    var v = await pidb.fetch(lsrom.type, lsrom.idbid);
    print(v);
    print(v.runtimeType);

  } catch (e, st) {
    print(e);
    print(st);
    return ;
  }
}