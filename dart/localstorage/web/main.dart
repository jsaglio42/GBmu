// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 13:44:43 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 19:32:28 by ngoguey          ###   ########.fr       //
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
import './controller_local_storage.dart';
import './controller_storage.dart';

main() {
  print('Hello World');
  LsRom lsrom;
  LsRam lsram;
  ControllerLocalStorage cls;
  ControllerStorage cs;

  final rng = new Random.secure();
  final int maxint = pow(2, 32);
  int romUid;

  try {

    cls = new ControllerLocalStorage();
    cs = new ControllerStorage(cls);
    print(cls.toString());

    cls.start();
    cs.start();
    romUid = rng.nextInt(maxint);

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
        '"romUid":0,'
        '"_size":12'
        '}');

    cls.write(lsrom);
    cls.write(lsram);
    // cls.write(new LsRom.unsafe(1507580930, Dead.v, 12, 12, 12));
    // cls.write(new LsRom.unsafe(1507580930, Alive.v, 12, 12, 12));

  } catch (e, st) {
    print(e);
    print(st);
    return ;
  }
}