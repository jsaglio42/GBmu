// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 13:44:43 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 17:36:00 by ngoguey          ###   ########.fr       //
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
  ControllerLocalStorage cls;
  ControllerStorage cs;

  final rng = new Random.secure();
  final int maxint = pow(2, 32);

  try {

    cls = new ControllerLocalStorage();
    cs = new ControllerStorage(cls);
    print(cls.toString());

    cls.start();
    cs.start();

    lsrom = new LsEntry.json_exn(
        '{"uid":${rng.nextInt(maxint)},"type":"Rom"}',
        '{'
        '"life":"Alive",'
        '"idbid":72,'
        '"_ramSize":12,'
        '"_globalChecksum":5050'
        '}');
    print(lsrom.keyJson);
    print(lsrom.valueJson);

    cls.write(lsrom);

  } catch (e, st) {
    print(e);
    print(st);
    return ;
  }

  // cls.write(new LsRom.unsafe(4242, Dead.v, 12, 12, 12));


  // Html.window.localStorage['lol'] = 'super';
  // Html.window.localStorage['alol'] = 'super';
  // Html.window.localStorage['blol'] = 'super';


}