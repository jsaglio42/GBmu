// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 17:14:02 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;
import 'package:emulator/emulator.dart' as Emu;
import 'package:emulator/emulator_classes.dart';
import 'package:ft/ft.dart' as ft;
import './debugger/registers.dart' as DebRegisters;
// import './debugger/video_registers.dart' as DebVRegisters;
// import './debugger/other_registers.dart' as DebORegisters;
import './debugger/mem_registers.dart' as DebMRegisters;

run() async
{
  print('main:\tHello World');

  var magbut = Html.querySelector('#magbut');

  var emuFut = Emu.spawn()
    .catchError((e) => print('main:\tError while creating emulator:\n$e'));

  var emu = await emuFut;

  print('main:\tEmulator created');
  magbut.onClick.listen((_) {
		print('main:\tonClick');
        emu.send('EmulationStart', 42);
        emu.send('EmulationMode', 'vitesse x10!!');
      });

  var debStatusOn = Html.querySelector('#debStatusOn');
  var debStatusOff = Html.querySelector('#debStatusOff'); 
  var debButtonToggle = Html.querySelector('#debButtonToggle');
  var debBody = Js.context.callMethod(r'$', ['#debBody']);

  debButtonToggle.onClick.listen((_) {
        print('main:\tdebButtonToggle.onClick()');
        emu.send(
            'DebStatusRequest', DebStatusRequest.TOGGLE);
      });

  emu.listener('DebStatusUpdate').listen((DebStatus p) {
    print('main:\tonDebStatusUpdate($p)');
    if (p.index == DebStatus.ON.index) {
      debStatusOn.style.display = '';
      debStatusOff.style.display = 'none';
      debBody.callMethod('slideDown', ['slow']);
    }
    else {
      debStatusOn.style.display = 'none';
      debStatusOff.style.display = '';
      debBody.callMethod('slideUp', ['fast']);
    }
  });

  print('main:\tinit debugger elements');
  DebRegisters.init(emu);
  DebMRegisters.init(emu);

  print('main:\tinit jquery tooltips');
  var req = Js.context.callMethod(r'$', ['[data-toggle="tooltip"]']);
  assert(req != null, "Jquery request failed");
  req.callMethod('tooltip', []);

  print('main:\tinit phase done');
}

main()
{
  run().catchError((e) => print('main:\tError:\n$e'));
}
