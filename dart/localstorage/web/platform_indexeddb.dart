// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_indexeddb.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 15:05:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 16:25:12 by ngoguey          ###   ########.fr       //
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

import './tmp_emulator_enums.dart';
import './tmp_emulator_types.dart' as Emulator;

class PlatformIndexedDb {


  Async.Future<int> add(Component c, Emulator.Serializable s) async {

    return 42;
  }

  Async.Future delete(Component c, int id) async {

    return ;
  }

}