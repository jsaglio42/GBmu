// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   init.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:21:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/28 18:17:26 by ngoguey          ###   ########.fr       //
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
import './tmp_emulator_enums.dart';
import './tmp_emulator_types.dart' as Emulator;

import './variants.dart';
import './local_storage_components.dart';
import './controllers_component_storage/platform_local_storage.dart';
import './controllers_component_storage/platform_component_storage.dart';
import './controllers_component_storage/platform_indexeddb.dart';
import './controllers_component_storage/transformer_lse_unserializer.dart';
import './controllers_component_storage/transformer_lse_data_check.dart';
import './controllers_component_storage/transformer_lse_idb_check.dart';
import './controllers_dom_components/platform_dom_component_storage.dart';
import './controllers_dom_components/platform_dom_events.dart';

Async.Future init(p) async {
  Ft.log('Component_System', 'init', [p]);

  final PlatformIndexedDb pidb = new PlatformIndexedDb();
  final PlatformLocalStorage pls = new PlatformLocalStorage();
  final PlatformComponentStorage pcs = new PlatformComponentStorage(pls, pidb);
  final TransformerLseUnserializer tu = new TransformerLseUnserializer(pls);
  final TransformerLseDataCheck tdc = new TransformerLseDataCheck(pcs, tu);
  final TransformerLseIdbCheck tic = new TransformerLseIdbCheck(pidb, tdc);

  final PlatformDomEvents pde = new PlatformDomEvents();
  final PlatformDomComponentStorage pdcs =
    new PlatformDomComponentStorage(pcs, pde);

  final Emulator.Rom rom = new Emulator.Rom(0, 400);
  final Emulator.Ram ram = new Emulator.Ram(0, 400);
  final Emulator.Ss ss = new Emulator.Ss.dummy();
  // LsRom lsrom;
  // LsRam lsram;
  // LsSs lsss;
  // List<Async.Future> futs;
  // List comps;

  await pidb.start(Html.window.indexedDB);
  pcs.start(tic);
  await pdcs.start();

  // pcs.entryDelete.forEach((_){
  //       print('main#deleteEntry');
  //     });
  // pcs.entryNew.forEach((_){
  //       print('main#newEntry');
  //     });
  // pcs.entryUpdate.forEach((_){
  //       print('main#updateEntry');
  //     });

  // futs = [
  //   pcs.entryNew.where((LsEntry e) => e.type is Rom).first,
  //   pcs.entryNew.where((LsEntry e) => e.type is Ram).first,
  //   pcs.entryNew.where((LsEntry e) => e.type is Ss).first,
  // ];

  /* await */ pls.start();

  // await pcs.newRom(rom);
  // await pcs.newRam(ram);
  // await pcs.newSs(ss);

  // comps = await Async.Future.wait(futs);

  // lsrom = comps[0];
  // lsram = comps[1];
  // lsss = comps[2];

  // pcs.bindRam(lsram, lsrom);
  // pcs.bindSs(lsss, lsrom, 2);
  // pcs.unbind(lsss);

  // lsram = (await pcs.entryUpdate.first).newValue;
  // await new Async.Future.delayed(new Duration(seconds: 2));
  // print('go!');
  // pcs.unbind(lsram);

  // lsram = (await pcs.entryUpdate.first).newValue;
  // await new Async.Future.delayed(new Duration(seconds: 2));
  // print('go!');
  // pcs.delete(lsram);

  Ft.log('Component_System', 'init#done');
  return ;
}