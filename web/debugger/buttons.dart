// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   buttons.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/28 18:57:22 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:09:17 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
// import 'dart:js' as Js;
// import 'dart:typed_data';
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;


class _Data {

  final Html.ButtonElement _resume;
  final Html.ButtonElement _pause;
  final Html.FormElement _form;

  _Data.eltList(List<Html.Element> v)
    : _resume = v?.elementAt(0)
    , _pause = v?.elementAt(1)
    , _form = v?.elementAt(3)
  {
    assert(_resume != null, 'debButton: missing resume button');
    assert(_pause != null, 'debButton: missing pause button');
    assert(_form != null, 'debButton: missing form button');
    _form.onChange.forEach(_onRadioUpdate);
    _pause.onClick.forEach(_onPauseClick);
    _resume.onClick.forEach(_onResumeClick);
    _emu.listener('EmulationPause').forEach(_onPauseEmu);
    _emu.listener('EmulationResume').forEach(_onResumeEmu);
  }
  _Data() : this.eltList(Html.querySelector("#debColButtons")?.children);

  void _onRadioUpdate(_)
  {
    int i;

    _form.children
      .forEach((l){
            var input = l.children[0];
            if (input.checked)
              i = int.parse(input.value);
          });
    _emu.send('EmulationAutoBreak', AutoBreakExternalMode.values[i]);
  }

  void _onPauseClick(_)
  {
    _emu.send('EmulationPause', 42);
  }
  void _onResumeClick(_)
  {
    _emu.send('EmulationResume', 42);
  }
  void _onPauseEmu(_)
  {
    _pause.style.display = 'none';
    _resume.style.display = '';
  }
  void _onResumeEmu(_)
  {
    _pause.style.display = '';
    _resume.style.display = 'none';
  }
}

final _data = new _Data();
Emulator.Emulator _emu;

void init(Emulator.Emulator emu)
{
  Ft.log('button.dart', 'init', [emu]);
  Ft.log('deb_but', 'init');
  _emu = emu;
  _data.toString(); /* Tips to instanciate _data */
}
