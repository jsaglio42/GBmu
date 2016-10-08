// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   init.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:21:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/08 11:35:32 by ngoguey          ###   ########.fr       //
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
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

import 'package:component_system/src/tmp_emulator_enums.dart';
import 'package:component_system/src/tmp_emulator_types.dart' as Emulator;

/* {"uid":2927093936,"type":"Rom"}
 *   {"idbid":1,"_ramSize":400,"_globalChecksum":8173}
 */

Async.Future init(p) async {
  Ft.log('Component_System', 'init', [p]);

  // Component storage interactions (local storage/indexedDb)
  final PlatformIndexedDb pidb = new PlatformIndexedDb();
  final PlatformLocalStorage pls = new PlatformLocalStorage();
  final PlatformComponentStorage pcs = new PlatformComponentStorage(pls, pidb);
  final TransformerLseUnserializer tu = new TransformerLseUnserializer(pls);
  final TransformerLseDataCheck tdc = new TransformerLseDataCheck(pcs, tu);
  final TransformerLseIdbCheck tic = new TransformerLseIdbCheck(pidb, tdc);

  // Dom logic-less controllers (should be renamed to `Store`)
  final PlatformDomEvents pde = new PlatformDomEvents();
  final PlatformComponentEvents pce = new PlatformComponentEvents();
  final PlatformDomComponentStorage pdcs = new PlatformDomComponentStorage(
      new DomGameBoySocket(pde),
      new DomDetachedCartBank(pde),
      new DomDetachedChipBank(pde));

  // Dom controllers
  final PlatformDomDragged pdd = new PlatformDomDragged(pde, pce, pdcs);
  new HandlerDomComponentNodes(pde, pce, pdcs);
  new HandlerDropZoneCatalyst(pde, pce, pdcs);
  new HandlerDraggableCatalyst(pde, pce, pdcs);

  // Bridge between data and dom
  final PlatformCart pc = new PlatformCart(pcs, pde, pce, pdcs);
  final PlatformChip pch = new PlatformChip(pcs, pde, pce, pdcs);
  final PlatformDomComponentStorageLogic pdcsl =
    new PlatformDomComponentStorageLogic(pcs, pde, pce, pdcs, pc, pch);

  // pidb.start: async computation
  await pidb.start(Html.window.indexedDB);

  // pcs.start: interdependant controllers
  pcs.start(tic);

  // pdcsl.start: async computation
  await pdcsl.start();

  // pls.start: data retrieval from local-storage
  /* await */ pls.start();





  final Emulator.Rom rom = new Emulator.Rom(0, 400);
  final Emulator.Ram ram = new Emulator.Ram(0, 400);
  final Emulator.Ss ss = new Emulator.Ss.dummy();
  // LsRom lsrom;
  // LsRam lsram;
  // LsSs lsss;
  // List<Async.Future> futs;
  // List comps;


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


  // await pcs.newRom(rom); //Add Rom
  // await pcs.newRom(rom);
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



  // print('MAIN await first DomCart');
  // final DomCart dc = await pce.onCartEvent
  // .where((ev) => ev.isNew)
  // .map((ev) => ev.cart)
  // .first;
  // print('MAIN got first DomCart');
  // print('MAIN await 3seconds');
  // await new Async.Future.delayed(new Duration(seconds: 2));
  // pcs.delete(dc.data);
  // print('MAIN done 3seconds');

  Ft.log('Component_System', 'init#done');
  return ;
}