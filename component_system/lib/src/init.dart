// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   init.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/28 11:21:29 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/12 18:34:44 by ngoguey          ###   ########.fr       //
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

import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/* {"uid":2927093936,"type":"Rom"}
 *   {"idbid":1,"_ramSize":400,"_globalChecksum":8173}
 */

Async.Future init(Emulator.Emulator emu) async {
  Ft.log('Component_System', 'init', [emu]);

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
  new HandlerDomDragged(pde, pce, pdcs);
  new HandlerDomComponentNodes(pde, pce, pdcs);
  new HandlerDropZoneCatalyst(pde, pce, pdcs);
  new HandlerDraggableCatalyst(pde, pce, pdcs);

  // Bridge between data and dom
  final PlatformCart pc = new PlatformCart(pcs, pde, pce, pdcs, emu);
  final PlatformChip pch = new PlatformChip(pcs, pde, pce, pdcs);
  final PlatformDom pd = new PlatformDom(pcs, pde, pce, pdcs, pc, pch);

  // Misc. controllers
  new HandlerFileAdmission(pcs);
  new HandlerEmulatorCommunication(emu, pce, pdcs);

  // pidb.start: async computation
  await pidb.start(Html.window.indexedDB);

  // pcs.start: interdependant controllers
  pcs.start(tic);

  // pdcsl.start: async computation
  await pd.start();

  // pls.start: data retrieval from local-storage
  /* await */ pls.start();

  Ft.log('Component_System', 'init#done');
  return ;
}