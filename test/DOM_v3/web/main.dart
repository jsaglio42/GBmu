// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 16:19:43 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'emulator.dart' as Emulator;
import 'dart:html' as HTML;
import 'dart:async' as Async;

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
  print('main:\tinit phase done');
}

main()
{
  run()
    ..catchError((e) {
          print('main:\tError:\n$e');
        });
}
