// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   main.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/10 17:25:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/08 15:40:21 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;
import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './main_space/keyboard.dart' as Keyboard;
import './main_space/canvas.dart' as Canvas;

import './debugger/registers.dart' as Debregisters;
import './debugger/mem_registers.dart' as Debmregisters;
import './debugger/mem_explorer.dart' as Debmexplorer;
import './debugger/instruction_flow.dart' as Debinstflow;
import './debugger/clock_info.dart' as Debclocks;
import './debugger/buttons.dart' as Debbuttons;

import './alerts.dart' as Mainalerts;
import 'nav.dart' as Nav;

run() async
{
  Ft.log('main.dart', 'run');

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
  Ft.log('main.dart', 'run#emuCreated');

  Html.querySelector('#magbut')
  .onClick.listen((_) {
        Ft.log('main.dart', 'magbut#onClick');
        emu.send('EmulationStart', lst);
      });

  Html.querySelector('#ejectbut')
  .onClick.listen((_) {
        Ft.log('main.dart', 'ejectbut#onClick');
        emu.send('Debug', <String, dynamic>{
          'action': 'eject',
        });
      });

  Html.querySelector('#crashbut')
  .onClick.listen((_) {
        Ft.log('main.dart', 'crashbut#onClick');
        emu.send('Debug', <String, dynamic>{
          'action': 'crash',
        });
      });


  // debButtonToggle.onClick.listen((_){
  //       Ft.log('main.dart', 'debToggle#onClick');
  //       emu.send('DebStatusRequest', DebuggerModeRequest.Toggle);
  //     });

  // emu.listener('DebStatusUpdate').forEach((bool enabled) {
  //   Ft.log('main.dart', 'debStatus#onEvent', [enabled]);
  //   if (enabled) {
  //     debStatusOn.style.display = '';
  //     debStatusOff.style.display = 'none';
  //     debBody.callMethod('slideDown', ['slow']);
  //   }
  //   else {
  //     debStatusOn.style.display = 'none';
  //     debStatusOff.style.display = '';
  //     debBody.callMethod('slideUp', ['fast']);
  //   }
  // });


  Debregisters.init(emu);
  Debmregisters.init(emu);
  Debmexplorer.init(emu);
  Debinstflow.init(emu);
  Debclocks.init(emu);
  Debbuttons.init(emu);
  // Mainbottompanel.init(emu);
  Mainalerts.init(emu);

  Keyboard.init(emu);
  Canvas.init(emu);

  // Mainalerts.init(emu);
  Nav.init(emu);

  var mainGameBoyState = Html.querySelector('#mainGameBoyState');

  var mainRomName = Html.querySelector('#mainRomName');
  emu.listener('EmulationStatus').forEach((modeRaw){
        final mode = GameBoyExternalMode.values[modeRaw.index];
        final name = 'Plokemon Violet super cool version 5.55';

        try {
          if (mode == GameBoyExternalMode.Absent)
            mainRomName.text = '';
          else if (name.length > 20)
            mainRomName.text = name.substring(0, 20) + '...';
          else
            mainRomName.text = name;
          mainGameBoyState.text = '(' + mode.toString().substring(20) + ')';
        } catch (e) {
          print(e);
        }
      });



  // final Html.ElementList<Html.AnchorElement> panelAnchors = Html.querySelectorAll('.navbar .nav > li > a');

  // panelAnchors.onClick.forEach((Html.MouseEvent ev) {
  //   Ft.log('main.dart', 'panelAnchors#onClick');

  //   final Html.AnchorElement tar = ev.target;
  //   tar.parent.classes.add('active');
  //   print(tar.parent.runtimeType);
  //   panelAnchors.where((Html.AnchorElement a) => a != tar).forEach((Html.AnchorElement a) {
  //     a.parent.classes.remove('active');
  //   });
  // });


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
  // Emulator.debugRomHeader();
  // test_endianess();
  run().catchError((e) => print('main:\tError:\n$e'));
  return ;
}
