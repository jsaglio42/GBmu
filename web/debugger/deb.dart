// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   deb.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/10 17:18:19 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 14:16:48 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './registers.dart' as Debregisters;
import './mem_registers.dart' as Debmregisters;
import './mem_explorer.dart' as Debmexplorer;
import './instruction_flow.dart' as Debinstflow;
import './clock_info.dart' as Debclocks;
import './buttons.dart' as Debbuttons;

void onOpen()
{
  _emu.send('DebStatusRequest', DebuggerModeRequest.Enable);
}

void onClose()
{
  _emu.send('DebStatusRequest', DebuggerModeRequest.Disable);
}

Emulator.Emulator _emu;

void init(Emulator.Emulator emu)
{
  Ft.log('deb.dart', 'init#start', [emu]);
  _emu = emu;
  var debStatusOn = Html.querySelector('#debStatusOn');
  var debStatusOff = Html.querySelector('#debStatusOff');

  emu.listener('DebStatusUpdate').forEach((bool enabled) {
    Ft.log('deb.dart', 'debStatus#onEvent', [enabled]);
    if (enabled) {
      debStatusOn.style.display = '';
      debStatusOff.style.display = 'none';
    }
    else {
      debStatusOn.style.display = 'none';
      debStatusOff.style.display = '';
    }
  });

  Debregisters.init(emu);
  Debmregisters.init(emu);
  Debmexplorer.init(emu);
  Debinstflow.init(emu);
  Debclocks.init(emu);
  Debbuttons.init(emu);
  Ft.log('deb.dart', 'init#end', [emu]);

}