// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/29 16:10:48 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './debugger/registers.dart' as Debregisters;
import './debugger/mem_registers.dart' as Debmregisters;
import './debugger/mem_explorer.dart' as Debmexplorer;
import './debugger/clock_info.dart' as Debclocks;
import './debugger/buttons.dart' as Debbuttons;
import './main_space/bottom_panel.dart' as Mainbottompanel;

run() async
{
  Ft.log('main', 'run');

  final Html.FileUploadInputElement inBut = Html.querySelector('#inBut');
  assert(inBut != null, "no inbut");

  final reader = new Html.FileReader();
  Uint8List lst;

  inBut.onChange.forEach((_){
        reader.readAsArrayBuffer(inBut.files[0]);
      });
  reader.onLoad.forEach((_){
        lst = reader.result;
      });


  var emuFut = Emulator.spawn()
  .catchError((e) => print('main:\tError while creating emulator:\n$e'));

  var emu = await emuFut;
  Ft.log('main', 'Emulator created');

  Html.querySelector('#magbut')
  .onClick.listen((_) {
        Ft.log('main', 'on magbut');
        emu.send('EmulationStart', lst);
      });

  Html.querySelector('#ejectbut')
  .onClick.listen((_) {
        Ft.log('maint', 'on ejectbut');
        emu.send('Debug', <String, dynamic>{
          'action': 'eject',
        });
      });

  Html.querySelector('#crashbut')
  .onClick.listen((_) {
        Ft.log('maint', 'on crashbut');
        emu.send('Debug', <String, dynamic>{
          'action': 'crash',
        });
      });

  var debStatusOn = Html.querySelector('#debStatusOn');
  var debStatusOff = Html.querySelector('#debStatusOff');
  var debButtonToggle = Html.querySelector('#debButtonToggle');
  var debBody = Js.context.callMethod(r'$', ['#debBody']);


  debButtonToggle.onClick.listen((_){
        Ft.log('main', 'debugger toggle');
        emu.send('DebStatusRequest', DebuggerModeRequest.Toggle);
      });

  emu.listener('DebStatusUpdate').forEach((bool enabled) {
    Ft.log('main', 'onDebStatusUpdate', enabled);
    if (enabled) {
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

  Debregisters.init(emu);
  Debmregisters.init(emu);
  Debmexplorer.init(emu);
  Debclocks.init(emu);
  Debbuttons.init(emu);
  Mainbottompanel.init(emu);


  var mainGameBoyState = Html.querySelector('#mainGameBoyState');
  emu.listener('EmulationStatus').forEach((mode){
        mainGameBoyState.text = mode.toString().substring(20);
      });



  Ft.log('main', 'init jquery tooltips');
  var req = Js.context.callMethod(r'$', ['[data-toggle="tooltip"]']);
  assert(req != null, "Jquery request failed");
  req.callMethod('tooltip', []);

  Ft.log('main', 'init DONE');
}

main()
{
  run().catchError((e) => print('main:\tError:\n$e'));
}
