// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 14:28:30 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'emulator.dart' as Emulator;
import 'dart:html' as HTML;
import 'dart:async' as Async;
import 'dart:js' as Js;

run() async
{
  print('main:\tHello World');

  var magbut = HTML.querySelector('#magbut');
  magbut.text = 'Hello Test';

  var emuFut = Emulator.create()
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

  emu.listener('RegInfo').listen((map) {
        print('main:\tonRegInfo($map)');
      });



  var debStatusOn = HTML.querySelector('#debStatusOn');
  var debStatusOff = HTML.querySelector('#debStatusOff');
  var debButtonToggle = HTML.querySelector('#debButtonToggle');
  var debBody = Js.context.callMethod(r'$', ['#debBody']);

  debButtonToggle.onClick.listen((_) {
        print('main:\tdebButtonToggle.onClick()');
        emu.send(
            'DebStatusRequest', Emulator.DebStatusRequest.TOGGLE);
      });

  emu.listener('DebStatusUpdate').listen((Emulator.DebStatus p) {
    print('main:\tonDebStatusUpdate($p)');
    if (p.index == Emulator.DebStatus.ON.index) {
      debStatusOn.style.display = '';
      debStatusOff.style.display = 'none';
      debBody.callMethod('slideDown', ['slow']);
    }
    else {
      debStatusOn.style.display = 'none';
      debStatusOff.style.display = '';
      debBody.callMethod('slideUp', ['slow']);
    }
  });

  print('main:\tinit phase done');
}

main()
{
  run()
    ..catchError((e) {
          print('main:\tError:\n$e');
        });
}
