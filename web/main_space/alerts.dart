// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   alerts.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/30 08:43:27 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/30 11:53:08 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './emulation_speed_codec.dart' as ESCodec;

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
    EmulatorEvent.GameBoyStart: {'class': 'success', 'timeout': true, 'name': 'Start'},
    EmulatorEvent.GameBoyEject: {'class': 'info', 'timeout': true, 'name': 'Eject'},
    EmulatorEvent.GameBoyCrash: {'class': 'danger', 'timeout': false, 'name': 'Crash'},
    EmulatorEvent.InitError: {'class': 'error', 'timeout': false, 'name': 'Error'},
  };

  _Message(this.type, this.msg, this.id)
  {
  }

  String get alertClass =>
    'alert-' + _mapping[this.type]['class'];
  String get readableType =>
    _mapping[this.type]['name'][0].toUpperCase() +
    _mapping[this.type]['name'].substring(1) + ':';

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
    _anchor.text = '×';
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
      this.block.classes.remove(msg.alertClass);
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

  _Data(Emulator.Emulator emu)
  {
    var m1 = new _Message(EmulatorEvent.GameBoyStart, 'msg1 lol', _ids++);
    var m2 = new _Message(EmulatorEvent.GameBoyCrash, 'msg2 lol msg2 lol msg2 lol msg2 lol msg2 lol msg2 lol msg2 lol msg2 lol ', _ids++);
    var m3 = new _Message(EmulatorEvent.GameBoyEject, 'msg3 lol', _ids++);

    _addMessage(m1);
    _addMessage(m2);
    _addMessage(m3);
  }

  void refresh()
  {
    _container.nodes = _frames.where((f) => f.shown).map((f) => f.block);
  }

  void _addMessage(_Message msg)
  {
    var node;

    print('a');
    _frames.sort((a, b) {
      if (a.shown && b.shown)
        return a.msgIdOrNull - b.msgIdOrNull;
      else
        return a.shown ? -1 : 1;
    });
    print('b');
    try {
      node = _frames.firstWhere((n) => !n.shown);
      print('c');
    } catch (_) {
      node = new _Frame(this);
      _frames.add(node);
      print('d');
    }
    print('e $node');
    node.render(msg);
    print('f');
    this.refresh();
    print('g');
  }

  void _onEmulatorEvent(EmulatorEvent evRaw)
  {
    final EmulatorEvent ev = EmulatorEvent.values[evRaw.index];
    // final m

  }

}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('main_alerts', 'init');
  _data = new _Data(emu);
  return ;
}
