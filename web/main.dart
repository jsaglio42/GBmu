// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 13:19:22 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:async' as Async;
import 'dart:js' as Js;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/emulator.dart' as Emulator;
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

  final Emulator.Emulator emu = await Emulator.spawn();

  Mainalerts.init(emu);
  Canvas.init(emu);
  Deb.init(emu);
  Opt.init(emu);
  final Cs.Cs cs = await Cs.init(emu);

  KeyMap.init(emu, cs);
  await Nav.init(emu);

  // Init JQ tooltips
  var req = Js.context.callMethod(r'$', ['[data-toggle="tooltip"]']);
  assert(req != null, "Jquery request failed");
  req.callMethod('tooltip', []);
}

main()
{
  Async.runZoned((){
    run();
  }, onError: (_, st) {
    Ft.logerr('main.dart', 'main#uncaught', [st]);
  });
  return ;
}
