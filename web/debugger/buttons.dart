// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   buttons.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/28 18:57:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 20:34:05 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

class _Data {

  final Html.ButtonElement resume;
  final Html.ButtonElement pause;
  final List<Html.ButtonElement> limitedEmulation;

  _Data()
    : resume = Html.querySelector("#debColButtons .ft-resume")
    , pause = Html.querySelector("#debColButtons .ft-pause")
    , limitedEmulation = new List.from(
        Html.querySelectorAll("#debColButtons .ft-limited-emu"))
  {
    assert(resume != null, 'debButton: missing resume button');
    assert(pause != null, 'debButton: missing pause button');
    assert(limitedEmulation.every((e) => (e != null)),
        'debButton: missing limitedEmulation');
  }

}

/*
** Callbacks
*/

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
  _emu = emu;
  _data.toString();

  /* Browser side */
  _data.resume.onClick.forEach(_requestResume);
  _data.pause.onClick.forEach(_requestPause);
  for (var le in LimitedEmulation.values) {
    _data.limitedEmulation[le.index]
      .onClick.forEach((_) {
            _emu.send('LimitedEmulation', le);
          });
  }

  /* Emulator Side */
  _emu.listener('EmulationResume').forEach(_onResumeEmu);
  _emu.listener('EmulationPause').forEach(_onPauseEmu);
  return ;
}
