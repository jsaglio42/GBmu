// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:55:53 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;
import 'dart:typed_data';
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './debugger/registers.dart' as Debregisters;
import './debugger/mem_registers.dart' as Debmregisters;

run() async
{
  print('main:\tHello World');

  final Html.FileUploadInputElement inBut = Html.querySelector('#inBut');
  assert(inBut != null);
  final reader = new Html.FileReader();
  Uint8List lst;

  inBut.onChange.forEach((_){
        reader.readAsArrayBuffer(inBut.files[0]);
      });
  reader.onLoad.forEach((_){
        lst = reader.result;
      });

  var magbut = Html.querySelector('#magbut');

  var emuFut = Emulator.spawn()
    .catchError((e) => print('main:\tError while creating emulator:\n$e'));

  var emu = await emuFut;

  print('main:\tEmulator created');
  magbut.onClick.listen((_) {
		print('main:\tonClick');
        emu.send('EmulationStart', lst);
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
  Debregisters.init(emu);
  Debmregisters.init(emu);

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
