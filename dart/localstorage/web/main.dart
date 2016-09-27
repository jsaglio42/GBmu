// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 13:44:43 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 14:33:02 by ngoguey          ###   ########.fr       //
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
import './transformer_lse_unserializer.dart';
import './transformer_lse_data_check.dart';
import './transformer_lse_idb_check.dart';

main() {
  print('Hello World');
  LsRom lsrom;
  LsRam lsram;
  PlatformLocalStorage cls;
  PlatformComponentStorage pcs;
  TransformerLseUnserializer tu;
  TransformerLseDataCheck tdc;
  TransformerLseIdbCheck tic;

  final rng = new Random.secure();
  final int maxint = pow(2, 32);
  int romUid;

  try {
    pcs = new PlatformComponentStorage();
    cls = new PlatformLocalStorage();
    tu = new TransformerLseUnserializer(cls);
    tdc = new TransformerLseDataCheck(pcs, tu);
    tic = new TransformerLseIdbCheck(tdc);

    cls.start();
    romUid = rng.nextInt(maxint);

    tic.lsEntryDelete.forEach((_){
          print('main#test-delete');
        });
    tic.lsEntryNew.forEach((_){
          print('main#test-new');
        });
    tic.lsEntryUpdate.forEach((_){
          print('main#test-update');
        });

    lsrom = new LsEntry.json_exn(
        '{"uid":${romUid},"type":"Rom"}',
        '{'
        '"life":"Alive",'
        '"idbid":72,'
        '"_ramSize":12,'
        '"_globalChecksum":5050'
        '}');

    lsram = new LsEntry.json_exn(
        '{"uid":${rng.nextInt(maxint)},"type":"Ram"}',
        '{'
        '"life":"Alive",'
        '"idbid":72,'
        '"romUid":$romUid,'
        // '"romUid":0,'
        '"_size":12'
        '}');

    cls.add(lsrom);
    cls.add(lsram);
    cls.update(lsram);
    cls.delete(lsram);
    // cls.write(new LsRom.unsafe(1507580930, Dead.v, 12, 12, 12));
    // cls.write(new LsRom.unsafe(1507580930, Alive.v, 12, 12, 12));

  } catch (e, st) {
    print(e);
    print(st);
    return ;
  }
}