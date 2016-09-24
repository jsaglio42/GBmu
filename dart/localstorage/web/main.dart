// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixins.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 10:26:42 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 12:32:26 by ngoguey          ###   ########.fr       //
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

main() {
  print('Hello World');
  LsRom lsrom;

  try {
    lsrom = new LsEntry.json_exn(
        '{"uid":4242,"type":"Rom"}',
        '{'
        '"life":"Alive",'
        '"idbid":72,'
        '"_ramSize":12,'
        '"_globalChecksum":5050'
        '}');
    print(lsrom.keyJson);
    print(lsrom.valueJson);
  } catch (e, st) {
    print(e);
    print(st);
  }

}