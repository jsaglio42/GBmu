// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 11:08:40 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:async' as Async;
import 'dart:js' as Js;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;
import 'package:emulator/variants.dart' as V;
import 'package:component_system/cs.dart' as Cs;

import './debugger/deb.dart' as Deb;

import './alerts.dart' as Mainalerts;
import './canvas.dart' as Canvas;
import './options/options.dart' as Opt;
import './nav.dart' as Nav;
import './key_mapping/key_mapping.dart' as KeyMap;

run() async
{
  Ft.log('main.dart', 'run');

  var emuFut = Emulator.spawn()
  .catchError((e) => print('main:\tError while creating emulator:\n$e'));

  var emu = await emuFut;
  Ft.log('main.dart', 'run#emuCreated');
  Mainalerts.init(emu);

  Canvas.init(emu);

  Deb.init(emu);
  Opt.init(emu);
  final Cs.Cs cs = await Cs.init(emu);
  KeyMap.init(emu, cs);
  await Nav.init(emu);


  Ft.log('main.dart', 'run#initJqTooltips');
  var req = Js.context.callMethod(r'$', ['[data-toggle="tooltip"]']);
  assert(req != null, "Jquery request failed");
  req.callMethod('tooltip', []);

  Ft.log('main.dart', 'run#done');
}

void test_endianess(){
  var l16 = new Uint16List(15);
  for (int i = 0; i < 15; i++) {
    l16[i] = (2 * i) + ((2 * i + 1) << 8);
  }
  var l8 = new Uint8List.view(l16.buffer);
  print(l16);
  print(l8);
  return ;
}

main()
{
  Async.runZoned((){
    run();
  }, onError: (_, st) {
    Ft.logerr('main.dart', 'main#uncaught', [st]);
  });
  // Emulator.debugRomHeader();
  // test_endianess();
  return ;
}
