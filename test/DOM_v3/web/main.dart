// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/15 15:09:45 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'emulator.dart' as Emulator;
import 'dart:html' as HTML;
import 'dart:async' as Async;

run() async
{
  print('Main: Hello World');

  var magbut = HTML.querySelector('#magbut');
  magbut.text = 'Hello Test';

  var emuFut = Emulator.create()
  ..catchError((err) {
        print('Main: emu.onError($err)');
      });

  var emu = await emuFut;

  print('Main: Emulator created');
  magbut.onClick.listen((_) {
		print('Main: onClick');
        emu.send('EmulationStart', 42);
        emu.send('EmulationMode', 'vitesse x10!!');
      });

  emu.listener('RegInfo').listen((map) {
        print('Main: onRegInfo($map)');
      });
  print('Main: init phase done');
}

main()
{
  run()
    ..catchError(print);
}
