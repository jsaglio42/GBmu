// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   nav.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/10 16:32:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 17:03:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:js' as Js;
import 'dart:async' as Async;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/variants.dart';
import 'package:emulator/emulator.dart' as Emulator;
import './debugger/deb.dart' as Deb;
import './options/options.dart' as Opt;

// import 'package:component_system/cs.dart' as Cs;

typedef void _callback_t();

class _Panel {

  Html.LIElement _parent;
  Html.AnchorElement _a;
  bool _openned = true;
  _callback_t _cbOpen;
  _callback_t _cbClose;
  Html.DivElement _panel;

  _Panel(a, panel, this._cbOpen, this._cbClose)
    : _parent = a.parent
    , _a = a
    , _panel = panel
  {
    _a.onClick.forEach(this.toggle);
    _parent.classes.add('active');
  }

  void toggle(_)
  {
    if (_openned)
      _close();
    else
      _open();
  }

  void _open()
  {
    Ft.log('nav.dart', '_Panel#_open', []);
    _parent.classes.add('active');
    _panel.style.display = '';
    _openned = true;
    if (_cbOpen != null)
      _cbOpen();
  }

  void _close()
  {
    Ft.log('nav.dart', '_Panel#_close', []);
    _parent.classes.remove('active');
    _panel.style.display = 'none';
    _openned = false;
    if (_cbClose != null)
      _cbClose();
  }

}

var _panels;
var mainGameBoyState = Html.querySelector('#mainGameBoyState');
var mainRomName = Html.querySelector('#mainRomName');

List<_Panel> _makePanels(Emulator.Emulator emu)
{
  final List aLst = Html.querySelectorAll('.navbar .nav > li > a');
  final List<_Panel> l = [];

  l.add(new _Panel(aLst[3], Html.querySelector('#debBody'),
          Deb.onOpen, Deb.onClose));
  l.add(new _Panel(aLst[1], Html.querySelector('#optBody'),
          Opt.onOpen, Opt.onClose));
  l.add(new _Panel(aLst[0], Html.querySelector('#cartsContainer'),
          (){
      Html.querySelector('#canvasContainer')
        .classes
        ..add('col-md-8')
        ..add('col-lg-9')
        ..remove('col-lg-12');
    }, (){
      Html.querySelector('#canvasContainer')
        .classes
        ..remove('col-md-8')
        ..remove('col-lg-9')
        ..add('col-lg-12');
    }));
  return l;
}

void _onEmulatorEvent(Map<String, dynamic> map) {
  final EmulatorEvent ev = map['type'];

  Ft.log('nav', '_onEmulatorEvent', [map]);

  if (ev is GameBoyEvent)
    _onGameBoyEvent(ev as GameBoyEvent, map);
  else {
    mainRomName.text = '';
    mainGameBoyState.text = '(Emulator crashed, reload page)';
  }
}

void _onGameBoyEvent(GameBoyEvent ev, Map<String, dynamic> map) {
  if (ev.dst is Absent)
    mainGameBoyState.text = '(Absent)';
  else if (ev.dst is Crashed)
    mainGameBoyState.text = '(Game crashed, restart or eject)';
  else
    mainGameBoyState.text = '(Emulating)';

  if (ev.src is Absent && ev.dst is! Absent) {
    if (map['name'].length > 25)
      mainRomName.text = map['name'].substring(0, 25) + '...';
    else
      mainRomName.text = map['name'];
  }
  else if (ev.dst is Absent && ev.src is! Absent)
    mainRomName.text = '';
}

Async.Future init(Emulator.Emulator emu) async
{
  Ft.log('nav.dart', 'init#start', [emu]);
  _panels = _makePanels(emu);
  emu.listener('Events').forEach(_onEmulatorEvent);
  return;
}