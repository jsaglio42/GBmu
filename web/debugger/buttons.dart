// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   buttons.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/28 18:57:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 19:47:37 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

class _Data {

  final Html.ButtonElement restart;
  final Html.ButtonElement resume;
  final Html.ButtonElement pause;
  final List<Html.ButtonElement> autobreak;

  _Data.eltList(List<Html.Element> v)
    : restart = v?.elementAt(0)
    , resume = v?.elementAt(1)
    , pause = v?.elementAt(2)
    , autobreak = new List.generate(4, (i) => v?.sublist(3)[i])
  {
    assert(restart != null, 'debButton: missing restart button');
    assert(resume != null, 'debButton: missing resume button');
    assert(pause != null, 'debButton: missing pause button');
    assert(autobreak.every((e) => (e != null)), 'debButton: missing autobreak');
  }

  _Data() : this.eltList(Html.querySelector("#debColButtons")?.children);

}

/*
** Callbacks
*/

void _requestRestart(_) {
  // _data.resume.style.display = '';
  // _data.pause.style.display = 'none';
}

void _requestResume(_) { _emu.send('EmulationResume', 42); }
void _requestPause(_) { _emu.send('EmulationPause', 42); }

void _onResumeEmu(_) {
  _data.resume.style.display = 'none';
  _data.pause.style.display = '';
}

void _onPauseEmu(_) {
  _data.resume.style.display = '';
  _data.pause.style.display = 'none';
}

/*
** Global
*/

final _data = new _Data();
Emulator.Emulator _emu;

/*
* Exposed Methods
*/

void init(Emulator.Emulator emu) {
  Ft.log('button.dart', 'init', [emu]);
  Ft.log('deb_but', 'init');
  _emu = emu;
  _data.toString();

  /* Browser side */
  _data.restart.onClick.forEach(_requestRestart);
  _data.resume.onClick.forEach(_requestResume);
  _data.pause.onClick.forEach(_requestPause);
  // for (var ab in AutoBreakExternalMode.values) {
  //   _data.autobreak[ab.index]
  //     .onClick((_) { _emu.send('EmulationAutoBreak', ab); });
  // }

  /* Emulator Side */
  _emu.listener('EmulationResume').forEach(_onResumeEmu);
  _emu.listener('EmulationPause').forEach(_onPauseEmu);
  return ;
}
