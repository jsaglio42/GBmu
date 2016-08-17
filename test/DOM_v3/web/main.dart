// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 17:26:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;
import './emulator/emulator.dart' as Emu;
import './debugger/registers.dart' as DebRegisters;
import './emulator/conf.dart';

run() async
{
  print('main:\tHello World');

  var magbut = Html.querySelector('#magbut');

  var emuFut = Emu.create()
  ..catchError((e) {
        print('main:\tError while creating emulator:\n$e');
      });

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
      debBody.callMethod('slideDown', ['fast']);
    }
    else {
      debStatusOn.style.display = 'none';
      debStatusOff.style.display = '';
      debBody.callMethod('slideUp', ['fast']);
    }
  });

  DebRegisters.init(emu);
  print('main:\tinit phase done');
}

main()
{
  run()
    ..catchError((e) {
          print('main:\tError:\n$e');
        });
}
