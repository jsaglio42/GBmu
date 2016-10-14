// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   alerts.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/30 08:43:27 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/13 18:59:00 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import "dart:core" hide Error;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/enums.dart';
import 'package:emulator/variants.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

var _data;
final Html.DivElement _container = Html.querySelector('#mainAlertBox');
final Duration _TIMEOUT_DURATION = new Duration(seconds: 3);

/*
 * Internal Methods
 */
class _Message {

  final EmulatorEvent type;
  final String msg;
  final int id;
  final static _mapping = <EmulatorEvent, Map>{
    Start.v: {'class': 'success', 'timeout': true},
    CrashedRestart.v: {'class': 'success', 'timeout': true},
    EmulatingRestart.v: {'class': 'success', 'timeout': true},

    StartError.v: {'class': 'warning', 'timeout': false},
    CrashedRestartError.v: {'class': 'warning', 'timeout': false},
    EmulatingRestartError.v: {'class': 'warning', 'timeout': false},

    EmulatingEject.v: {'class': 'info', 'timeout': true},
    CrashedEject.v: {'class': 'info', 'timeout': true},

    Crash.v: {'class': 'danger', 'timeout': false},
    EmulatorCrash.v: {'class': 'danger', 'timeout': false},
  };

  _Message(this.type, this.msg, this.id);

  String get alertClass => 'alert-' + _mapping[this.type]['class'];
  String get readableType => type.toString() + ':';
  bool get timeout => _mapping[this.type]['timeout'];

}

class _Frame {

  final Html.DivElement block;
  final Html.HtmlElement _headerDiv;
  final Html.HtmlElement _messageDiv;
  final Html.AnchorElement _anchor;
  final _Data _handler;

  bool _shown = false;
  Async.Timer _timerOrNull = null;
  _Message _msgOrNull = null;

  int get msgIdOrNull => _msgOrNull.id;
  bool get shown => _shown;

  _Frame(this._handler)
    : block = new Html.Element.tag('div')
    , _headerDiv = new Html.Element.tag('strong')
    , _messageDiv = new Html.Element.tag('span')
    , _anchor = new Html.Element.tag('a')
  {
    assert(this.block != null, "Construction failed for block element");
    assert(_headerDiv != null, "Construction failed for header element");
    assert(_messageDiv != null, "Construction failed for message element");
    assert(_anchor != null, "Construction failed for anchor element");
    this.block.classes.add('alert');
    _anchor.classes.add('close');
    _anchor.href = '#';
    _anchor.text = '×'; // utf character
    _anchor.setAttribute('aria-label', "close");

    this.block.append(_anchor);
    this.block.append(_headerDiv);
    this.block.append(_messageDiv);

    _anchor.onClick.forEach(_onClick);
  }

  void _onClick([_])
  {
    if (_timerOrNull != null) {
      if (_timerOrNull.isActive)
        _timerOrNull.cancel();
      _timerOrNull = null;
    }
    _shown = false;
    _handler.refresh();
  }

  void render(_Message msg)
  {
    if (_msgOrNull != null)
      this.block.classes.remove(_msgOrNull.alertClass);
    this.block.classes.add(msg.alertClass);
    _headerDiv.text = msg.readableType;
    _messageDiv.text = msg.msg;
    _shown = true;
    _msgOrNull = msg;
    if (msg.timeout)
      _timerOrNull = new Async.Timer(_TIMEOUT_DURATION, _onClick);
  }

}

class _Data {

  final List<_Frame> _frames = new List<_Frame>();
  int _ids = 0;

  _Data(Emulator.Emulator emu) {
    emu.listener('Events').forEach(_onEmulatorEvent);
  }

  void refresh()
  {
    _container.nodes = _frames.where((f) => f.shown).map((f) => f.block);
  }

  void _addMessage(_Message msg)
  {
    var node;

    _frames.sort((a, b) {
      if (a.shown && b.shown)
        return a.msgIdOrNull - b.msgIdOrNull;
      else
        return a.shown ? -1 : 1;
    });
    try {
      node = _frames.firstWhere((n) => !n.shown);
    } catch (_) {
      Ft.log('alerts.dart', '_addMessage#newFrameAllocation');
      node = new _Frame(this);
      _frames.add(node);
    }
    node.render(msg);
    this.refresh();
  }

  void _onEmulatorEvent(Map<String, dynamic> map) {
    final EmulatorEvent ev = map['type'].reinstanciate;

    Ft.log('nav', '_onEmulatorEvent', [map]);

    if (ev is GameBoyEvent)
      _onGameBoyEvent(ev as GameBoyEvent, map);
    else {
      _addMessage(new _Message(ev, map['msg'].toString(), _ids++));
      Ft.logerr('alerts.dart', 'event', [map]);
    }
  }

  void _onGameBoyEvent(GameBoyEvent ev, Map<String, dynamic> map) {
    if (ev is EmulationBegin) {
      _addMessage(new _Message(ev, map['name'], _ids++));
      Ft.log('alerts.dart', 'event', [map]);
    }
    else if (ev is Eject) {
      _addMessage(new _Message(ev, map['name'], _ids++));
      Ft.log('alerts.dart', 'event', [map]);
    }
    else if (ev is Error && ev.dst is Absent) {
      _addMessage(new _Message(ev, map['msg'], _ids++));
      Ft.logwarn('alerts.dart', 'event', [map]);
    }
  }

}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('alerts.dart', 'event');
  _data = new _Data(emu);
  return ;
}
