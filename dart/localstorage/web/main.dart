// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 13:44:43 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 17:13:23 by ngoguey          ###   ########.fr       //
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
import './platform_local_storage.dart';
import './platform_component_storage.dart';
import './platform_indexeddb.dart';
import './transformer_lse_unserializer.dart';
import './transformer_lse_data_check.dart';
import './transformer_lse_idb_check.dart';

import './tmp_emulator_enums.dart';
import './tmp_emulator_types.dart' as Emulator;

main() async {
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
    tic = new TransformerLseIdbCheck(tdc);

    pls.start();
    pcs.start(tic);

    pcs.newRom(rom);
    pcs.newRam(ram);

    lsrom = await pcs.entryNew.where((LsEntry e) => e.type is Rom).first;
    lsram = await pcs.entryNew.where((LsEntry e) => e.type is Ram).first;

    pcs.bind(lsram, lsrom);

    lsram = (await pcs.entryUpdate.first).newValue;
    await new Async.Future.delayed(new Duration(seconds: 3));
    print('go!');

    pcs.unbind(lsram);


  } catch (e, st) {
    print(e);
    print(st);
    return ;
  }
}